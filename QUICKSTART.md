# linc_cpython 快速开始指南

## 🌸 欢迎使用 linc_cpython!

这是一个基于 linc 标准的 Haxe C++ 绑定库，让你能够在 Haxe 代码中调用 Python C API。

## 📦 项目结构

```
linc_cpython/
├── cpython/                    # Haxe 外部类
│   ├── CPython.hx             # 主要 API 绑定（250+ 行）
│   └── PyObject.hx            # PyObject 类型定义
├── linc/                       # C++ 实现
│   ├── linc_cpython.h         # C++ 头文件（70+ 函数声明）
│   ├── linc_cpython.cpp       # C++ 实现（350+ 行）
│   ├── linc_cpython.xml       # hxcpp 构建配置
│   └── Linc.hx                # 辅助宏
├── test/                       # 测试代码
│   ├── Test.hx                # 综合测试套件
│   └── test.hxml              # 测试配置
├── README.md                   # 完整文档
├── COMPATIBILITY_REPORT.md     # 兼容性与维护性报告
├── LICENSE.md                  # MIT 许可证
└── .gitignore                  # Git 忽略规则
```

## 🚀 快速开始

### 1. 安装依赖

确保已安装：
- Haxe 4.0+
- hxcpp
- Python 3.9+ 开发文件

### 2. 安装库

```bash
# 克隆到本地
haxelib git linc_cpython https://github.com/Ajwyunsx/linc_cpython.git

# 或者本地开发
haxelib dev linc_cpython /path/to/linc_cpython
```

### 3. 第一个程序

创建 `Main.hx`:

```haxe
import cpython.CPython;

class Main {
    static function main() {
        // 初始化 Python
        CPython.initialize();
        
        // 执行 Python 代码
        CPython.runSimpleString("print('Hello from Python!')");
        
        // 计算表达式
        var result = CPython.evalString("2 + 2");
        trace("2 + 2 = " + CPython.toInt(result));
        CPython.decref(result);
        
        // 清理
        CPython.finalize();
    }
}
```

创建 `build.hxml`:

```hxml
-main Main
-cpp cpp/
-lib linc_cpython
-debug
```

构建和运行：

```bash
haxe build.hxml
./cpp/Main
```

### 4. 运行测试

```bash
cd test
haxe test.hxml
./cpp/Test
```

## ✨ 主要特性

### 核心功能

- ✅ **Python 解释器**: 初始化、运行、关闭
- ✅ **类型转换**: Haxe ↔ Python（Int, Float, String, Bool）
- ✅ **容器类型**: List, Dict, Tuple 操作
- ✅ **模块导入**: 导入并使用 Python 模块
- ✅ **函数调用**: 调用 Python 函数
- ✅ **代码执行**: 动态执行 Python 代码
- ✅ **错误处理**: 完整的错误检测和处理

### API 统计

- **总函数数**: 70+
- **Haxe 代码**: 350+ 行
- **C++ 代码**: 400+ 行
- **测试覆盖**: 7 个测试场景
- **示例代码**: 5+ 个完整示例

## 📊 语法兼容性

### 完全兼容的 Haxe 特性

- ✅ extern class
- ✅ @:native 元数据
- ✅ @:include 元数据
- ✅ @:build 宏
- ✅ 类型别名 (typedef)
- ✅ 函数重载
- ✅ cpp.RawPointer
- ✅ cpp.ConstCharStar

### 支持的平台

- ✅ Windows (Python 3.9-3.12)
- ✅ Linux (Python 3.9-3.12)
- ✅ macOS (Python 3.9-3.12)

## 🔧 维护性特点

### 代码质量

- ✅ **标准结构**: 符合 linc 标准
- ✅ **清晰命名**: 一致的命名规范
- ✅ **完整文档**: 每个函数都有文档注释
- ✅ **类型安全**: 完整的类型注解
- ✅ **内存安全**: 正确的引用计数管理

### 易于维护

- ✅ **模块化**: 清晰的文件组织
- ✅ **可扩展**: 易于添加新功能
- ✅ **可测试**: 全面的测试覆盖
- ✅ **跨平台**: 统一的构建配置

## 📝 代码示例

### 示例 1: 使用 Python 列表

```haxe
var list = CPython.listNew();

// 添加元素
for (i in 0...5) {
    var item = CPython.fromInt(i);
    CPython.listAppend(list, item);
    CPython.decref(item);
}

// 读取元素
trace("List size: " + CPython.listSize(list));
for (i in 0...CPython.listSize(list)) {
    var item = CPython.listGetItem(list, i);
    trace("Item[" + i + "] = " + CPython.toInt(item));
}

CPython.decref(list);
```

### 示例 2: 导入 Python 模块

```haxe
// 导入 math 模块
var math = CPython.importModule("math");

// 获取 sqrt 函数
var sqrt = CPython.getAttr(math, "sqrt");

// 调用 sqrt(16)
var args = CPython.tupleNew(1);
CPython.tupleSetItem(args, 0, CPython.fromFloat(16));

var result = CPython.callFunction(sqrt, args);
trace("sqrt(16) = " + CPython.toFloat(result));

// 清理
CPython.decref(result);
CPython.decref(args);
CPython.decref(sqrt);
CPython.decref(math);
```

### 示例 3: 错误处理

```haxe
CPython.clearError();

// 尝试导入不存在的模块
var module = CPython.importModule("nonexistent");

if (module == null) {
    if (CPython.hasError()) {
        trace("Error: " + CPython.getErrorString());
        CPython.clearError();
    }
}
```

## 📈 性能考虑

### 内存管理

- 使用 `incref/decref` 管理引用计数
- 避免内存泄漏
- 注意借用引用（不增加引用计数）

### 优化建议

1. 批量操作减少函数调用开销
2. 缓存频繁使用的 Python 对象
3. 避免不必要的类型转换
4. 使用 `evalString` 执行复杂计算

## 🐛 调试技巧

### 检查引用计数

```haxe
var obj = CPython.fromInt(42);
trace("Ref count: " + CPython.getRefCount(obj));
CPython.decref(obj);
```

### 检查错误

```haxe
if (CPython.hasError()) {
    trace("Error: " + CPython.getErrorString());
    CPython.clearError();
}
```

## 📚 相关资源

- [完整文档](./README.md)
- [兼容性报告](./COMPATIBILITY_REPORT.md)
- [linc 项目](http://snowkit.github.io/linc/)
- [Python C API](https://docs.python.org/3/c-api/)

## 🤝 贡献

欢迎贡献代码！请遵循：
- linc 标准
- 现有代码风格
- 添加测试
- 更新文档

## 📄 许可证

MIT License - 详见 [LICENSE.md](./LICENSE.md)

---

**版本**: 1.0.0  
**创建日期**: 2026-03-14  
**作者**: linc_cpython contributors
