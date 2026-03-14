package cpython;

class PythonSequence {
    public static function concat(left:PyObject, right:PyObject):PyObject {
        var result = Python.sequenceConcat(left, right);
        if (result == null) {
            throw PythonException.fromCurrentError('sequence concat failed');
        }
        return result;
    }

    public static function repeat(obj:PyObject, count:Int):PyObject {
        var result = Python.sequenceRepeat(obj, count);
        if (result == null) {
            throw PythonException.fromCurrentError('sequence repeat failed');
        }
        return result;
    }

    public static function concatDynamic(left:Dynamic, right:Dynamic):Array<Dynamic> {
        var pyLeft = Convert.fromDynamic(left);
        var pyRight = Convert.fromDynamic(right);
        var result = concat(pyLeft, pyRight);
        var values:Array<Dynamic> = cast Convert.toDynamic(result);
        Python.decref(result);
        Python.decref(pyLeft);
        Python.decref(pyRight);
        return values;
    }

    public static function repeatDynamic(value:Dynamic, count:Int):Array<Dynamic> {
        var pyValue = Convert.fromDynamic(value);
        var result = repeat(pyValue, count);
        var values:Array<Dynamic> = cast Convert.toDynamic(result);
        Python.decref(result);
        Python.decref(pyValue);
        return values;
    }
}
