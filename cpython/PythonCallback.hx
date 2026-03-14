package cpython;

private interface IPythonRawCallback {
    public function invoke(args:PyObject, kwargs:PyObject):PyObject;
}

private class FunctionPythonRawCallback implements IPythonRawCallback {
    var callback:Dynamic;

    public function new(callback:PythonRawCallback) {
        this.callback = callback;
    }

    public function invoke(args:PyObject, kwargs:PyObject):PyObject {
        var result:Dynamic = Reflect.callMethod(null, callback, [args, kwargs]);
        return result != null ? Python.dynamicHandleToPyObject(result) : Python.none();
    }
}

private class FunctionPythonDynamicCallback implements IPythonRawCallback {
    var callback:PythonDynamicCallback;

    public function new(callback:PythonDynamicCallback) {
        this.callback = callback;
    }

    public function invoke(args:PyObject, kwargs:PyObject):PyObject {
        var dynamicArgs:Dynamic = args != null ? Convert.toDynamic(args) : [];
        var dynamicKwargs:Dynamic = kwargs != null ? Convert.toDynamic(kwargs) : null;
        return Convert.fromDynamic(callback(dynamicArgs, dynamicKwargs));
    }
}

typedef PythonRawCallback = Dynamic;
typedef PythonDynamicCallback = Dynamic->Dynamic->Dynamic;

class PythonCallback {
    static var nextId:Int = 1;
    static var registered:Array<IPythonRawCallback> = [];

    public static function releaseRegistered(id:Int):Void {
        if (id >= 0 && id < registered.length) {
            registered[id] = null;
        }
    }

    public static function invokeRegistered(id:Int, args:PyObject, kwargs:PyObject):PyObject {
        var callback = id >= 0 && id < registered.length ? registered[id] : null;
        if (callback == null) {
            throw new PythonException('No Haxe callback registered for id ' + id);
        }

        var result = callback.invoke(args, kwargs);
        return result != null ? result : Python.none();
    }

    public static function createRaw(callback:PythonRawCallback, ?name:String = 'haxe_callback'):PyObject {
        var id = nextId++;
        registered[id] = new FunctionPythonRawCallback(callback);

        var callable = Python.createHaxeCallback(id, name);
        if (callable == null) {
            releaseRegistered(id);
            throw PythonException.fromCurrentError('createHaxeCallback failed for ' + name);
        }

        return callable;
    }

    public static function createDynamic(callback:PythonDynamicCallback, ?name:String = 'haxe_callback'):PyObject {
        var id = nextId++;
        registered[id] = new FunctionPythonDynamicCallback(callback);

        var callable = Python.createHaxeCallback(id, name);
        if (callable == null) {
            releaseRegistered(id);
            throw PythonException.fromCurrentError('createHaxeCallback failed for ' + name);
        }

        return callable;
    }

    public static function publishRaw(name:String, callback:PythonRawCallback, ?targetDict:PyObject):PyObject {
        var callable = createRaw(callback, name);
        if (targetDict == null) {
            targetDict = Python.getMainDict();
        }

        if (Python.dictSetItemString(targetDict, name, callable) != 0) {
            Python.decref(callable);
            throw PythonException.fromCurrentError('publishRaw failed for ' + name);
        }

        return callable;
    }

    public static function publishDynamic(name:String, callback:PythonDynamicCallback, ?targetDict:PyObject):PyObject {
        var callable = createDynamic(callback, name);
        if (targetDict == null) {
            targetDict = Python.getMainDict();
        }

        if (Python.dictSetItemString(targetDict, name, callable) != 0) {
            Python.decref(callable);
            throw PythonException.fromCurrentError('publishDynamic failed for ' + name);
        }

        return callable;
    }
}
