package cpython;

class PythonIter {
    public static function nextObjectOrNull(iter:PyObject):PyObject {
        var next = Python.iterNext(iter);
        if (next == null && Python.hasError()) {
            throw PythonException.fromCurrentError('iterNext failed');
        }
        return next;
    }

    public static function toDynamicArray(obj:PyObject):Array<Dynamic> {
        PythonConfig.ensureInitialized();

        var iter = Python.getIter(obj);
        if (iter == null) {
            throw PythonException.fromCurrentError('getIter failed');
        }

        var result:Array<Dynamic> = [];

        while (true) {
            var next = nextObjectOrNull(iter);
            if (next == null) {
                break;
            }

            result.push(Convert.toDynamic(next));
            Python.decref(next);
        }

        Python.decref(iter);
        return result;
    }

    public static function toStringArray(obj:PyObject):Array<String> {
        PythonConfig.ensureInitialized();

        var iter = Python.getIter(obj);
        if (iter == null) {
            throw PythonException.fromCurrentError('getIter failed');
        }

        var result:Array<String> = [];

        while (true) {
            var next = nextObjectOrNull(iter);
            if (next == null) {
                break;
            }

            result.push(Python.toString(next));
            Python.decref(next);
        }

        Python.decref(iter);
        return result;
    }
}
