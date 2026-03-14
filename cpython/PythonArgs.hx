package cpython;

class PythonArgs {
    public static function empty():PyObject {
        return Python.tupleNew(0);
    }

    public static function fromPyObjects(values:Array<Dynamic>):PyObject {
        var tuple = Python.tupleNew(values.length);
        for (i in 0...values.length) {
            var value = Python.dynamicHandleToPyObject(values[i]);
            Python.tupleSetItem(tuple, i, value);
        }
        return tuple;
    }

    public static function fromArray(values:Array<Dynamic>):PyObject {
        var tuple = Python.tupleNew(values.length);
        for (i in 0...values.length) {
            var pyValue = Convert.fromDynamic(values[i]);
            Python.tupleSetItem(tuple, i, pyValue);
            Python.decref(pyValue);
        }
        return tuple;
    }
}
