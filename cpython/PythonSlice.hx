package cpython;

class PythonSlice {
    public static function create(start:Int, stop:Int, ?step:Int = 1):PyObject {
        return Python.sliceNew(start, stop, step);
    }

    public static function get(obj:PyObject, start:Int, stop:Int):PyObject {
        var result = Python.getSlice(obj, start, stop);
        if (result == null) {
            throw PythonException.fromCurrentError('getSlice failed');
        }
        return result;
    }

    public static function replace(obj:PyObject, start:Int, stop:Int, value:Dynamic):Void {
        var pyValue = Convert.fromDynamic(value);
        var result = Python.setSlice(obj, start, stop, pyValue);
        Python.decref(pyValue);

        if (result != 0) {
            throw PythonException.fromCurrentError('setSlice failed');
        }
    }

    public static function deleteRange(obj:PyObject, start:Int, stop:Int):Void {
        if (Python.delSlice(obj, start, stop) != 0) {
            throw PythonException.fromCurrentError('delSlice failed');
        }
    }
}
