package cpython;

class PythonObjects {
    public static function construct(typeObj:PyObject, ?args:Array<Dynamic>, ?kwargs:Dynamic):PyObject {
        var pyArgs = args != null ? PythonArgs.fromArray(args) : null;
        var pyKwargs = kwargs != null ? PythonKwargs.fromDynamic(kwargs) : null;

        try {
            var result = PythonRun.call(typeObj, pyArgs, pyKwargs);
            if (pyArgs != null) {
                Python.decref(pyArgs);
            }
            if (pyKwargs != null) {
                Python.decref(pyKwargs);
            }
            return result;
        } catch (e) {
            if (pyArgs != null) {
                Python.decref(pyArgs);
            }
            if (pyKwargs != null) {
                Python.decref(pyKwargs);
            }
            throw e;
        }
    }

    public static function constructFromModule(module:PyObject, name:String, ?args:Array<Dynamic>, ?kwargs:Dynamic):PyObject {
        var ctor = Python.getAttr(module, name);
        if (ctor == null) {
            throw PythonException.fromCurrentError('constructor not found: ' + name);
        }

        try {
            var result = construct(ctor, args, kwargs);
            Python.decref(ctor);
            return result;
        } catch (e) {
            Python.decref(ctor);
            throw e;
        }
    }

    public static function callAttr(obj:PyObject, name:String, ?args:Array<Dynamic>, ?kwargs:Dynamic):PyObject {
        var callable = Python.getAttr(obj, name);
        if (callable == null) {
            throw PythonException.fromCurrentError('attribute not found: ' + name);
        }

        var pyArgs = args != null ? PythonArgs.fromArray(args) : null;
        var pyKwargs = kwargs != null ? PythonKwargs.fromDynamic(kwargs) : null;

        try {
            var result = PythonRun.call(callable, pyArgs, pyKwargs);
            if (pyArgs != null) {
                Python.decref(pyArgs);
            }
            if (pyKwargs != null) {
                Python.decref(pyKwargs);
            }
            Python.decref(callable);
            return result;
        } catch (e) {
            if (pyArgs != null) {
                Python.decref(pyArgs);
            }
            if (pyKwargs != null) {
                Python.decref(pyKwargs);
            }
            Python.decref(callable);
            throw e;
        }
    }
}
