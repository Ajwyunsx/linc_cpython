package cpython;

class PythonException extends haxe.Exception {
    public var tracebackText(default, null):String;

    public function new(message:String, ?tracebackText:String, ?previous:Dynamic, ?native:Dynamic) {
        super(message, previous, native);
        this.tracebackText = tracebackText;
    }

    public static function fromCurrentError(?prefix:String):PythonException {
        var traceback = Python.getErrorTraceback();
        var message = traceback;
        if (prefix != null && prefix.length > 0) {
            message = prefix + ": " + message;
        }
        return new PythonException(message, traceback);
    }
}
