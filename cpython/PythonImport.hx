package cpython;

class PythonImport {
    static var configuredPaths:Array<String> = [];

    public static function init(?basePaths:Array<String>):Void {
        PythonConfig.ensureInitialized();
        if (basePaths == null) {
            basePaths = ['./', './modules', './scripts'];
        }
        addPaths(basePaths);
    }

    public static function addPath(path:String):Void {
        if (configuredPaths.indexOf(path) == -1) {
            PythonConfig.appendSearchPath(path);
            configuredPaths.push(path);
        }
    }

    public static function addPaths(paths:Array<String>):Void {
        for (path in paths) {
            addPath(path);
        }
    }

    public static function importModule(name:String):PyObject {
        PythonConfig.ensureInitialized();
        return Python.importModule(name);
    }

    public static function importOrThrow(name:String):PyObject {
        var module = importModule(name);
        if (module == null) {
            throw PythonException.fromCurrentError('import failed for ' + name);
        }
        return module;
    }

    public static function importFromPath(name:String, path:String):PyObject {
        addPath(path);
        return importModule(name);
    }

    public static function require(name:String):PyObject {
        return importOrThrow(name);
    }
}
