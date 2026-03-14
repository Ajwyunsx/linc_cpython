package cpython;

import haxe.ds.StringMap;

class PythonKwargs {
    public static function create():PyObject {
        return Python.dictNew();
    }

    public static function set(kwargs:PyObject, key:String, value:Dynamic):Void {
        var pyValue = Convert.fromDynamic(value);
        var result = Python.dictSetItemString(kwargs, key, pyValue);
        Python.decref(pyValue);

        if (result != 0) {
            throw PythonException.fromCurrentError('kwargs set failed for ' + key);
        }
    }

    public static function setPyObject(kwargs:PyObject, key:String, value:PyObject):Void {
        if (Python.dictSetItemString(kwargs, key, value) != 0) {
            throw PythonException.fromCurrentError('kwargs setPyObject failed for ' + key);
        }
    }

    public static function fromDynamic(value:Dynamic):PyObject {
        var kwargs = create();

        if (value == null) {
            return kwargs;
        }

        if (Std.isOfType(value, StringMap)) {
            var map:StringMap<Dynamic> = cast value;
            for (key in map.keys()) {
                set(kwargs, key, map.get(key));
            }
            return kwargs;
        }

        for (field in Reflect.fields(value)) {
            set(kwargs, field, Reflect.field(value, field));
        }

        return kwargs;
    }
}
