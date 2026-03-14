// hxcpp include should be first
#include <hxcpp.h>
#include "./linc_cpython.h"
#include <cpython/PythonCallback.h>
#include <haxe/Exception.h>
#include <cstring>
#include <fstream>
#include <sstream>
#include <string>

namespace linc {

    namespace cpython {

        namespace {

            struct HaxeCallbackInfo {
                int callbackId;
                std::string name;
                PyMethodDef def;
            };

            inline PyObject* asPyObject(void* obj) {
                return reinterpret_cast<PyObject*>(obj);
            }

            inline void* asHandle(PyObject* obj) {
                return reinterpret_cast<void*>(obj);
            }

            inline PyObject* getMainGlobals() {
                PyObject* mainModule = PyImport_AddModule("__main__");
                if (!mainModule) {
                    return nullptr;
                }
                return PyModule_GetDict(mainModule);
            }

            inline PyObject* getSysPathList() {
                return PySys_GetObject("path");
            }

            inline void* returnNoneHandle() {
                Py_INCREF(Py_None);
                return asHandle(Py_None);
            }

            inline ::String stringFromPyTextObject(PyObject* obj) {
                if (!obj) {
                    return null();
                }

                PyObject* stringObj = PyObject_Str(obj);
                if (!stringObj) {
                    return null();
                }

                const char* value = PyUnicode_AsUTF8(stringObj);
                ::String result = value ? ::String(value) : null();
                Py_DECREF(stringObj);
                return result;
            }

            inline PyObject* asBytesObject(PyObject* obj) {
                if (!obj) {
                    return nullptr;
                }

                if (PyBytes_Check(obj)) {
                    Py_INCREF(obj);
                    return obj;
                }

                return PyObject_Bytes(obj);
            }

            inline ::String bytesLikeToString(PyObject* obj) {
                PyObject* bytesObj = asBytesObject(obj);
                if (!bytesObj) {
                    return null();
                }

                char* buffer = nullptr;
                Py_ssize_t size = 0;
                ::String result = null();

                if (PyBytes_AsStringAndSize(bytesObj, &buffer, &size) == 0 && buffer) {
                    result = ::String(buffer);
                }

                Py_DECREF(bytesObj);
                return result;
            }

            inline ::String formatFetchedError(PyObject* ptype, PyObject* pvalue, PyObject* ptraceback) {
                if (!ptype && !pvalue && !ptraceback) {
                    return ::String("No error");
                }

                PyErr_NormalizeException(&ptype, &pvalue, &ptraceback);

                ::String result = pvalue ? stringFromPyTextObject(pvalue) : stringFromPyTextObject(ptype);

                PyObject* tracebackModule = PyImport_ImportModule("traceback");
                if (tracebackModule) {
                    PyObject* formatExceptionFn = PyObject_GetAttrString(tracebackModule, "format_exception");
                    if (formatExceptionFn) {
                        PyObject* args = PyTuple_New(3);
                        PyObject* typeObj = ptype ? ptype : Py_None;
                        PyObject* valueObj = pvalue ? pvalue : Py_None;
                        PyObject* tracebackObj = ptraceback ? ptraceback : Py_None;

                        Py_INCREF(typeObj);
                        Py_INCREF(valueObj);
                        Py_INCREF(tracebackObj);
                        PyTuple_SetItem(args, 0, typeObj);
                        PyTuple_SetItem(args, 1, valueObj);
                        PyTuple_SetItem(args, 2, tracebackObj);

                        PyObject* formattedList = PyObject_CallObject(formatExceptionFn, args);
                        Py_DECREF(args);

                        if (formattedList) {
                            PyObject* separator = PyUnicode_FromString("");
                            PyObject* joined = PyUnicode_Join(separator, formattedList);
                            Py_DECREF(separator);
                            Py_DECREF(formattedList);

                            if (joined) {
                                const char* text = PyUnicode_AsUTF8(joined);
                                if (text) {
                                    result = ::String(text);
                                }
                                Py_DECREF(joined);
                            } else {
                                PyErr_Clear();
                            }
                        } else {
                            PyErr_Clear();
                        }

                        Py_DECREF(formatExceptionFn);
                    } else {
                        PyErr_Clear();
                    }

                    Py_DECREF(tracebackModule);
                } else {
                    PyErr_Clear();
                }

                Py_XDECREF(ptype);
                Py_XDECREF(pvalue);
                Py_XDECREF(ptraceback);

                return result != null() ? result : ::String("Unknown error");
            }

            void destroyHaxeCallbackCapsule(PyObject* capsule) {
                HaxeCallbackInfo* info = reinterpret_cast<HaxeCallbackInfo*>(PyCapsule_GetPointer(capsule, "linc_cpython.callback"));
                if (!info) {
                    PyErr_Clear();
                    return;
                }

                ::cpython::PythonCallback_obj::releaseRegistered(info->callbackId);
                delete info;
            }

            PyObject* invokeHaxeRegisteredCallback(PyObject* self, PyObject* args, PyObject* kwargs) {
                HaxeCallbackInfo* info = reinterpret_cast<HaxeCallbackInfo*>(PyCapsule_GetPointer(self, "linc_cpython.callback"));
                if (!info) {
                    PyErr_SetString(PyExc_RuntimeError, "Invalid Haxe callback capsule");
                    return nullptr;
                }

                try {
                    void* result = ::cpython::PythonCallback_obj::invokeRegistered(info->callbackId, asHandle(args), asHandle(kwargs));
                    if (!result) {
                        Py_INCREF(Py_None);
                        return Py_None;
                    }
                    return asPyObject(result);
                } catch (::Dynamic e) {
                    ::String message = ::String("Haxe callback failed");
                    try {
                        message = ::haxe::Exception_obj::caught(e)->get_message();
                    } catch (...) {
                    }
                    PyErr_SetString(PyExc_RuntimeError, message.c_str());
                    return nullptr;
                } catch (...) {
                    PyErr_SetString(PyExc_RuntimeError, "Unknown Haxe callback failure");
                    return nullptr;
                }
            }

        }

        // Python interpreter lifecycle
        void initialize() {
            if (!Py_IsInitialized()) {
                Py_Initialize();
            }
        }

        void finalize() {
            if (Py_IsInitialized()) {
                Py_Finalize();
            }
        }

        bool isInitialized() {
            return Py_IsInitialized() != 0;
        }

        void* getMainModule() {
            return asHandle(PyImport_AddModule("__main__"));
        }

        void* getMainDict() {
            return asHandle(getMainGlobals());
        }

        void* getBuiltins() {
            return asHandle(PyEval_GetBuiltins());
        }

        void* getSysModules() {
            return asHandle(PyImport_GetModuleDict());
        }

        // Module and import
        void* importModule(const char* name) {
            if (!name) {
                return nullptr;
            }
            return asHandle(PyImport_ImportModule(name));
        }

        void* reloadModule(void* module) {
            PyObject* pyModule = asPyObject(module);
            if (!pyModule) {
                return nullptr;
            }
            return asHandle(PyImport_ReloadModule(pyModule));
        }

        void* getModuleDict(void* module) {
            PyObject* pyModule = asPyObject(module);
            if (!pyModule) {
                return nullptr;
            }
            return asHandle(PyModule_GetDict(pyModule));
        }

        int appendSysPath(const char* path) {
            if (!path) {
                return -1;
            }

            PyObject* sysPath = getSysPathList();
            if (!sysPath || !PyList_Check(sysPath)) {
                return -1;
            }

            PyObject* pyPath = PyUnicode_FromString(path);
            if (!pyPath) {
                return -1;
            }

            int result = PyList_Append(sysPath, pyPath);
            Py_DECREF(pyPath);
            return result;
        }

        int insertSysPath(int index, const char* path) {
            if (!path) {
                return -1;
            }

            PyObject* sysPath = getSysPathList();
            if (!sysPath || !PyList_Check(sysPath)) {
                return -1;
            }

            PyObject* pyPath = PyUnicode_FromString(path);
            if (!pyPath) {
                return -1;
            }

            int result = PyList_Insert(sysPath, (Py_ssize_t)index, pyPath);
            Py_DECREF(pyPath);
            return result;
        }

        // Object reference counting
        void incref(void* obj) {
            PyObject* pyObj = asPyObject(obj);
            if (pyObj) {
                Py_INCREF(pyObj);
            }
        }

        void decref(void* obj) {
            PyObject* pyObj = asPyObject(obj);
            if (pyObj) {
                Py_DECREF(pyObj);
            }
        }

        int getRefCount(void* obj) {
            PyObject* pyObj = asPyObject(obj);
            if (!pyObj) {
                return 0;
            }
            return (int)Py_REFCNT(pyObj);
        }

        // Type checking
        bool isNone(void* obj) {
            return asPyObject(obj) == Py_None;
        }

        bool isBool(void* obj) {
            PyObject* pyObj = asPyObject(obj);
            return pyObj && PyBool_Check(pyObj);
        }

        bool isInt(void* obj) {
            PyObject* pyObj = asPyObject(obj);
            return pyObj && PyLong_Check(pyObj);
        }

        bool isFloat(void* obj) {
            PyObject* pyObj = asPyObject(obj);
            return pyObj && PyFloat_Check(pyObj);
        }

        bool isString(void* obj) {
            PyObject* pyObj = asPyObject(obj);
            return pyObj && PyUnicode_Check(pyObj);
        }

        bool isBytes(void* obj) {
            PyObject* pyObj = asPyObject(obj);
            return pyObj && PyBytes_Check(pyObj);
        }

        bool isByteArray(void* obj) {
            PyObject* pyObj = asPyObject(obj);
            return pyObj && PyByteArray_Check(pyObj);
        }

        bool isMemoryView(void* obj) {
            PyObject* pyObj = asPyObject(obj);
            return pyObj && PyMemoryView_Check(pyObj);
        }

        bool isList(void* obj) {
            PyObject* pyObj = asPyObject(obj);
            return pyObj && PyList_Check(pyObj);
        }

        bool isDict(void* obj) {
            PyObject* pyObj = asPyObject(obj);
            return pyObj && PyDict_Check(pyObj);
        }

        bool isTuple(void* obj) {
            PyObject* pyObj = asPyObject(obj);
            return pyObj && PyTuple_Check(pyObj);
        }

        bool isSlice(void* obj) {
            PyObject* pyObj = asPyObject(obj);
            return pyObj && PySlice_Check(pyObj);
        }

        bool isSet(void* obj) {
            PyObject* pyObj = asPyObject(obj);
            return pyObj && PySet_Check(pyObj);
        }

        bool isCallable(void* obj) {
            PyObject* pyObj = asPyObject(obj);
            return pyObj && PyCallable_Check(pyObj);
        }

        bool isModule(void* obj) {
            PyObject* pyObj = asPyObject(obj);
            return pyObj && PyModule_Check(pyObj);
        }

        // Conversions from Python to C++
        int toInt(void* obj) {
            PyObject* pyObj = asPyObject(obj);
            if (!pyObj) {
                return 0;
            }
            return (int)PyLong_AsLong(pyObj);
        }

        double toFloat(void* obj) {
            PyObject* pyObj = asPyObject(obj);
            if (!pyObj) {
                return 0.0;
            }
            return PyFloat_AsDouble(pyObj);
        }

        ::String toString(void* obj) {
            PyObject* pyObj = asPyObject(obj);
            if (!pyObj || pyObj == Py_None) {
                return null();
            }

            PyObject* stringObj = PyObject_Str(pyObj);
            if (!stringObj) {
                return null();
            }

            const char* value = PyUnicode_AsUTF8(stringObj);
            ::String result = value ? ::String(value) : null();
            Py_DECREF(stringObj);
            return result;
        }

        ::String repr(void* obj) {
            PyObject* pyObj = asPyObject(obj);
            if (!pyObj || pyObj == Py_None) {
                return null();
            }

            PyObject* reprObj = PyObject_Repr(pyObj);
            if (!reprObj) {
                return null();
            }

            const char* value = PyUnicode_AsUTF8(reprObj);
            ::String result = value ? ::String(value) : null();
            Py_DECREF(reprObj);
            return result;
        }

        ::String typeName(void* obj) {
            PyObject* pyObj = asPyObject(obj);
            if (!pyObj) {
                return null();
            }

            const char* name = Py_TYPE(pyObj)->tp_name;
            return name ? ::String(name) : null();
        }

        bool toBool(void* obj) {
            PyObject* pyObj = asPyObject(obj);
            if (!pyObj) {
                return false;
            }
            return PyObject_IsTrue(pyObj) == 1;
        }

        // Conversions from C++ to Python
        void* fromInt(int value) {
            return asHandle(PyLong_FromLong((long)value));
        }

        void* fromFloat(double value) {
            return asHandle(PyFloat_FromDouble(value));
        }

        void* fromString(const char* value) {
            if (!value) {
                return returnNoneHandle();
            }
            return asHandle(PyUnicode_FromString(value));
        }

        void* fromString(const ::String& value) {
            if (value == null()) {
                return returnNoneHandle();
            }
            return asHandle(PyUnicode_FromString(value.c_str()));
        }

        void* bytesFromString(const char* value) {
            if (!value) {
                return returnNoneHandle();
            }
            return asHandle(PyBytes_FromStringAndSize(value, (Py_ssize_t)std::strlen(value)));
        }

        void* bytesFromString(const ::String& value) {
            if (value == null()) {
                return returnNoneHandle();
            }
            return asHandle(PyBytes_FromStringAndSize(value.c_str(), (Py_ssize_t)std::strlen(value.c_str())));
        }

        void* byteArrayFromString(const char* value) {
            if (!value) {
                return returnNoneHandle();
            }
            return asHandle(PyByteArray_FromStringAndSize(value, (Py_ssize_t)std::strlen(value)));
        }

        void* byteArrayFromString(const ::String& value) {
            if (value == null()) {
                return returnNoneHandle();
            }
            return asHandle(PyByteArray_FromStringAndSize(value.c_str(), (Py_ssize_t)std::strlen(value.c_str())));
        }

        void* memoryViewFromObject(void* obj) {
            PyObject* pyObj = asPyObject(obj);
            if (!pyObj) {
                return nullptr;
            }
            return asHandle(PyMemoryView_FromObject(pyObj));
        }

        void* fromBool(bool value) {
            return asHandle(PyBool_FromLong(value ? 1 : 0));
        }

        void* none() {
            return returnNoneHandle();
        }

        // Bytes operations
        int bytesSize(void* obj) {
            PyObject* pyObj = asPyObject(obj);
            if (!pyObj) {
                return 0;
            }

            if (PyBytes_Check(pyObj)) {
                return (int)PyBytes_Size(pyObj);
            }

            if (PyByteArray_Check(pyObj)) {
                return (int)PyByteArray_Size(pyObj);
            }

            if (PyMemoryView_Check(pyObj)) {
                return (int)PyObject_Size(pyObj);
            }

            PyObject* bytesObj = asBytesObject(pyObj);
            if (!bytesObj) {
                return 0;
            }

            int result = (int)PyBytes_Size(bytesObj);
            Py_DECREF(bytesObj);
            return result;
        }

        ::String bytesAsString(void* obj) {
            return bytesLikeToString(asPyObject(obj));
        }

        // List operations
        void* listNew() {
            return asHandle(PyList_New(0));
        }

        int listSize(void* list) {
            PyObject* pyList = asPyObject(list);
            if (!pyList || !PyList_Check(pyList)) {
                return 0;
            }
            return (int)PyList_Size(pyList);
        }

        void* listGetItem(void* list, int index) {
            PyObject* pyList = asPyObject(list);
            if (!pyList || !PyList_Check(pyList)) {
                return nullptr;
            }
            return asHandle(PyList_GetItem(pyList, (Py_ssize_t)index));
        }

        int listSetItem(void* list, int index, void* item) {
            PyObject* pyList = asPyObject(list);
            PyObject* pyItem = asPyObject(item);
            if (!pyList || !PyList_Check(pyList) || !pyItem) {
                return -1;
            }
            Py_INCREF(pyItem);
            int result = PyList_SetItem(pyList, (Py_ssize_t)index, pyItem);
            if (result != 0) {
                Py_DECREF(pyItem);
            }
            return result;
        }

        int listAppend(void* list, void* item) {
            PyObject* pyList = asPyObject(list);
            PyObject* pyItem = asPyObject(item);
            if (!pyList || !PyList_Check(pyList) || !pyItem) {
                return -1;
            }
            return PyList_Append(pyList, pyItem);
        }

        void* sequenceConcat(void* left, void* right) {
            PyObject* pyLeft = asPyObject(left);
            PyObject* pyRight = asPyObject(right);
            if (!pyLeft || !pyRight) {
                return nullptr;
            }
            return asHandle(PySequence_Concat(pyLeft, pyRight));
        }

        void* sequenceRepeat(void* obj, int count) {
            PyObject* pyObj = asPyObject(obj);
            if (!pyObj) {
                return nullptr;
            }
            return asHandle(PySequence_Repeat(pyObj, (Py_ssize_t)count));
        }

        // Slice operations
        void* sliceNew(int start, int stop, int step) {
            PyObject* startObj = PyLong_FromLong(start);
            PyObject* stopObj = PyLong_FromLong(stop);
            PyObject* stepObj = PyLong_FromLong(step);
            PyObject* result = PySlice_New(startObj, stopObj, stepObj);
            Py_DECREF(startObj);
            Py_DECREF(stopObj);
            Py_DECREF(stepObj);
            return asHandle(result);
        }

        void* getSlice(void* obj, int start, int stop) {
            PyObject* pyObj = asPyObject(obj);
            if (!pyObj) {
                return nullptr;
            }
            return asHandle(PySequence_GetSlice(pyObj, (Py_ssize_t)start, (Py_ssize_t)stop));
        }

        int setSlice(void* obj, int start, int stop, void* value) {
            PyObject* pyObj = asPyObject(obj);
            PyObject* pyValue = asPyObject(value);
            if (!pyObj || !pyValue) {
                return -1;
            }
            return PySequence_SetSlice(pyObj, (Py_ssize_t)start, (Py_ssize_t)stop, pyValue);
        }

        int delSlice(void* obj, int start, int stop) {
            PyObject* pyObj = asPyObject(obj);
            if (!pyObj) {
                return -1;
            }
            return PySequence_DelSlice(pyObj, (Py_ssize_t)start, (Py_ssize_t)stop);
        }

        // Set operations
        void* setNew() {
            return asHandle(PySet_New(nullptr));
        }

        int setSize(void* setObj) {
            PyObject* pySet = asPyObject(setObj);
            if (!pySet || !PySet_Check(pySet)) {
                return 0;
            }
            return (int)PySet_Size(pySet);
        }

        int setAdd(void* setObj, void* item) {
            PyObject* pySet = asPyObject(setObj);
            PyObject* pyItem = asPyObject(item);
            if (!pySet || !PySet_Check(pySet) || !pyItem) {
                return -1;
            }
            return PySet_Add(pySet, pyItem);
        }

        int setContains(void* setObj, void* item) {
            PyObject* pySet = asPyObject(setObj);
            PyObject* pyItem = asPyObject(item);
            if (!pySet || !PySet_Check(pySet) || !pyItem) {
                return 0;
            }
            return PySet_Contains(pySet, pyItem);
        }

        // Generic item operations
        void* getItem(void* obj, void* key) {
            PyObject* pyObj = asPyObject(obj);
            PyObject* pyKey = asPyObject(key);
            if (!pyObj || !pyKey) {
                return nullptr;
            }
            return asHandle(PyObject_GetItem(pyObj, pyKey));
        }

        int setItem(void* obj, void* key, void* value) {
            PyObject* pyObj = asPyObject(obj);
            PyObject* pyKey = asPyObject(key);
            PyObject* pyValue = asPyObject(value);
            if (!pyObj || !pyKey || !pyValue) {
                return -1;
            }
            return PyObject_SetItem(pyObj, pyKey, pyValue);
        }

        int delItem(void* obj, void* key) {
            PyObject* pyObj = asPyObject(obj);
            PyObject* pyKey = asPyObject(key);
            if (!pyObj || !pyKey) {
                return -1;
            }
            return PyObject_DelItem(pyObj, pyKey);
        }

        int contains(void* obj, void* key) {
            PyObject* pyObj = asPyObject(obj);
            PyObject* pyKey = asPyObject(key);
            if (!pyObj || !pyKey) {
                return 0;
            }
            return PySequence_Contains(pyObj, pyKey);
        }

        int objectSize(void* obj) {
            PyObject* pyObj = asPyObject(obj);
            if (!pyObj) {
                return 0;
            }
            return (int)PyObject_Size(pyObj);
        }

        // Dict operations
        void* dictNew() {
            return asHandle(PyDict_New());
        }

        int dictSize(void* dict) {
            PyObject* pyDict = asPyObject(dict);
            if (!pyDict || !PyDict_Check(pyDict)) {
                return 0;
            }
            return (int)PyDict_Size(pyDict);
        }

        void* dictGetItem(void* dict, void* key) {
            PyObject* pyDict = asPyObject(dict);
            PyObject* pyKey = asPyObject(key);
            if (!pyDict || !PyDict_Check(pyDict) || !pyKey) {
                return nullptr;
            }
            return asHandle(PyDict_GetItem(pyDict, pyKey));
        }

        void* dictGetItemString(void* dict, const char* key) {
            PyObject* pyDict = asPyObject(dict);
            if (!pyDict || !PyDict_Check(pyDict) || !key) {
                return nullptr;
            }
            return asHandle(PyDict_GetItemString(pyDict, key));
        }

        int dictSetItem(void* dict, void* key, void* value) {
            PyObject* pyDict = asPyObject(dict);
            PyObject* pyKey = asPyObject(key);
            PyObject* pyValue = asPyObject(value);
            if (!pyDict || !PyDict_Check(pyDict) || !pyKey || !pyValue) {
                return -1;
            }
            return PyDict_SetItem(pyDict, pyKey, pyValue);
        }

        int dictSetItemString(void* dict, const char* key, void* value) {
            PyObject* pyDict = asPyObject(dict);
            PyObject* pyValue = asPyObject(value);
            if (!pyDict || !PyDict_Check(pyDict) || !key || !pyValue) {
                return -1;
            }
            return PyDict_SetItemString(pyDict, key, pyValue);
        }

        int dictDelItem(void* dict, void* key) {
            PyObject* pyDict = asPyObject(dict);
            PyObject* pyKey = asPyObject(key);
            if (!pyDict || !PyDict_Check(pyDict) || !pyKey) {
                return -1;
            }
            return PyDict_DelItem(pyDict, pyKey);
        }

        int dictDelItemString(void* dict, const char* key) {
            PyObject* pyDict = asPyObject(dict);
            if (!pyDict || !PyDict_Check(pyDict) || !key) {
                return -1;
            }
            return PyDict_DelItemString(pyDict, key);
        }

        void* dictKeys(void* dict) {
            PyObject* pyDict = asPyObject(dict);
            if (!pyDict || !PyDict_Check(pyDict)) {
                return nullptr;
            }
            return asHandle(PyDict_Keys(pyDict));
        }

        void* dictValues(void* dict) {
            PyObject* pyDict = asPyObject(dict);
            if (!pyDict || !PyDict_Check(pyDict)) {
                return nullptr;
            }
            return asHandle(PyDict_Values(pyDict));
        }

        void* dictItems(void* dict) {
            PyObject* pyDict = asPyObject(dict);
            if (!pyDict || !PyDict_Check(pyDict)) {
                return nullptr;
            }
            return asHandle(PyDict_Items(pyDict));
        }

        // Tuple operations
        void* tupleNew(int size) {
            return asHandle(PyTuple_New((Py_ssize_t)size));
        }

        int tupleSize(void* tuple) {
            PyObject* pyTuple = asPyObject(tuple);
            if (!pyTuple || !PyTuple_Check(pyTuple)) {
                return 0;
            }
            return (int)PyTuple_Size(pyTuple);
        }

        void* tupleGetItem(void* tuple, int index) {
            PyObject* pyTuple = asPyObject(tuple);
            if (!pyTuple || !PyTuple_Check(pyTuple)) {
                return nullptr;
            }
            return asHandle(PyTuple_GetItem(pyTuple, (Py_ssize_t)index));
        }

        int tupleSetItem(void* tuple, int index, void* item) {
            PyObject* pyTuple = asPyObject(tuple);
            PyObject* pyItem = asPyObject(item);
            if (!pyTuple || !PyTuple_Check(pyTuple) || !pyItem) {
                return -1;
            }
            Py_INCREF(pyItem);
            int result = PyTuple_SetItem(pyTuple, (Py_ssize_t)index, pyItem);
            if (result != 0) {
                Py_DECREF(pyItem);
            }
            return result;
        }

        // Callable operations
        void* callFunction(void* callable, void* args) {
            PyObject* pyCallable = asPyObject(callable);
            PyObject* pyArgs = asPyObject(args);
            if (!pyCallable || !pyArgs) {
                return nullptr;
            }
            return asHandle(PyObject_CallObject(pyCallable, pyArgs));
        }

        void* callFunctionNoArgs(void* callable) {
            PyObject* pyCallable = asPyObject(callable);
            if (!pyCallable) {
                return nullptr;
            }
            return asHandle(PyObject_CallObject(pyCallable, nullptr));
        }

        void* callFunctionWithKeywords(void* callable, void* args, void* kwargs) {
            PyObject* pyCallable = asPyObject(callable);
            PyObject* pyArgs = asPyObject(args);
            PyObject* pyKwargs = asPyObject(kwargs);
            if (!pyCallable) {
                return nullptr;
            }

            bool ownsArgs = false;
            if (!pyArgs) {
                pyArgs = PyTuple_New(0);
                ownsArgs = true;
            }

            PyObject* result = PyObject_Call(pyCallable, pyArgs, pyKwargs);
            if (ownsArgs) {
                Py_DECREF(pyArgs);
            }
            return asHandle(result);
        }

        void* getBuiltin(const char* name) {
            if (!name) {
                return nullptr;
            }

            PyObject* builtinsModule = PyImport_ImportModule("builtins");
            if (!builtinsModule) {
                return nullptr;
            }

            PyObject* result = PyObject_GetAttrString(builtinsModule, name);
            Py_DECREF(builtinsModule);
            return asHandle(result);
        }

        void* callMethod(void* obj, const char* name, void* args) {
            PyObject* pyObj = asPyObject(obj);
            PyObject* pyArgs = asPyObject(args);
            if (!pyObj || !name || !pyArgs) {
                return nullptr;
            }

            PyObject* method = PyObject_GetAttrString(pyObj, name);
            if (!method) {
                return nullptr;
            }

            PyObject* result = PyObject_CallObject(method, pyArgs);
            Py_DECREF(method);
            return asHandle(result);
        }

        // Iterator operations
        void* getIter(void* obj) {
            PyObject* pyObj = asPyObject(obj);
            if (!pyObj) {
                return nullptr;
            }
            return asHandle(PyObject_GetIter(pyObj));
        }

        void* iterNext(void* iterObj) {
            PyObject* pyIter = asPyObject(iterObj);
            if (!pyIter) {
                return nullptr;
            }
            return asHandle(PyIter_Next(pyIter));
        }

        void* dir(void* obj) {
            PyObject* pyObj = asPyObject(obj);
            if (!pyObj) {
                return nullptr;
            }
            return asHandle(PyObject_Dir(pyObj));
        }

        void* callMethodNoArgs(void* obj, const char* name) {
            PyObject* pyObj = asPyObject(obj);
            if (!pyObj || !name) {
                return nullptr;
            }

            PyObject* method = PyObject_GetAttrString(pyObj, name);
            if (!method) {
                return nullptr;
            }

            PyObject* result = PyObject_CallObject(method, nullptr);
            Py_DECREF(method);
            return asHandle(result);
        }

        void* createHaxeCallback(int callbackId, const char* name) {
            HaxeCallbackInfo* info = new HaxeCallbackInfo();
            info->callbackId = callbackId;
            info->name = name ? name : "haxe_callback";
            info->def.ml_name = info->name.c_str();
            info->def.ml_meth = reinterpret_cast<PyCFunction>(invokeHaxeRegisteredCallback);
            info->def.ml_flags = METH_VARARGS | METH_KEYWORDS;
            info->def.ml_doc = "Haxe callback bridge";

            PyObject* capsule = PyCapsule_New(info, "linc_cpython.callback", destroyHaxeCallbackCapsule);
            if (!capsule) {
                delete info;
                return nullptr;
            }

            PyObject* callable = PyCFunction_NewEx(&info->def, capsule, nullptr);
            Py_DECREF(capsule);

            if (!callable) {
                return nullptr;
            }

            return asHandle(callable);
        }

        void* dynamicHandleToPyObject(::Dynamic value) {
            return value.mPtr ? value.mPtr->__GetHandle() : nullptr;
        }

        int compareEq(void* left, void* right) {
            return PyObject_RichCompareBool(asPyObject(left), asPyObject(right), Py_EQ);
        }

        int compareNe(void* left, void* right) {
            return PyObject_RichCompareBool(asPyObject(left), asPyObject(right), Py_NE);
        }

        int compareLt(void* left, void* right) {
            return PyObject_RichCompareBool(asPyObject(left), asPyObject(right), Py_LT);
        }

        int compareLe(void* left, void* right) {
            return PyObject_RichCompareBool(asPyObject(left), asPyObject(right), Py_LE);
        }

        int compareGt(void* left, void* right) {
            return PyObject_RichCompareBool(asPyObject(left), asPyObject(right), Py_GT);
        }

        int compareGe(void* left, void* right) {
            return PyObject_RichCompareBool(asPyObject(left), asPyObject(right), Py_GE);
        }

        int isInstance(void* obj, void* cls) {
            PyObject* pyObj = asPyObject(obj);
            PyObject* pyCls = asPyObject(cls);
            if (!pyObj || !pyCls) {
                return 0;
            }
            return PyObject_IsInstance(pyObj, pyCls);
        }

        int isSubclass(void* derived, void* cls) {
            PyObject* pyDerived = asPyObject(derived);
            PyObject* pyCls = asPyObject(cls);
            if (!pyDerived || !pyCls) {
                return 0;
            }
            return PyObject_IsSubclass(pyDerived, pyCls);
        }

        int hashObject(void* obj) {
            PyObject* pyObj = asPyObject(obj);
            if (!pyObj) {
                return 0;
            }
            return (int)PyObject_Hash(pyObj);
        }

        // Attribute access
        void* getAttr(void* obj, const char* name) {
            PyObject* pyObj = asPyObject(obj);
            if (!pyObj || !name) {
                return nullptr;
            }
            return asHandle(PyObject_GetAttrString(pyObj, name));
        }

        int setAttr(void* obj, const char* name, void* value) {
            PyObject* pyObj = asPyObject(obj);
            PyObject* pyValue = asPyObject(value);
            if (!pyObj || !name || !pyValue) {
                return -1;
            }
            return PyObject_SetAttrString(pyObj, name, pyValue);
        }

        int delAttr(void* obj, const char* name) {
            PyObject* pyObj = asPyObject(obj);
            if (!pyObj || !name) {
                return -1;
            }
            return PyObject_DelAttrString(pyObj, name);
        }

        int hasAttr(void* obj, const char* name) {
            PyObject* pyObj = asPyObject(obj);
            if (!pyObj || !name) {
                return 0;
            }
            return PyObject_HasAttrString(pyObj, name);
        }

        // Context manager operations
        void* enterContext(void* obj) {
            PyObject* pyObj = asPyObject(obj);
            if (!pyObj) {
                return nullptr;
            }

            PyObject* enterFn = PyObject_GetAttrString(pyObj, "__enter__");
            if (!enterFn) {
                return nullptr;
            }

            PyObject* result = PyObject_CallObject(enterFn, nullptr);
            Py_DECREF(enterFn);
            return asHandle(result);
        }

        int exitContext(void* obj, void* excType, void* excValue, void* traceback) {
            PyObject* pyObj = asPyObject(obj);
            if (!pyObj) {
                return 0;
            }

            PyObject* exitFn = PyObject_GetAttrString(pyObj, "__exit__");
            if (!exitFn) {
                return 0;
            }

            PyObject* args = PyTuple_New(3);
            PyObject* typeObj = asPyObject(excType);
            PyObject* valueObj = asPyObject(excValue);
            PyObject* tracebackObj = asPyObject(traceback);

            if (!typeObj) typeObj = Py_None;
            if (!valueObj) valueObj = Py_None;
            if (!tracebackObj) tracebackObj = Py_None;

            Py_INCREF(typeObj);
            Py_INCREF(valueObj);
            Py_INCREF(tracebackObj);
            PyTuple_SetItem(args, 0, typeObj);
            PyTuple_SetItem(args, 1, valueObj);
            PyTuple_SetItem(args, 2, tracebackObj);

            PyObject* result = PyObject_CallObject(exitFn, args);
            Py_DECREF(args);
            Py_DECREF(exitFn);

            if (!result) {
                return 0;
            }

            int handled = PyObject_IsTrue(result);
            Py_DECREF(result);
            return handled == 1 ? 1 : 0;
        }

        // Error handling
        void clearError() {
            PyErr_Clear();
        }

        bool hasError() {
            return PyErr_Occurred() != nullptr;
        }

        ::String getErrorString() {
            PyObject* ptype = nullptr;
            PyObject* pvalue = nullptr;
            PyObject* ptraceback = nullptr;
            PyErr_Fetch(&ptype, &pvalue, &ptraceback);

            if (!ptype && !pvalue && !ptraceback) {
                return ::String("No error");
            }

            ::String result = pvalue ? stringFromPyTextObject(pvalue) : stringFromPyTextObject(ptype);

            Py_XDECREF(ptype);
            Py_XDECREF(pvalue);
            Py_XDECREF(ptraceback);
            return result != null() ? result : ::String("Unknown error");
        }

        ::String getErrorTraceback() {
            PyObject* ptype = nullptr;
            PyObject* pvalue = nullptr;
            PyObject* ptraceback = nullptr;
            PyErr_Fetch(&ptype, &pvalue, &ptraceback);
            return formatFetchedError(ptype, pvalue, ptraceback);
        }

        // Eval and exec
        void* evalString(const char* expression) {
            if (!expression) {
                return nullptr;
            }

            PyObject* globals = getMainGlobals();
            if (!globals) {
                return nullptr;
            }

            return asHandle(PyRun_String(expression, Py_eval_input, globals, globals));
        }

        void* execString(const char* command) {
            if (!command) {
                return nullptr;
            }

            PyObject* globals = getMainGlobals();
            if (!globals) {
                return nullptr;
            }

            return asHandle(PyRun_String(command, Py_file_input, globals, globals));
        }

        void* runSimpleString(const char* command) {
            if (!command) {
                return nullptr;
            }
            int result = PyRun_SimpleString(command);
            if (result == 0) {
                return returnNoneHandle();
            }
            return nullptr;
        }

        void* runFile(const char* filename) {
            if (!filename) {
                return nullptr;
            }

            std::ifstream file(filename, std::ios::binary);
            if (!file.is_open()) {
                return nullptr;
            }

            std::ostringstream buffer;
            buffer << file.rdbuf();
            std::string source = buffer.str();
            return execString(source.c_str());
        }

        // Helper for creating args tuple
        void* createArgs(int count, void** items) {
            PyObject* tuple = PyTuple_New((Py_ssize_t)count);
            if (!tuple) {
                return nullptr;
            }

            for (int i = 0; i < count; i++) {
                PyObject* item = items ? asPyObject(items[i]) : nullptr;
                if (!item) {
                    item = Py_None;
                }
                Py_INCREF(item);
                PyTuple_SetItem(tuple, i, item);
            }

            return asHandle(tuple);
        }

    } // cpython namespace

} // linc
