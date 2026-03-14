package cpython;

class PythonBuiltins {
    public static function get(name:String):PyObject {
        PythonConfig.ensureInitialized();
        return Python.getBuiltin(name);
    }

    public static function getOrThrow(name:String):PyObject {
        var builtin = get(name);
        if (builtin == null) {
            throw new PythonException('builtin not found: ' + name);
        }
        return builtin;
    }

    public static function len(obj:PyObject):Int {
        return Python.objectSize(obj);
    }

    public static function contains(obj:PyObject, key:PyObject):Bool {
        return Python.contains(obj, key);
    }

    public static function typeName(obj:PyObject):String {
        return Python.typeName(obj);
    }

    public static function dirStrings(obj:PyObject):Array<String> {
        var dirList = Python.dir(obj);
        if (dirList == null) {
            throw PythonException.fromCurrentError('dir failed');
        }

        var values = PythonIter.toStringArray(dirList);
        Python.decref(dirList);
        return values;
    }

    public static function call(name:String, ?args:PyObject, ?kwargs:PyObject):PyObject {
        var builtin = getOrThrow(name);
        var result = PythonRun.call(builtin, args, kwargs);
        Python.decref(builtin);
        return result;
    }
}
