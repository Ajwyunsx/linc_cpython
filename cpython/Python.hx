package cpython;

@:keep
@:include('linc_cpython.h')
#if !display
@:build(linc.Linc.touch())
@:build(linc.Linc.xml('cpython'))
#end
extern class Python {

    public static inline var PY_SINGLE_INPUT:Int = 256;
    public static inline var PY_FILE_INPUT:Int = 257;
    public static inline var PY_EVAL_INPUT:Int = 258;

    @:native('linc::cpython::initialize')
    static function initialize() : Void;

    @:native('linc::cpython::finalize')
    static function finalize() : Void;

    @:native('linc::cpython::isInitialized')
    static function isInitialized() : Bool;

    @:native('linc::cpython::getMainModule')
    static function getMainModule() : PyObject;

    @:native('linc::cpython::getMainDict')
    static function getMainDict() : PyObject;

    @:native('linc::cpython::getBuiltins')
    static function getBuiltins() : PyObject;

    @:native('linc::cpython::getSysModules')
    static function getSysModules() : PyObject;

    @:native('linc::cpython::importModule')
    static function importModule(name:String) : PyObject;

    @:native('linc::cpython::reloadModule')
    static function reloadModule(module:PyObject) : PyObject;

    @:native('linc::cpython::getModuleDict')
    static function getModuleDict(module:PyObject) : PyObject;

    @:native('linc::cpython::appendSysPath')
    static function appendSysPath(path:String) : Int;

    @:native('linc::cpython::insertSysPath')
    static function insertSysPath(index:Int, path:String) : Int;

    @:native('linc::cpython::incref')
    static function incref(obj:PyObject) : Void;

    @:native('linc::cpython::decref')
    static function decref(obj:PyObject) : Void;

    @:native('linc::cpython::getRefCount')
    static function getRefCount(obj:PyObject) : Int;

    @:native('linc::cpython::isNone')
    static function isNone(obj:PyObject) : Bool;

    @:native('linc::cpython::isBool')
    static function isBool(obj:PyObject) : Bool;

    @:native('linc::cpython::isInt')
    static function isInt(obj:PyObject) : Bool;

    @:native('linc::cpython::isFloat')
    static function isFloat(obj:PyObject) : Bool;

    @:native('linc::cpython::isString')
    static function isString(obj:PyObject) : Bool;

    @:native('linc::cpython::isBytes')
    static function isBytes(obj:PyObject) : Bool;

    @:native('linc::cpython::isByteArray')
    static function isByteArray(obj:PyObject) : Bool;

    @:native('linc::cpython::isMemoryView')
    static function isMemoryView(obj:PyObject) : Bool;

    @:native('linc::cpython::isList')
    static function isList(obj:PyObject) : Bool;

    @:native('linc::cpython::isDict')
    static function isDict(obj:PyObject) : Bool;

    @:native('linc::cpython::isTuple')
    static function isTuple(obj:PyObject) : Bool;

    @:native('linc::cpython::isSlice')
    static function isSlice(obj:PyObject) : Bool;

    @:native('linc::cpython::isSet')
    static function isSet(obj:PyObject) : Bool;

    @:native('linc::cpython::isCallable')
    static function isCallable(obj:PyObject) : Bool;

    @:native('linc::cpython::isModule')
    static function isModule(obj:PyObject) : Bool;

    @:native('linc::cpython::toInt')
    static function toInt(obj:PyObject) : Int;

    @:native('linc::cpython::toFloat')
    static function toFloat(obj:PyObject) : Float;

    @:native('linc::cpython::toString')
    static function toString(obj:PyObject) : String;

    @:native('linc::cpython::repr')
    static function repr(obj:PyObject) : String;

    @:native('linc::cpython::typeName')
    static function typeName(obj:PyObject) : String;

    @:native('linc::cpython::toBool')
    static function toBool(obj:PyObject) : Bool;

    @:native('linc::cpython::fromInt')
    static function fromInt(value:Int) : PyObject;

    @:native('linc::cpython::fromFloat')
    static function fromFloat(value:Float) : PyObject;

    @:native('linc::cpython::fromString')
    static function fromString(value:String) : PyObject;

    @:native('linc::cpython::bytesFromString')
    static function bytesFromString(value:String) : PyObject;

    @:native('linc::cpython::byteArrayFromString')
    static function byteArrayFromString(value:String) : PyObject;

    @:native('linc::cpython::memoryViewFromObject')
    static function memoryViewFromObject(obj:PyObject) : PyObject;

    @:native('linc::cpython::fromBool')
    static function fromBool(value:Bool) : PyObject;

    @:native('linc::cpython::none')
    static function none() : PyObject;

    @:native('linc::cpython::bytesSize')
    static function bytesSize(obj:PyObject) : Int;

    @:native('linc::cpython::bytesAsString')
    static function bytesAsString(obj:PyObject) : String;

    @:native('linc::cpython::listNew')
    static function listNew() : PyObject;

    @:native('linc::cpython::listSize')
    static function listSize(list:PyObject) : Int;

    @:native('linc::cpython::listGetItem')
    static function listGetItem(list:PyObject, index:Int) : PyObject;

    @:native('linc::cpython::listSetItem')
    static function listSetItem(list:PyObject, index:Int, item:PyObject) : Int;

    @:native('linc::cpython::listAppend')
    static function listAppend(list:PyObject, item:PyObject) : Int;

    @:native('linc::cpython::sequenceConcat')
    static function sequenceConcat(left:PyObject, right:PyObject) : PyObject;

    @:native('linc::cpython::sequenceRepeat')
    static function sequenceRepeat(obj:PyObject, count:Int) : PyObject;

    @:native('linc::cpython::sliceNew')
    static function sliceNew(start:Int, stop:Int, step:Int) : PyObject;

    @:native('linc::cpython::getSlice')
    static function getSlice(obj:PyObject, start:Int, stop:Int) : PyObject;

    @:native('linc::cpython::setSlice')
    static function setSlice(obj:PyObject, start:Int, stop:Int, value:PyObject) : Int;

    @:native('linc::cpython::delSlice')
    static function delSlice(obj:PyObject, start:Int, stop:Int) : Int;

    @:native('linc::cpython::setNew')
    static function setNew() : PyObject;

    @:native('linc::cpython::setSize')
    static function setSize(setObj:PyObject) : Int;

    @:native('linc::cpython::setAdd')
    static function setAdd(setObj:PyObject, item:PyObject) : Int;

    @:noCompletion
    @:native('linc::cpython::setContains')
    static function _setContains(setObj:PyObject, item:PyObject) : Int;

    static inline function setContains(setObj:PyObject, item:PyObject) : Bool {
        return _setContains(setObj, item) == 1;
    }

    @:native('linc::cpython::getItem')
    static function getItem(obj:PyObject, key:PyObject) : PyObject;

    @:native('linc::cpython::setItem')
    static function setItem(obj:PyObject, key:PyObject, value:PyObject) : Int;

    @:native('linc::cpython::delItem')
    static function delItem(obj:PyObject, key:PyObject) : Int;

    @:noCompletion
    @:native('linc::cpython::contains')
    static function _contains(obj:PyObject, key:PyObject) : Int;

    static inline function contains(obj:PyObject, key:PyObject) : Bool {
        return _contains(obj, key) == 1;
    }

    @:native('linc::cpython::objectSize')
    static function objectSize(obj:PyObject) : Int;

    @:native('linc::cpython::dictNew')
    static function dictNew() : PyObject;

    @:native('linc::cpython::dictSize')
    static function dictSize(dict:PyObject) : Int;

    @:native('linc::cpython::dictGetItem')
    static function dictGetItem(dict:PyObject, key:PyObject) : PyObject;

    @:native('linc::cpython::dictGetItemString')
    static function dictGetItemString(dict:PyObject, key:String) : PyObject;

    @:native('linc::cpython::dictSetItem')
    static function dictSetItem(dict:PyObject, key:PyObject, value:PyObject) : Int;

    @:native('linc::cpython::dictSetItemString')
    static function dictSetItemString(dict:PyObject, key:String, value:PyObject) : Int;

    @:native('linc::cpython::dictDelItem')
    static function dictDelItem(dict:PyObject, key:PyObject) : Int;

    @:native('linc::cpython::dictDelItemString')
    static function dictDelItemString(dict:PyObject, key:String) : Int;

    @:native('linc::cpython::dictKeys')
    static function dictKeys(dict:PyObject) : PyObject;

    @:native('linc::cpython::dictValues')
    static function dictValues(dict:PyObject) : PyObject;

    @:native('linc::cpython::dictItems')
    static function dictItems(dict:PyObject) : PyObject;

    @:native('linc::cpython::tupleNew')
    static function tupleNew(size:Int) : PyObject;

    @:native('linc::cpython::tupleSize')
    static function tupleSize(tuple:PyObject) : Int;

    @:native('linc::cpython::tupleGetItem')
    static function tupleGetItem(tuple:PyObject, index:Int) : PyObject;

    @:native('linc::cpython::tupleSetItem')
    static function tupleSetItem(tuple:PyObject, index:Int, item:PyObject) : Int;

    @:native('linc::cpython::callFunction')
    static function callFunction(callable:PyObject, args:PyObject) : PyObject;

    @:native('linc::cpython::callFunctionNoArgs')
    static function callFunctionNoArgs(callable:PyObject) : PyObject;

    @:native('linc::cpython::callFunctionWithKeywords')
    static function callFunctionWithKeywords(callable:PyObject, args:PyObject, kwargs:PyObject) : PyObject;

    @:native('linc::cpython::getBuiltin')
    static function getBuiltin(name:String) : PyObject;

    @:native('linc::cpython::callMethod')
    static function callMethod(obj:PyObject, name:String, args:PyObject) : PyObject;

    @:native('linc::cpython::callMethodNoArgs')
    static function callMethodNoArgs(obj:PyObject, name:String) : PyObject;

    @:native('linc::cpython::createHaxeCallback')
    static function createHaxeCallback(callbackId:Int, name:String) : PyObject;

    @:native('linc::cpython::dynamicHandleToPyObject')
    static function dynamicHandleToPyObject(value:Dynamic) : PyObject;

    @:noCompletion
    @:native('linc::cpython::compareEq')
    static function _compareEq(left:PyObject, right:PyObject) : Int;

    static inline function compareEq(left:PyObject, right:PyObject) : Bool {
        return _compareEq(left, right) == 1;
    }

    @:noCompletion
    @:native('linc::cpython::compareNe')
    static function _compareNe(left:PyObject, right:PyObject) : Int;

    static inline function compareNe(left:PyObject, right:PyObject) : Bool {
        return _compareNe(left, right) == 1;
    }

    @:noCompletion
    @:native('linc::cpython::compareLt')
    static function _compareLt(left:PyObject, right:PyObject) : Int;

    static inline function compareLt(left:PyObject, right:PyObject) : Bool {
        return _compareLt(left, right) == 1;
    }

    @:noCompletion
    @:native('linc::cpython::compareLe')
    static function _compareLe(left:PyObject, right:PyObject) : Int;

    static inline function compareLe(left:PyObject, right:PyObject) : Bool {
        return _compareLe(left, right) == 1;
    }

    @:noCompletion
    @:native('linc::cpython::compareGt')
    static function _compareGt(left:PyObject, right:PyObject) : Int;

    static inline function compareGt(left:PyObject, right:PyObject) : Bool {
        return _compareGt(left, right) == 1;
    }

    @:noCompletion
    @:native('linc::cpython::compareGe')
    static function _compareGe(left:PyObject, right:PyObject) : Int;

    static inline function compareGe(left:PyObject, right:PyObject) : Bool {
        return _compareGe(left, right) == 1;
    }

    @:noCompletion
    @:native('linc::cpython::isInstance')
    static function _isInstance(obj:PyObject, cls:PyObject) : Int;

    static inline function isInstance(obj:PyObject, cls:PyObject) : Bool {
        return _isInstance(obj, cls) == 1;
    }

    @:noCompletion
    @:native('linc::cpython::isSubclass')
    static function _isSubclass(derived:PyObject, cls:PyObject) : Int;

    static inline function isSubclass(derived:PyObject, cls:PyObject) : Bool {
        return _isSubclass(derived, cls) == 1;
    }

    @:native('linc::cpython::hashObject')
    static function hashObject(obj:PyObject) : Int;

    @:native('linc::cpython::getIter')
    static function getIter(obj:PyObject) : PyObject;

    @:native('linc::cpython::iterNext')
    static function iterNext(iterObj:PyObject) : PyObject;

    @:native('linc::cpython::dir')
    static function dir(obj:PyObject) : PyObject;

    @:native('linc::cpython::getAttr')
    static function getAttr(obj:PyObject, name:String) : PyObject;

    @:native('linc::cpython::setAttr')
    static function setAttr(obj:PyObject, name:String, value:PyObject) : Int;

    @:native('linc::cpython::delAttr')
    static function delAttr(obj:PyObject, name:String) : Int;

    @:native('linc::cpython::hasAttr')
    static function hasAttr(obj:PyObject, name:String) : Int;

    @:native('linc::cpython::enterContext')
    static function enterContext(obj:PyObject) : PyObject;

    @:native('linc::cpython::exitContext')
    static function exitContext(obj:PyObject, excType:PyObject, excValue:PyObject, traceback:PyObject) : Int;

    @:native('linc::cpython::clearError')
    static function clearError() : Void;

    @:native('linc::cpython::hasError')
    static function hasError() : Bool;

    @:native('linc::cpython::getErrorString')
    static function getErrorString() : String;

    @:native('linc::cpython::getErrorTraceback')
    static function getErrorTraceback() : String;

    @:native('linc::cpython::evalString')
    static function evalString(expression:String) : PyObject;

    @:native('linc::cpython::execString')
    static function execString(command:String) : PyObject;

    @:native('linc::cpython::runSimpleString')
    static function runSimpleString(command:String) : PyObject;

    @:native('linc::cpython::runFile')
    static function runFile(filename:String) : PyObject;
}
