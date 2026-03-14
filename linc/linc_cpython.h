#pragma once

// hxcpp include should always be first
#ifndef HXCPP_H
#include <hxcpp.h>
#endif

// Python C API includes
#include <Python.h>

namespace linc {

    namespace cpython {

        // Python interpreter lifecycle
        extern void initialize();
        extern void finalize();
        extern bool isInitialized();
        extern void* getMainModule();
        extern void* getMainDict();
        extern void* getBuiltins();
        extern void* getSysModules();

        // Module and import
        extern void* importModule(const char* name);
        extern void* reloadModule(void* module);
        extern void* getModuleDict(void* module);
        extern int appendSysPath(const char* path);
        extern int insertSysPath(int index, const char* path);

        // Object reference counting
        extern void incref(void* obj);
        extern void decref(void* obj);
        extern int getRefCount(void* obj);

        // Type checking
        extern bool isNone(void* obj);
        extern bool isBool(void* obj);
        extern bool isInt(void* obj);
        extern bool isFloat(void* obj);
        extern bool isString(void* obj);
        extern bool isBytes(void* obj);
        extern bool isByteArray(void* obj);
        extern bool isMemoryView(void* obj);
        extern bool isList(void* obj);
        extern bool isDict(void* obj);
        extern bool isTuple(void* obj);
        extern bool isSlice(void* obj);
        extern bool isSet(void* obj);
        extern bool isCallable(void* obj);
        extern bool isModule(void* obj);

        // Conversions from Python to C++
        extern int toInt(void* obj);
        extern double toFloat(void* obj);
        extern ::String toString(void* obj);
        extern ::String repr(void* obj);
        extern ::String typeName(void* obj);
        extern bool toBool(void* obj);

        // Conversions from C++ to Python
        extern void* fromInt(int value);
        extern void* fromFloat(double value);
        extern void* fromString(const char* value);
        extern void* fromString(const ::String& value);
        extern void* bytesFromString(const char* value);
        extern void* bytesFromString(const ::String& value);
        extern void* byteArrayFromString(const char* value);
        extern void* byteArrayFromString(const ::String& value);
        extern void* memoryViewFromObject(void* obj);
        extern void* fromBool(bool value);
        extern void* none();

        // Bytes operations
        extern int bytesSize(void* obj);
        extern ::String bytesAsString(void* obj);

        // List operations
        extern void* listNew();
        extern int listSize(void* list);
        extern void* listGetItem(void* list, int index);
        extern int listSetItem(void* list, int index, void* item);
        extern int listAppend(void* list, void* item);
        extern void* sequenceConcat(void* left, void* right);
        extern void* sequenceRepeat(void* obj, int count);

        // Slice operations
        extern void* sliceNew(int start, int stop, int step);
        extern void* getSlice(void* obj, int start, int stop);
        extern int setSlice(void* obj, int start, int stop, void* value);
        extern int delSlice(void* obj, int start, int stop);

        // Set operations
        extern void* setNew();
        extern int setSize(void* setObj);
        extern int setAdd(void* setObj, void* item);
        extern int setContains(void* setObj, void* item);

        // Generic item operations
        extern void* getItem(void* obj, void* key);
        extern int setItem(void* obj, void* key, void* value);
        extern int delItem(void* obj, void* key);
        extern int contains(void* obj, void* key);
        extern int objectSize(void* obj);

        // Dict operations
        extern void* dictNew();
        extern int dictSize(void* dict);
        extern void* dictGetItem(void* dict, void* key);
        extern void* dictGetItemString(void* dict, const char* key);
        extern int dictSetItem(void* dict, void* key, void* value);
        extern int dictSetItemString(void* dict, const char* key, void* value);
        extern int dictDelItem(void* dict, void* key);
        extern int dictDelItemString(void* dict, const char* key);
        extern void* dictKeys(void* dict);
        extern void* dictValues(void* dict);
        extern void* dictItems(void* dict);

        // Tuple operations
        extern void* tupleNew(int size);
        extern int tupleSize(void* tuple);
        extern void* tupleGetItem(void* tuple, int index);
        extern int tupleSetItem(void* tuple, int index, void* item);

        // Callable operations
        extern void* callFunction(void* callable, void* args);
        extern void* callFunctionNoArgs(void* callable);
        extern void* callFunctionWithKeywords(void* callable, void* args, void* kwargs);
        extern void* getBuiltin(const char* name);
        extern void* callMethod(void* obj, const char* name, void* args);
        extern void* callMethodNoArgs(void* obj, const char* name);
        extern void* createHaxeCallback(int callbackId, const char* name);
        extern void* dynamicHandleToPyObject(::Dynamic value);

        // Comparison and protocol helpers
        extern int compareEq(void* left, void* right);
        extern int compareNe(void* left, void* right);
        extern int compareLt(void* left, void* right);
        extern int compareLe(void* left, void* right);
        extern int compareGt(void* left, void* right);
        extern int compareGe(void* left, void* right);
        extern int isInstance(void* obj, void* cls);
        extern int isSubclass(void* derived, void* cls);
        extern int hashObject(void* obj);

        // Iterator operations
        extern void* getIter(void* obj);
        extern void* iterNext(void* iterObj);
        extern void* dir(void* obj);

        // Attribute access
        extern void* getAttr(void* obj, const char* name);
        extern int setAttr(void* obj, const char* name, void* value);
        extern int delAttr(void* obj, const char* name);
        extern int hasAttr(void* obj, const char* name);

        // Context manager operations
        extern void* enterContext(void* obj);
        extern int exitContext(void* obj, void* excType, void* excValue, void* traceback);

        // Error handling
        extern void clearError();
        extern bool hasError();
        extern ::String getErrorString();
        extern ::String getErrorTraceback();

        // Eval and exec
        extern void* evalString(const char* expression);
        extern void* execString(const char* command);
        extern void* runSimpleString(const char* command);
        extern void* runFile(const char* filename);

        // Helper for creating args tuple
        extern void* createArgs(int count, void** items);

    } // cpython namespace

} // linc
