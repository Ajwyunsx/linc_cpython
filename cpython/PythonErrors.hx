package cpython;

class PythonErrors {
    public static function hasError():Bool {
        return Python.hasError();
    }

    public static function clear():Void {
        Python.clearError();
    }

    public static function message():String {
        return Python.getErrorString();
    }

    public static function traceback():String {
        return Python.getErrorTraceback();
    }

    public static function throwCurrent(?prefix:String):Void {
        throw PythonException.fromCurrentError(prefix);
    }
}
