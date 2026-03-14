package cpython;

class PythonContext {
    public static function enter(contextObj:PyObject):PyObject {
        var result = Python.enterContext(contextObj);
        if (result == null) {
            throw PythonException.fromCurrentError('enterContext failed');
        }
        return result;
    }

    public static function exit(contextObj:PyObject, ?excType:PyObject, ?excValue:PyObject, ?traceback:PyObject):Bool {
        var ownsType = excType == null;
        var ownsValue = excValue == null;
        var ownsTraceback = traceback == null;

        var typeObj = ownsType ? Python.none() : excType;
        var valueObj = ownsValue ? Python.none() : excValue;
        var tracebackObj = ownsTraceback ? Python.none() : traceback;

        var result = Python.exitContext(contextObj, typeObj, valueObj, tracebackObj) == 1;

        if (ownsType) {
            Python.decref(typeObj);
        }
        if (ownsValue) {
            Python.decref(valueObj);
        }
        if (ownsTraceback) {
            Python.decref(tracebackObj);
        }

        return result;
    }

    public static function withObject<T>(contextObj:PyObject, body:Dynamic->T):T {
        var entered = enter(contextObj);
        try {
            var result = body(cast entered);
            exit(contextObj);
            Python.decref(entered);
            return result;
        } catch (e) {
            exit(contextObj);
            Python.decref(entered);
            throw e;
        }
    }
}
