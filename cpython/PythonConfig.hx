package cpython;

class PythonConfig {
    public static function ensureInitialized():Void {
        if (!Python.isInitialized()) {
            Python.initialize();
        }
    }

    public static function init(?searchPaths:Array<String>):Void {
        ensureInitialized();
        if (searchPaths != null) {
            appendSearchPaths(searchPaths);
        }
    }

    public static function shutdown():Void {
        if (Python.isInitialized()) {
            Python.finalize();
        }
    }

    public static function appendSearchPath(path:String):Void {
        ensureInitialized();
        if (Python.appendSysPath(path) != 0) {
            throw PythonException.fromCurrentError('appendSearchPath failed for ' + path);
        }
    }

    public static function insertSearchPath(index:Int, path:String):Void {
        ensureInitialized();
        if (Python.insertSysPath(index, path) != 0) {
            throw PythonException.fromCurrentError('insertSearchPath failed for ' + path);
        }
    }

    public static function appendSearchPaths(paths:Array<String>):Void {
        for (path in paths) {
            appendSearchPath(path);
        }
    }
}
