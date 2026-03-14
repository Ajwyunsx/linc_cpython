package cpython;

class PythonModules {
    public static function isLoaded(name:String):Bool {
        return Python.dictGetItemString(Python.getSysModules(), name) != null;
    }

    public static function getLoaded(name:String):PyObject {
        var module = Python.dictGetItemString(Python.getSysModules(), name);
        if (module != null) {
            Python.incref(module);
        }
        return module;
    }

    public static function unload(name:String):Bool {
        if (!isLoaded(name)) {
            return false;
        }
        return Python.dictDelItemString(Python.getSysModules(), name) == 0;
    }

    public static function importModule(name:String):PyObject {
        PythonConfig.ensureInitialized();
        return Python.importModule(name);
    }

    public static function require(name:String):PyObject {
        var module = importModule(name);
        if (module == null) {
            throw PythonException.fromCurrentError('import failed for ' + name);
        }
        return module;
    }

    public static function reload(module:PyObject):PyObject {
        var result = Python.reloadModule(module);
        if (result == null) {
            throw PythonException.fromCurrentError('reload failed');
        }
        return result;
    }

    public static function reloadByName(name:String):PyObject {
        var loaded = getLoaded(name);
        if (loaded == null) {
            return require(name);
        }

        try {
            var result = reload(loaded);
            Python.decref(loaded);
            return result;
        } catch (e) {
            Python.decref(loaded);
            throw e;
        }
    }

    public static function invalidateCaches():Void {
        var importlib = require('importlib');
        var invalidate = Python.getAttr(importlib, 'invalidate_caches');
        if (invalidate == null) {
            Python.decref(importlib);
            throw PythonException.fromCurrentError('invalidate_caches not found');
        }

        try {
            var result = PythonRun.call(invalidate);
            Python.decref(result);
            Python.decref(invalidate);
            Python.decref(importlib);
        } catch (e) {
            Python.decref(invalidate);
            Python.decref(importlib);
            throw e;
        }
    }
}
