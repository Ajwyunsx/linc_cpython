package cpython;

class PythonDelete {
    public static function item(obj:PyObject, key:Dynamic):Void {
        var pyKey = Convert.fromDynamic(key);
        var result = Python.delItem(obj, pyKey);
        Python.decref(pyKey);

        if (result != 0) {
            throw PythonException.fromCurrentError('delItem failed');
        }
    }

    public static function dictKeyString(dict:PyObject, key:String):Void {
        if (Python.dictDelItemString(dict, key) != 0) {
            throw PythonException.fromCurrentError('dictDelItemString failed for ' + key);
        }
    }

    public static function attr(obj:PyObject, name:String):Void {
        if (Python.delAttr(obj, name) != 0) {
            throw PythonException.fromCurrentError('delAttr failed for ' + name);
        }
    }
}
