package cpython;

/**
 * Opaque type representing a Python PyObject*
 * This is a pointer to a Python object in the CPython runtime
 */
typedef PyObject = cpp.RawPointer<cpp.Void>;

typedef PyObjectHandle = PyObject;
