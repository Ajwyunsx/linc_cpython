package cpython;

class PythonMapping {
    public static function keys(dict:PyObject):Array<String> {
        var keyList = Python.dictKeys(dict);
        if (keyList == null) {
            throw PythonException.fromCurrentError('dictKeys failed');
        }

        var values = PythonIter.toStringArray(keyList);
        Python.decref(keyList);
        return values;
    }

    public static function values(dict:PyObject):Array<Dynamic> {
        var valueList = Python.dictValues(dict);
        if (valueList == null) {
            throw PythonException.fromCurrentError('dictValues failed');
        }

        var values:Array<Dynamic> = cast Convert.toDynamic(valueList);
        Python.decref(valueList);
        return values;
    }

    public static function items(dict:PyObject):Array<Dynamic> {
        var itemList = Python.dictItems(dict);
        if (itemList == null) {
            throw PythonException.fromCurrentError('dictItems failed');
        }

        var values:Array<Dynamic> = cast Convert.toDynamic(itemList);
        Python.decref(itemList);
        return values;
    }
}
