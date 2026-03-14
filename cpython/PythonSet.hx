package cpython;

class PythonSet {
    public static function create():PyObject {
        return Python.setNew();
    }

    public static function fromArray(values:Array<Dynamic>):PyObject {
        var setObj = create();
        for (value in values) {
            var pyValue = Convert.fromDynamic(value);
            Python.setAdd(setObj, pyValue);
            Python.decref(pyValue);
        }
        return setObj;
    }

    public static function size(setObj:PyObject):Int {
        return Python.setSize(setObj);
    }

    public static function containsDynamic(setObj:PyObject, value:Dynamic):Bool {
        var pyValue = Convert.fromDynamic(value);
        var result = Python.setContains(setObj, pyValue);
        Python.decref(pyValue);
        return result;
    }

    public static function toDynamicArray(setObj:PyObject):Array<Dynamic> {
        return PythonIter.toDynamicArray(setObj);
    }
}
