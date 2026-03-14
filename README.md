# linc/cpython

Haxe/hxcpp @:native bindings for Python C API.

This is a [linc](http://snowkit.github.io/linc/) library.

---

This library works with the Haxe cpp target only.

## Purpose

`linc_cpython` provides low-level access to the Python C API from Haxe code, allowing you to:

- Embed Python interpreter in your Haxe/C++ application
- Import and use Python modules
- Convert data between Haxe and Python
- Call Python functions from Haxe
- Execute Python code dynamically
- Create and manipulate Python objects (lists, dicts, tuples)

## Module Layout

- `cpython.Python` - main low-level extern API, similar to `llua.Lua`
- `cpython.CPython` - compatibility alias to `cpython.Python`
- `cpython.PythonConfig` - interpreter and search-path configuration helpers
- `cpython.PythonImport` - module import helpers for external paths
- `cpython.PythonRun` - safe wrappers for `eval`, `exec`, file execution, and calls
- `cpython.Convert` - recursive Haxe `Dynamic` <-> Python object conversion
- `cpython.PythonBuiltins` - helpers for builtins, `len`, `dir`, and type inspection
- `cpython.PythonIter` - iterator helpers for converting Python iterables to Haxe arrays
- `cpython.PythonSet` - set creation and compatibility helpers
- `cpython.PythonArgs` - positional argument tuple builder
- `cpython.PythonKwargs` - keyword argument dict builder
- `cpython.PythonObjects` - object construction and attribute-call helpers
- `cpython.PythonModules` - module cache, reload, and unload helpers
- `cpython.PythonSlice` - slice creation, replacement, and deletion helpers
- `cpython.PythonDelete` - item, dict-key, and attribute deletion helpers
- `cpython.PythonContext` - context manager enter/exit helpers
- `cpython.PythonSequence` - sequence concat and repeat helpers
- `cpython.PythonMapping` - mapping keys, values, and items helpers
- `cpython.PythonCompare` - comparison, hashing, and instance helpers
- `cpython.PythonCallback` - Python-to-Haxe callback bridge helpers
- `cpython.PythonBytes` - bytes, bytearray, and memoryview helpers
- `cpython.PythonErrors` - CPython error and traceback helpers

## Install

```bash
haxelib git linc_cpython https://github.com/yourusername/linc_cpython.git
```

## Requirements

- Haxe 4.0+
- hxcpp
- Python 3.9+ development files (headers and libraries)

### Platform-specific Setup

#### Windows

Install Python and ensure the following paths are correct:
- Headers: `C:/Python3X/include`
- Libraries: `C:/Python3X/libs`

You can override these paths using defines:
```bash
-D PYTHON_INCLUDE_PATH=C:/custom/python/include
-D PYTHON_LIB_PATH=C:/custom/python/libs
-D PYTHON_LIB=python39
```

#### Linux

```bash
# Ubuntu/Debian
sudo apt-get install python3-dev

# Or specify custom paths
-D PYTHON_INCLUDE_PATH=/usr/include/python3.10
-D PYTHON_LIB_PATH=/usr/lib/python3.10/config-3.10-x86_64-linux-gnu
```

#### macOS

Python is usually pre-installed or available via Homebrew:
```bash
brew install python
```

## Example Usage

### Basic Example

```haxe
import cpython.Python;
import cpython.PythonConfig;

class Example {
    
    static function main() {
        PythonConfig.init(["./modules"]);
        
        var list = Python.listNew();
        
        for (i in 0...5) {
            var pyInt = Python.fromInt(i * 10);
            Python.listAppend(list, pyInt);
            Python.decref(pyInt);
        }
        
        trace("List size: " + Python.listSize(list));
        
        for (i in 0...Python.listSize(list)) {
            var item = Python.listGetItem(list, i);
            trace("Item[" + i + "] = " + Python.toInt(item));
        }
        
        Python.decref(list);
        PythonConfig.shutdown();
    }
    
}
```

### External Import Helpers

```haxe
import cpython.Python;
import cpython.PythonImport;

PythonImport.init(["./modules"]);

var module = PythonImport.require("external_module");
var square = Python.getAttr(module, "square");

var args = Python.tupleNew(1);
var value = Python.fromInt(9);
Python.tupleSetItem(args, 0, value);

var result = Python.callFunction(square, args);
trace(Python.toInt(result)); // 81
```

### Builtins, Set, And Iterator Helpers

```haxe
import cpython.Python;
import cpython.PythonBuiltins;
import cpython.PythonIter;
import cpython.PythonSet;

var setObj = PythonSet.fromArray([1, 2, 2, 3]);
trace(PythonSet.size(setObj)); // 3

var names = PythonBuiltins.dirStrings(setObj);
trace(names.indexOf("add") != -1);

var values = PythonIter.toDynamicArray(setObj);
trace(values.length);
```

### Bytes And Tracebacks

```haxe
import cpython.PythonBytes;
import cpython.PythonErrors;
import cpython.PythonRun;

var bytesObj = PythonBytes.fromString("hello-bytes");
trace(PythonBytes.size(bytesObj));

try {
    PythonRun.exec("raise ValueError('boom')");
} catch (e) {
    trace(PythonErrors.traceback());
}
```

### Module Cache And Object Helpers

```haxe
import cpython.PythonModules;
import cpython.PythonObjects;

var module = PythonModules.require("external_module");
var point = PythonObjects.constructFromModule(module, "Point", [3, 4], {label: "cli"});
var tuple = PythonObjects.callAttr(point, "as_tuple");
```

### Slice, Delete, And Context Helpers

```haxe
import cpython.PythonContext;
import cpython.PythonDelete;
import cpython.PythonSlice;

var listObj = Convert.fromDynamic([0, 1, 2, 3, 4]);
var part = PythonSlice.get(listObj, 1, 4);
PythonSlice.replace(listObj, 1, 3, [9, 8]);
PythonSlice.deleteRange(listObj, 3, 4);

var context = PythonObjects.constructFromModule(module, "DemoContext", ["ctx"]);
var entered = PythonContext.enter(context);
PythonContext.exit(context);
```

### Protocol Helpers

```haxe
import cpython.PythonCompare;
import cpython.PythonMapping;
import cpython.PythonSequence;

var values = PythonSequence.concatDynamic([1, 2], [3, 4]);
var repeated = PythonSequence.repeatDynamic([7, 8], 3);

var dictObj = Convert.fromDynamic({alpha: 1, beta: 2});
trace(PythonMapping.keys(dictObj));

var left = Python.fromInt(1);
var right = Python.fromInt(2);
trace(PythonCompare.lt(left, right));
```

### Python Calling Back Into Haxe

```haxe
import cpython.PythonCallback;
import cpython.PythonModules;
import cpython.PythonRun;

var module = PythonModules.require("external_module");
var callback = PythonCallback.createDynamic(function(args, kwargs) {
    var values:Array<Dynamic> = cast args;
    return values[0] + Std.int(Reflect.field(kwargs, "bonus"));
});

var runner = Python.getAttr(module, "call_haxe_callback");
var pyArgs = Python.tupleNew(2);
var value = Python.fromInt(10);
Python.tupleSetItem(pyArgs, 0, callback);
Python.tupleSetItem(pyArgs, 1, value);

var result = PythonRun.call(runner, pyArgs);
trace(Python.toInt(result)); // 15
```

### Android Prebuilt Layout

`linc_cpython` supports Android prebuilt static libraries using this layout:

- `lib/cpython/include/android/armv7/`
- `lib/cpython/include/android/arm64-v8a/`
- `lib/cpython/include/android/x86/`
- `lib/cpython/include/android/x86_64/`
- `lib/cpython/lib/android/<abi>/lib/libpython3.12.a`

The workflow `.github/workflows/android-prebuilt.yml` is designed to populate these directories.

### Importing Python Modules

```haxe
// Import the math module
var mathModule = CPython.importModule("math");

if (mathModule != null) {
    // Get sqrt function
    var sqrt = CPython.getAttr(mathModule, "sqrt");
    
    // Create argument tuple
    var args = CPython.tupleNew(1);
    var arg = CPython.fromFloat(16.0);
    CPython.tupleSetItem(args, 0, arg);
    
    // Call sqrt(16.0)
    var result = CPython.callFunction(sqrt, args);
    trace("sqrt(16) = " + CPython.toFloat(result));
    
    // Clean up
    CPython.decref(result);
    CPython.decref(args);
    CPython.decref(arg);
    CPython.decref(sqrt);
    CPython.decref(mathModule);
}
```

### Evaluating Python Code

```haxe
// Execute Python code
CPython.runSimpleString("print('Hello from Python!')");

// Evaluate an expression
var result = CPython.evalString("2 + 2");
trace("2 + 2 = " + CPython.toInt(result));
CPython.decref(result);
```

### Working with Dictionaries

```haxe
// Create a dict
var dict = CPython.dictNew();

// Set key-value pairs
var key = CPython.fromString("message");
var value = CPython.fromString("Hello from Haxe!");
CPython.dictSetItem(dict, key, value);
CPython.decref(key);
CPython.decref(value);

// Retrieve value
var retrieved = CPython.dictGetItemString(dict, "message");
trace("Message: " + CPython.toString(retrieved));

// Clean up
CPython.decref(dict);
```

### Error Handling

```haxe
// Clear any previous errors
CPython.clearError();

// Try to import a non-existent module
var module = CPython.importModule("nonexistent");

if (module == null) {
    if (CPython.hasError()) {
        trace("Error: " + CPython.getErrorString());
        CPython.clearError();
    }
}
```

## Build Configuration

Create an `.hxml` file for your project:

```hxml
-main YourMainClass
-cpp cpp/
-lib linc_cpython

# Optional: Specify Python version paths
-D PYTHON_INCLUDE_PATH=/usr/include/python3.10
-D PYTHON_LIB_PATH=/usr/lib/python3.10/config-3.10-x86_64-linux-gnu
```

## Features

### Interpreter Lifecycle
- `initialize()` - Initialize Python interpreter
- `finalize()` - Finalize Python interpreter
- `isInitialized()` - Check if interpreter is running

### Type Conversions

**From Haxe to Python:**
- `fromInt(value:Int)` - Convert Int to Python int
- `fromFloat(value:Float)` - Convert Float to Python float
- `fromString(value:String)` - Convert String to Python str
- `fromBool(value:Bool)` - Convert Bool to Python bool
- `none()` - Python None

**From Python to Haxe:**
- `toInt(obj)` - Convert Python int to Int
- `toFloat(obj)` - Convert Python float to Float
- `toString(obj)` - Convert Python str to String
- `toBool(obj)` - Convert Python bool to Bool

### Type Checking
- `isNone()`, `isInt()`, `isFloat()`, `isString()`
- `isBytes()`, `isByteArray()`, `isMemoryView()`
- `isList()`, `isDict()`, `isTuple()`, `isSet()`, `isCallable()`

### List Operations
- `listNew()` - Create new list
- `listSize(list)` - Get list length
- `listGetItem(list, index)` - Get item at index
- `listSetItem(list, index, item)` - Set item at index
- `listAppend(list, item)` - Append item to list

### Set Operations
- `setNew()` - Create new set
- `setAdd(set, item)` - Add an item to a set
- `setSize(set)` - Get set size
- `setContains(set, item)` - Check membership

### Slice Operations
- `sliceNew(start, stop, step)` - Create a Python `slice`
- `getSlice(obj, start, stop)` - Read a sequence slice
- `setSlice(obj, start, stop, value)` - Replace a slice
- `delSlice(obj, start, stop)` - Delete a slice range

### Protocol Operations
- `sequenceConcat(left, right)` - Concatenate sequences
- `sequenceRepeat(obj, count)` - Repeat sequences
- `dictValues(dict)` - Get mapping values list
- `dictItems(dict)` - Get mapping items list
- `compareEq/compareLt/...` - Rich comparison helpers
- `isInstance(obj, cls)` - Instance protocol helper
- `isSubclass(derived, cls)` - Subclass protocol helper
- `hashObject(obj)` - Hash protocol helper

### Bytes Operations
- `bytesFromString(value)` - Create Python `bytes`
- `byteArrayFromString(value)` - Create Python `bytearray`
- `memoryViewFromObject(obj)` - Create a `memoryview`
- `bytesSize(obj)` - Get size of a bytes-like object
- `bytesAsString(obj)` - Convert a bytes-like object to Haxe string

### Generic Object Helpers
- `objectSize(obj)` - Get object length/size
- `contains(obj, key)` - Generic membership check
- `typeName(obj)` - Get CPython type name
- `dir(obj)` - Get `dir(...)` result as a Python list

### Dict Operations
- `dictNew()` - Create new dict
- `dictGetItem(dict, key)` - Get item by key object
- `dictGetItemString(dict, key)` - Get item by string key
- `dictSetItem(dict, key, value)` - Set item
- `dictSetItemString(dict, key, value)` - Set item with string key

### Tuple Operations
- `tupleNew(size)` - Create tuple
- `tupleSize(tuple)` - Get tuple length
- `tupleGetItem(tuple, index)` - Get item
- `tupleSetItem(tuple, index, item)` - Set item

### Module & Import
- `importModule(name)` - Import a module
- `getModuleDict(module)` - Get module dictionary
- `getAttr(obj, name)` - Get attribute
- `setAttr(obj, name, value)` - Set attribute

### Function Calling
- `callFunction(callable, args)` - Call with args tuple
- `callFunctionNoArgs(callable)` - Call without arguments
- `callFunctionWithKeywords(callable, args, kwargs)` - Call with kwargs
- `getBuiltin(name)` - Access a builtin callable or object
- `callMethod(obj, name, args)` - Call instance method with args

### Code Execution
- `evalString(expression)` - Evaluate expression
- `execString(command)` - Execute code in `__main__`
- `runSimpleString(command)` - Execute Python code
- `runFile(path)` - Execute a Python source file safely on hxcpp/Windows

### High-Level Helpers
- `PythonImport.init([...])` - Configure import paths like a require/search path helper
- `PythonModules.require(name)` - Import with cache-aware module helpers
- `PythonModules.unload(name)` - Remove a module from `sys.modules`
- `PythonArgs.fromArray(values)` - Build positional args tuples
- `PythonKwargs.fromDynamic(obj)` - Build keyword args from Haxe objects
- `PythonObjects.constructFromModule(...)` - Construct Python objects from Haxe
- `PythonSlice.get/replace/deleteRange(...)` - Haxe-friendly slice helpers
- `PythonDelete.item/attr(...)` - Haxe-friendly deletion helpers
- `PythonContext.enter/exit(...)` - Context manager helpers for `with`-style flows
- `PythonSequence.concatDynamic(...)` - Concatenate Haxe arrays via Python sequence protocol
- `PythonSequence.repeatDynamic(...)` - Repeat Haxe arrays via Python sequence protocol
- `PythonMapping.keys/values/items(...)` - Haxe-friendly mapping protocol helpers
- `PythonCompare.eq/lt/isInstance(...)` - Haxe-friendly comparison and protocol helpers
- `PythonCallback.createDynamic(...)` - Expose a Haxe function as a Python callable
- `PythonCallback.publishDynamic(...)` - Publish a Haxe callback into Python globals
- `PythonBuiltins.len(obj)` - Haxe-friendly builtin wrapper
- `PythonBuiltins.dirStrings(obj)` - Convert `dir()` results to `Array<String>`
- `PythonIter.toDynamicArray(obj)` - Iterate any Python iterable into Haxe values
- `PythonSet.fromArray(values)` - Create Python sets from Haxe arrays
- `PythonBytes.fromBytes(bytes)` - Convert `haxe.io.Bytes` to Python bytes
- `PythonErrors.traceback()` - Fetch formatted traceback text

### Error Handling
- `clearError()` - Clear error indicator
- `hasError()` - Check if error occurred
- `getErrorString()` - Get error message
- `getErrorTraceback()` - Get formatted traceback text

## Automation

- `.github/workflows/ci.yml` runs the Windows hxcpp test suite and builds a `.haxelib.zip` artifact
- `.github/workflows/android-prebuilt.yml` builds Android static CPython libraries and can sync them back into `lib/cpython/`
- `scripts/package-haxelib.sh` creates a package archive using `.haxelibignore`
- `scripts/build-android-python.sh` cross-builds `libpython3.12.a` for Android ABIs using the NDK

### Memory Management
- `incref(obj)` - Increment reference count
- `decref(obj)` - Decrement reference count
- `getRefCount(obj)` - Get reference count

## API Compatibility

This library provides bindings to the Python 3 C API. It is compatible with:
- Python 3.9
- Python 3.10
- Python 3.11
- Python 3.12

## Testing

Run the test suite:

```bash
cd test
haxe test.hxml
./cpp/Test
```

## License

MIT License - See LICENSE.md

## Contributing

Contributions are welcome! Please follow the linc guidelines:
- Maintain consistency with other linc libraries
- Follow the existing code style
- Add tests for new features
- Update documentation

## See Also

- [linc](http://snowkit.github.io/linc/) - Low-level Interfaces Native Collection
- [Python C API Documentation](https://docs.python.org/3/c-api/)
- [hxcpp](https://github.com/HaxeFoundation/hxcpp) - Haxe C++ runtime

## Support

For issues, questions, or contributions:
- GitHub Issues: https://github.com/yourusername/linc_cpython/issues
- Haxe Community: https://community.haxe.org/
