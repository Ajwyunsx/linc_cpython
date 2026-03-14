package cpython;

class PythonCompare {
    public static function eq(left:PyObject, right:PyObject):Bool {
        return Python.compareEq(left, right);
    }

    public static function ne(left:PyObject, right:PyObject):Bool {
        return Python.compareNe(left, right);
    }

    public static function lt(left:PyObject, right:PyObject):Bool {
        return Python.compareLt(left, right);
    }

    public static function le(left:PyObject, right:PyObject):Bool {
        return Python.compareLe(left, right);
    }

    public static function gt(left:PyObject, right:PyObject):Bool {
        return Python.compareGt(left, right);
    }

    public static function ge(left:PyObject, right:PyObject):Bool {
        return Python.compareGe(left, right);
    }

    public static function isInstance(obj:PyObject, cls:PyObject):Bool {
        return Python.isInstance(obj, cls);
    }

    public static function isSubclass(derived:PyObject, cls:PyObject):Bool {
        return Python.isSubclass(derived, cls);
    }

    public static function hash(obj:PyObject):Int {
        return Python.hashObject(obj);
    }
}
