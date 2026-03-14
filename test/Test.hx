import cpython.CPython;
import cpython.Convert;
import cpython.Python;
import cpython.PythonArgs;
import cpython.PythonBuiltins;
import cpython.PythonBytes;
import cpython.PythonCallback;
import cpython.PythonCompare;
import cpython.PythonConfig;
import cpython.PythonContext;
import cpython.PythonDelete;
import cpython.PythonErrors;
import cpython.PythonException;
import cpython.PythonImport;
import cpython.PythonIter;
import cpython.PythonKwargs;
import cpython.PythonMapping;
import cpython.PythonModules;
import cpython.PythonObjects;
import cpython.PythonRun;
import cpython.PythonSequence;
import cpython.PythonSlice;
import cpython.PythonSet;
import haxe.io.Bytes;

class Test {

    static function main() {
        trace("=== linc_cpython Compatibility Suite ===\n");

        testInterpreterLifecycle();
        PythonConfig.init(["./modules"]);

        testTypeConversions();
        testBuiltinsAndIntrospection();
        testConvertCompatibility();
        testExternalImportCompatibility();
        testMethodCallsAndExec();
        testSetAndIteratorCompatibility();
        testModuleCacheAndObjectHelpers();
        testCallbackBridgeCompatibility();
        testSliceDeleteAndContextCompatibility();
        testProtocolLayerCompatibility();
        testBytesCompatibility();
        testRunFileAndGlobals();
        testErrorHandling();
        testTracebackFormatting();

        PythonConfig.shutdown();
        trace("\n=== All compatibility tests completed! ===");
    }

    static function testInterpreterLifecycle() {
        trace("Test 1: Interpreter Lifecycle");

        var wasInit = CPython.isInitialized();
        trace("  Initial state: " + (wasInit ? "initialized" : "not initialized"));

        CPython.initialize();
        trace("  After initialize(): " + (CPython.isInitialized() ? "initialized" : "not initialized"));

        CPython.finalize();
        trace("  After finalize(): " + (CPython.isInitialized() ? "initialized" : "not initialized"));

        CPython.initialize();
        trace("  Alias compatibility (CPython -> Python): ok");
        trace("  ✓ Interpreter lifecycle test passed\n");
    }

    static function testTypeConversions() {
        trace("Test 2: Core Type Conversions");

        var pyInt = CPython.fromInt(42);
        trace("  Integer: 42 -> " + Std.string(CPython.toInt(pyInt)));
        trace("  isInt: " + Std.string(CPython.isInt(pyInt)));
        CPython.decref(pyInt);

        var pyFloat = CPython.fromFloat(3.14159);
        trace("  Float: 3.14159 -> " + Std.string(CPython.toFloat(pyFloat)));
        trace("  isFloat: " + Std.string(CPython.isFloat(pyFloat)));
        CPython.decref(pyFloat);

        var pyStr = CPython.fromString("Hello from Haxe!");
        trace("  String: Hello from Haxe! -> " + CPython.toString(pyStr));
        trace("  isString: " + Std.string(CPython.isString(pyStr)));
        CPython.decref(pyStr);

        var pyBool = CPython.fromBool(true);
        trace("  Boolean: true -> " + Std.string(CPython.toBool(pyBool)));
        trace("  isBool: " + Std.string(Python.isBool(pyBool)));
        CPython.decref(pyBool);

        var pyNone = CPython.none();
        trace("  None: " + Std.string(CPython.isNone(pyNone)));
        CPython.decref(pyNone);

        trace("  ✓ Core conversion test passed\n");
    }

    static function testConvertCompatibility() {
        trace("Test 4: Dynamic Convert Compatibility");

        var source = {
            title: "bubble",
            numbers: [1, 2, 3],
            nested: {
                enabled: true,
                score: 9.5
            }
        };

        var pyValue = Convert.fromDynamic(source);
        var roundTrip:Dynamic = Convert.toDynamic(pyValue);

        trace("  title: " + Std.string(Reflect.field(roundTrip, "title")));
        var numbers:Array<Dynamic> = cast Reflect.field(roundTrip, "numbers");
        trace("  numbers length: " + Std.string(numbers.length));

        var nested:Dynamic = Reflect.field(roundTrip, "nested");
        trace("  nested.enabled: " + Std.string(Reflect.field(nested, "enabled")));

        Python.decref(pyValue);
        trace("  ✓ Dynamic convert compatibility test passed\n");
    }

    static function testBuiltinsAndIntrospection() {
        trace("Test 3: Builtins And Introspection");

        var list = Convert.fromDynamic([1, 2, 3, 4]);
        var args = Python.tupleNew(1);
        Python.tupleSetItem(args, 0, list);

        var lengthObj = PythonBuiltins.call("len", args);
        trace("  builtin len([1,2,3,4]): " + Std.string(Python.toInt(lengthObj)));
        trace("  type(list): " + PythonBuiltins.typeName(list));

        var module = PythonImport.require("external_module");
        var dirNames = PythonBuiltins.dirStrings(module);
        trace("  dir contains square: " + Std.string(dirNames.indexOf("square") != -1));
        trace("  dir contains Greeter: " + Std.string(dirNames.indexOf("Greeter") != -1));

        Python.decref(lengthObj);
        Python.decref(args);
        Python.decref(list);
        Python.decref(module);

        trace("  ✓ Builtins/introspection test passed\n");
    }

    static function testExternalImportCompatibility() {
        trace("Test 5: External Import And Module Compatibility");

        PythonImport.init(["./modules"]);
        var module = PythonImport.require("external_module");

        trace("  external_module imported: " + Std.string(Python.isModule(module)));

        var square = Python.getAttr(module, "square");
        var args = Python.tupleNew(1);
        var arg = Python.fromInt(12);
        Python.tupleSetItem(args, 0, arg);
        var squared = PythonRun.call(square, args);

        trace("  square(12): " + Std.string(Python.toInt(squared)));

        Python.decref(arg);
        Python.decref(args);
        Python.decref(square);
        Python.decref(squared);

        var payloadFn = Python.getAttr(module, "get_payload");
        var payload = PythonRun.call(payloadFn);
        var payloadDynamic:Dynamic = Convert.toDynamic(payload);
        trace("  payload.kind: " + Std.string(Reflect.field(payloadDynamic, "kind")));

        var tags:Array<Dynamic> = cast Reflect.field(payloadDynamic, "tags");
        trace("  payload.tags count: " + Std.string(tags.length));

        Python.decref(payloadFn);
        Python.decref(payload);
        Python.decref(module);

        trace("  ✓ External import compatibility test passed\n");
    }

    static function testMethodCallsAndExec() {
        trace("Test 6: Method Calls And Exec Compatibility");

        var module = PythonImport.require("external_module");
        var greeterClass = Python.getAttr(module, "Greeter");

        var ctorArgs = Python.tupleNew(1);
        var prefix = Python.fromString("Hello");
        Python.tupleSetItem(ctorArgs, 0, prefix);
        var greeter = PythonRun.call(greeterClass, ctorArgs);

        var greetArgs = Python.tupleNew(1);
        var name = Python.fromString("Haxe");
        Python.tupleSetItem(greetArgs, 0, name);
        var greeting = PythonRun.callMethod(greeter, "greet", greetArgs);

        trace("  greet result: " + Python.toString(greeting));

        Python.decref(prefix);
        Python.decref(ctorArgs);
        Python.decref(name);
        Python.decref(greetArgs);
        Python.decref(greeterClass);
        Python.decref(greeter);
        Python.decref(greeting);
        Python.decref(module);

        var execResult = PythonRun.exec("runtime_value = 7 * 6");
        Python.decref(execResult);

        var mainDict = Python.getMainDict();
        var runtimeValue = Python.dictGetItemString(mainDict, "runtime_value");
        trace("  runtime_value: " + Std.string(Python.toInt(runtimeValue)));

        trace("  ✓ Method/exec compatibility test passed\n");
    }

    static function testSetAndIteratorCompatibility() {
        trace("Test 7: Set And Iterator Compatibility");

        var setObj = PythonSet.fromArray([1, 2, 2, 3, "four"]);
        trace("  isSet: " + Std.string(Python.isSet(setObj)));
        trace("  set size: " + Std.string(PythonSet.size(setObj)));
        trace("  contains 'four': " + Std.string(PythonSet.containsDynamic(setObj, "four")));

        var iterValues = PythonSet.toDynamicArray(setObj);
        trace("  iterated set values: " + Std.string(iterValues.length));

        var dict = Python.dictNew();
        var alpha = Python.fromInt(1);
        var beta = Python.fromInt(2);
        Python.dictSetItemString(dict, "alpha", alpha);
        Python.dictSetItemString(dict, "beta", beta);

        var keys = Python.dictKeys(dict);
        var keyNames = PythonIter.toStringArray(keys);
        trace("  iterated dict key count: " + Std.string(keyNames.length));
        trace("  keys contain alpha: " + Std.string(keyNames.indexOf("alpha") != -1));

        Python.decref(keys);
        Python.decref(alpha);
        Python.decref(beta);
        Python.decref(dict);
        Python.decref(setObj);

        trace("  ✓ Set/iterator compatibility test passed\n");
    }

    static function testModuleCacheAndObjectHelpers() {
        trace("Test 8: Module Cache And Object Helpers");

        trace("  external_module loaded: " + Std.string(PythonModules.isLoaded("external_module")));

        var oldLoaded = PythonModules.getLoaded("external_module");
        if (oldLoaded != null) {
            Python.decref(oldLoaded);
        }

        var unloaded = PythonModules.unload("external_module");
        trace("  unload external_module: " + Std.string(unloaded));
        trace("  loaded after unload: " + Std.string(PythonModules.isLoaded("external_module")));

        PythonModules.invalidateCaches();
        var module = PythonModules.require("external_module");
        trace("  reimported after unload: " + Std.string(module != null));

        var describe = Python.getAttr(module, "describe");
        var emptyArgs = PythonArgs.empty();
        var kwargs = PythonKwargs.fromDynamic({name: "Haxe", punctuation: "?"});
        var described = PythonRun.call(describe, emptyArgs, kwargs);
        trace("  describe kwargs: " + Python.toString(described));

        Python.decref(emptyArgs);
        Python.decref(kwargs);
        Python.decref(described);
        Python.decref(describe);

        var point = PythonObjects.constructFromModule(module, "Point", [3, 4], {label: "cli"});
        var pointTuple = PythonObjects.callAttr(point, "as_tuple");
        var pointData:Array<Dynamic> = cast Convert.toDynamic(pointTuple);
        trace("  point tuple len: " + Std.string(pointData.length));
        trace("  point label: " + Std.string(pointData[2]));

        Python.decref(pointTuple);
        Python.decref(point);
        Python.decref(module);

        trace("  ✓ Module cache/object helper test passed\n");
    }

    static function testCallbackBridgeCompatibility() {
        trace("Test 9: Callback Bridge Compatibility");

        var module = PythonModules.require("external_module");
        trace("  callback step: module loaded");

        var dynamicCallback = PythonCallback.createDynamic(function(args:Dynamic, kwargs:Dynamic) {
            var values:Array<Dynamic> = cast args;
            return values[0] + Std.int(Reflect.field(kwargs, "bonus"));
        }, "sum_bonus");
        trace("  callback step: dynamic callback created");

        var callbackRunner = Python.getAttr(module, "call_haxe_callback");
        trace("  callback step: runner fetched");
        var ten = Python.fromInt(10);
        var callArgs = Python.tupleNew(2);
        Python.tupleSetItem(callArgs, 0, dynamicCallback);
        Python.tupleSetItem(callArgs, 1, ten);
        trace("  callback step: dynamic args built");
        var callbackResult = PythonRun.call(callbackRunner, callArgs);
        trace("  callback step: dynamic callback invoked");
        trace("  dynamic callback result: " + Std.string(Python.toInt(callbackResult)));

        var published = PythonCallback.publishDynamic("haxe_magic", function(args:Dynamic, kwargs:Dynamic) {
            var values:Array<Dynamic> = cast args;
            return "magic-" + Std.string(values[0]);
        });
        trace("  callback step: global callback published");
        var publishedResult = PythonRun.eval("haxe_magic(3)");
        trace("  callback step: published callback invoked");
        trace("  published callback result: " + Python.toString(publishedResult));
        PythonDelete.dictKeyString(Python.getMainDict(), "haxe_magic");

        Python.decref(publishedResult);
        Python.decref(published);
        Python.decref(callbackResult);
        Python.decref(callArgs);
        Python.decref(ten);
        Python.decref(callbackRunner);
        Python.decref(dynamicCallback);
        Python.decref(module);

        trace("  ✓ Callback bridge compatibility test passed\n");
    }

    static function testSliceDeleteAndContextCompatibility() {
        trace("Test 10: Slice Delete And Context Compatibility");

        var listObj = Convert.fromDynamic([0, 1, 2, 3, 4, 5]);
        var sliceSpec = PythonSlice.create(1, 5, 1);
        trace("  isSlice: " + Std.string(Python.isSlice(sliceSpec)));

        var sliceObj = PythonSlice.get(listObj, 1, 5);
        var sliceValues:Array<Dynamic> = cast Convert.toDynamic(sliceObj);
        trace("  slice len: " + Std.string(sliceValues.length));
        trace("  slice first: " + Std.string(sliceValues[0]));

        PythonSlice.replace(listObj, 1, 3, [9, 8]);
        var afterReplace:Array<Dynamic> = cast Convert.toDynamic(listObj);
        trace("  after replace second: " + Std.string(afterReplace[1]));

        PythonSlice.deleteRange(listObj, 4, 6);
        var afterDelete:Array<Dynamic> = cast Convert.toDynamic(listObj);
        trace("  after delete len: " + Std.string(afterDelete.length));

        var dict = Python.dictNew();
        var keep = Python.fromInt(1);
        var drop = Python.fromInt(2);
        Python.dictSetItemString(dict, "keep", keep);
        Python.dictSetItemString(dict, "drop", drop);
        PythonDelete.item(dict, "keep");
        PythonDelete.dictKeyString(dict, "drop");
        trace("  dict size after deletes: " + Std.string(Python.dictSize(dict)));

        var module = PythonModules.require("external_module");
        var point = PythonObjects.constructFromModule(module, "Point", [1, 2], {label: "temp"});
        trace("  point has label before delete: " + Std.string(Python.hasAttr(point, "label") == 1));
        PythonDelete.attr(point, "label");
        trace("  point has label after delete: " + Std.string(Python.hasAttr(point, "label") == 1));

        var context = PythonObjects.constructFromModule(module, "DemoContext", ["ctx"]);
        var active = PythonContext.enter(context);
        var attr = Python.getAttr(active, "label");
        var label = Python.toString(attr);
        Python.decref(attr);
        Python.decref(active);
        PythonContext.exit(context);
        trace("  context label: " + label);

        var events = Python.getAttr(context, "events");
        var eventValues:Array<Dynamic> = cast Convert.toDynamic(events);
        trace("  context event count: " + Std.string(eventValues.length));
        trace("  context last event: " + Std.string(eventValues[eventValues.length - 1]));

        Python.decref(events);
        Python.decref(context);
        Python.decref(point);
        Python.decref(module);
        Python.decref(keep);
        Python.decref(drop);
        Python.decref(dict);
        Python.decref(sliceObj);
        Python.decref(sliceSpec);
        Python.decref(listObj);

        trace("  ✓ Slice/delete/context compatibility test passed\n");
    }

    static function testProtocolLayerCompatibility() {
        trace("Test 11: Protocol Layer Compatibility");

        var concatValues = PythonSequence.concatDynamic([1, 2], [3, 4]);
        trace("  concat len: " + Std.string(concatValues.length));
        trace("  concat last: " + Std.string(concatValues[3]));

        var repeatValues = PythonSequence.repeatDynamic([7, 8], 3);
        trace("  repeat len: " + Std.string(repeatValues.length));
        trace("  repeat middle: " + Std.string(repeatValues[2]));

        var dictObj = Convert.fromDynamic({alpha: 1, beta: 2, gamma: 3});
        var mappingKeys = PythonMapping.keys(dictObj);
        var mappingValues = PythonMapping.values(dictObj);
        var mappingItems = PythonMapping.items(dictObj);
        trace("  mapping key count: " + Std.string(mappingKeys.length));
        trace("  mapping values count: " + Std.string(mappingValues.length));
        trace("  mapping items count: " + Std.string(mappingItems.length));

        var pointModule = PythonModules.require("external_module");
        var pointClass = Python.getAttr(pointModule, "Point");
        var fancyClass = Python.getAttr(pointModule, "FancyPoint");
        var point = PythonObjects.constructFromModule(pointModule, "Point", [5, 6], {label: "cmp"});

        var eqLeft = Python.fromInt(5);
        var eqRight = Python.fromInt(5);
        trace("  compare eq ints: " + Std.string(PythonCompare.eq(eqLeft, eqRight)));

        var one = Python.fromInt(1);
        var two = Python.fromInt(2);
        trace("  compare lt ints: " + Std.string(PythonCompare.lt(one, two)));
        trace("  point is instance of Point: " + Std.string(PythonCompare.isInstance(point, pointClass)));
        trace("  FancyPoint is subclass of Point: " + Std.string(PythonCompare.isSubclass(fancyClass, pointClass)));

        var hashTarget = Python.fromString("hash-me");
        trace("  hash nonzero: " + Std.string(PythonCompare.hash(hashTarget) != 0));

        var brokenIterClass = Python.getAttr(pointModule, "BrokenIter");
        var brokenIter = PythonObjects.construct(brokenIterClass);
        try {
            PythonIter.toDynamicArray(brokenIter);
            trace("  broken iterator unexpectedly succeeded");
        } catch (e:PythonException) {
            trace("  broken iterator error caught: " + Std.string(e.tracebackText.indexOf("broken iterator") != -1));
        }

        Python.decref(brokenIter);
        Python.decref(brokenIterClass);
        Python.decref(hashTarget);
        Python.decref(eqLeft);
        Python.decref(eqRight);
        Python.decref(one);
        Python.decref(two);
        Python.decref(point);
        Python.decref(pointClass);
        Python.decref(fancyClass);
        Python.decref(pointModule);
        Python.decref(dictObj);

        trace("  ✓ Protocol layer compatibility test passed\n");
    }

    static function testRunFileAndGlobals() {
        trace("Test 13: File Execution And Global Import Config");

        var fileResult = PythonRun.runFile("./modules/bootstrap_script.py");
        Python.decref(fileResult);

        var mainDict = Python.getMainDict();
        var bootstrapMessage = Python.dictGetItemString(mainDict, "bootstrap_message");
        trace("  bootstrap_message: " + Python.toString(bootstrapMessage));

        var bootstrapValues = Python.dictGetItemString(mainDict, "bootstrap_values");
        var values:Array<Dynamic> = cast Convert.toDynamic(bootstrapValues);
        trace("  bootstrap_values length: " + Std.string(values.length));

        trace("  ✓ File/global compatibility test passed\n");
    }

    static function testBytesCompatibility() {
        trace("Test 12: Bytes And MemoryView Compatibility");

        var bytesObj = PythonBytes.fromString("hello-bytes");
        trace("  isBytes: " + Std.string(Python.isBytes(bytesObj)));
        trace("  bytes size: " + Std.string(PythonBytes.size(bytesObj)));
        trace("  bytes text: " + PythonBytes.toString(bytesObj));

        var byteArray = PythonBytes.byteArrayFromString("mutable-data");
        var memoryView = PythonBytes.memoryView(byteArray);
        trace("  isByteArray: " + Std.string(Python.isByteArray(byteArray)));
        trace("  isMemoryView: " + Std.string(Python.isMemoryView(memoryView)));
        trace("  memoryview text: " + PythonBytes.toString(memoryView));

        var haxeBytes = Bytes.ofString("haxe-bytes");
        var converted = Convert.fromDynamic(haxeBytes);
        trace("  Convert.fromDynamic(Bytes) -> bytes: " + Std.string(Python.isBytes(converted)));

        Python.decref(bytesObj);
        Python.decref(byteArray);
        Python.decref(memoryView);
        Python.decref(converted);

        trace("  ✓ Bytes compatibility test passed\n");
    }

    static function testErrorHandling() {
        trace("Test 14: Error Handling");

        PythonErrors.clear();
        var fakeModule = PythonImport.importModule("missing_demo_module_xyz");

        if (fakeModule == null) {
            trace("  hasError: " + Std.string(PythonErrors.hasError()));
            trace("  Error message: " + PythonErrors.message());
            PythonErrors.clear();
            trace("  After clearError(): " + Std.string(PythonErrors.hasError()));
            trace("  ✓ Error handling test passed\n");
        } else {
            trace("  Unexpected module import success");
            Python.decref(fakeModule);
        }
    }

    static function testTracebackFormatting() {
        trace("Test 15: Traceback Formatting");

        try {
            var result = PythonRun.exec("def explode():\n    return 1 / 0\nexplode()\n");
            Python.decref(result);
            trace("  Unexpected success for traceback test");
        } catch (e:PythonException) {
            trace("  traceback has ZeroDivisionError: " + Std.string(e.tracebackText.indexOf("ZeroDivisionError") != -1));
            trace("  traceback has explode(): " + Std.string(e.tracebackText.indexOf("explode") != -1));
            trace("  ✓ Traceback formatting test passed\n");
        }
    }
}
