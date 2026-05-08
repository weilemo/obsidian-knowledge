# 模板类链接问题与文件组织（seqlist）

- 场景来源：`seqList` 模板类（`seqList.h / seqList.cpp / main.cpp`）
- 关键问题：为什么常规分文件写法会触发 `undefined reference`

## 1. 先看常规写法

非模板类通常这样组织：
- `seqlist.h`：类声明
- `seqlist.cpp`：成员函数定义
- `main.cpp`：`#include "seqlist.h"` 并使用

这对普通类通常没问题，因为定义已经在 `.cpp` 编译成目标代码，链接时可找到。

## 2. 模板类为什么会出链接问题

`seqList` 是模板类：
```cpp
template <class elemType>
class seqList { ... };
```

模板代码不是“先统一编译好所有类型版本”，而是“在使用点实例化”。
例如在 `main.cpp` 里写 `seqList<int>` 时，编译器需要同时看到模板定义，才能生成 `seqList<int>` 的成员函数实体。

如果模板实现只放在 `seqlist.cpp`，而 `main.cpp` 只看到声明，就可能出现：
- 编译阶段看起来通过
- 链接阶段报 `undefined reference`

本质：声明在，所需模板实例的定义不在可见范围内。

## 3. 这页课件给出的三种办法

### 方法1（推荐）
- 不单独使用 `seqlist.cpp`
- 把模板类成员函数实现放回 `seqlist.h`

优点：模板实现对使用点可见，最稳定、最常见。

### 方法2（可用但不优雅）
- 保留 `seqlist.cpp`
- `main.cpp` 里除了 `#include "seqlist.h"`，再 `#include "seqlist.cpp"`

本质仍是“让实现在使用点可见”。

### 方法3（演示用）
- `seqlist.h`、`seqlist.cpp` 都不用
- 声明和实现都写在 `main.cpp`

适合课堂演示，小工程临时验证，工程实践不推荐。

## 4. 与上文知识点的关联

- 你前面问到的 `undefined reference`，这里正是典型来源之一。
- 与 `#include` 规则相关：模板实现必须被“看见”。
- 与“类模板写法”相关：`template <class T>` 的成员函数类外定义也要放到可见处。

## 5. 一页速记

- 普通类：`h + cpp` 分离通常可行。
- 模板类：声明和实现通常都放头文件。
- `undefined reference` 常见于“模板实现不可见”。
- 课内最稳妥做法：模板类统一写在 `.h` 中。

