package cpython;

import haxe.io.Bytes;
import haxe.ds.StringMap;

class Convert {
    public static function fromDynamic(value:Dynamic):PyObject {
        if (value == null) {
            return Python.none();
        }

        if (Std.isOfType(value, Bool)) {
            return Python.fromBool(value);
        }

        if (Std.isOfType(value, Int)) {
            return Python.fromInt(value);
        }

        if (Std.isOfType(value, Float)) {
            return Python.fromFloat(value);
        }

        if (Std.isOfType(value, String)) {
            return Python.fromString(value);
        }

        if (Std.isOfType(value, Bytes)) {
            return PythonBytes.fromBytes(cast value);
        }

        if (Std.isOfType(value, Array)) {
            var list = Python.listNew();
            for (item in (cast value:Array<Dynamic>)) {
                var pyItem = fromDynamic(item);
                Python.listAppend(list, pyItem);
                Python.decref(pyItem);
            }
            return list;
        }

        if (Std.isOfType(value, StringMap)) {
            var dict = Python.dictNew();
            var map:StringMap<Dynamic> = cast value;
            for (key in map.keys()) {
                var pyValue = fromDynamic(map.get(key));
                Python.dictSetItemString(dict, key, pyValue);
                Python.decref(pyValue);
            }
            return dict;
        }

        if (Reflect.isObject(value)) {
            var dict = Python.dictNew();
            for (field in Reflect.fields(value)) {
                var pyValue = fromDynamic(Reflect.field(value, field));
                Python.dictSetItemString(dict, field, pyValue);
                Python.decref(pyValue);
            }
            return dict;
        }

        return Python.fromString(Std.string(value));
    }

    public static function toDynamic(obj:PyObject):Dynamic {
        if (obj == null || Python.isNone(obj)) {
            return null;
        }

        if (Python.isBool(obj)) {
            return Python.toBool(obj);
        }

        if (Python.isInt(obj)) {
            return Python.toInt(obj);
        }

        if (Python.isFloat(obj)) {
            return Python.toFloat(obj);
        }

        if (Python.isString(obj)) {
            return Python.toString(obj);
        }

        if (Python.isList(obj)) {
            return listToArray(obj, true);
        }

        if (Python.isTuple(obj)) {
            return listToArray(obj, false);
        }

        if (Python.isSet(obj)) {
            return PythonIter.toDynamicArray(obj);
        }

        if (Python.isDict(obj)) {
            var result = {};
            var keys = Python.dictKeys(obj);
            if (keys != null) {
                var size = Python.listSize(keys);
                for (i in 0...size) {
                    var keyObj = Python.listGetItem(keys, i);
                    var fieldName = Python.toString(keyObj);
                    var valueObj = Python.dictGetItem(obj, keyObj);
                    Reflect.setField(result, fieldName, toDynamic(valueObj));
                }
                Python.decref(keys);
            }
            return result;
        }

        return Python.toString(obj);
    }

    static function listToArray(obj:PyObject, isList:Bool):Array<Dynamic> {
        var result:Array<Dynamic> = [];
        var size = isList ? Python.listSize(obj) : Python.tupleSize(obj);
        for (i in 0...size) {
            var item = isList ? Python.listGetItem(obj, i) : Python.tupleGetItem(obj, i);
            result.push(toDynamic(item));
        }
        return result;
    }
}
