package cpython;

class PythonRun {
    public static function eval(code:String):PyObject {
        PythonConfig.ensureInitialized();
        var result = Python.evalString(code);
        if (result == null) {
            throw PythonException.fromCurrentError('eval failed');
        }
        return result;
    }

    public static function exec(code:String):PyObject {
        PythonConfig.ensureInitialized();
        var result = Python.execString(code);
        if (result == null) {
            throw PythonException.fromCurrentError('exec failed');
        }
        return result;
    }

    public static function runFile(path:String):PyObject {
        PythonConfig.ensureInitialized();
        var result = Python.runFile(path);
        if (result == null) {
            throw PythonException.fromCurrentError('runFile failed for ' + path);
        }
        return result;
    }

    public static function call(callable:PyObject, ?args:PyObject, ?kwargs:PyObject):PyObject {
        var result = kwargs != null
            ? Python.callFunctionWithKeywords(callable, args, kwargs)
            : (args != null ? Python.callFunction(callable, args) : Python.callFunctionNoArgs(callable));

        if (result == null) {
            throw PythonException.fromCurrentError('call failed');
        }
        return result;
    }

    public static function callMethod(obj:PyObject, name:String, ?args:PyObject):PyObject {
        var result = args != null ? Python.callMethod(obj, name, args) : Python.callMethodNoArgs(obj, name);
        if (result == null) {
            throw PythonException.fromCurrentError('callMethod failed for ' + name);
        }
        return result;
    }
}
