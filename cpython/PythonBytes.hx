package cpython;

import haxe.io.Bytes;

class PythonBytes {
    public static function fromString(value:String):PyObject {
        return Python.bytesFromString(value);
    }

    public static function fromBytes(bytes:Bytes):PyObject {
        return Python.bytesFromString(bytes.toString());
    }

    public static function byteArrayFromString(value:String):PyObject {
        return Python.byteArrayFromString(value);
    }

    public static function toString(obj:PyObject):String {
        return Python.bytesAsString(obj);
    }

    public static function toBytes(obj:PyObject):Bytes {
        return Bytes.ofString(toString(obj));
    }

    public static function size(obj:PyObject):Int {
        return Python.bytesSize(obj);
    }

    public static function memoryView(obj:PyObject):PyObject {
        return Python.memoryViewFromObject(obj);
    }

    public static function isBytesLike(obj:PyObject):Bool {
        return Python.isBytes(obj) || Python.isByteArray(obj) || Python.isMemoryView(obj);
    }
}
