# C++ 文件开头常见写法与原理

- 适用课程：ICE3402P Data Structure
- 目标：理解 `.cpp` 文件最前面常见几行代码的作用、替代写法与注意事项

## 1. 最常见开头示例

```cpp
#include <iostream>
#define INTSIZE 100
using namespace std;
```

这三行分别解决：
- `#include`：把需要的库声明引入进来
- `#define`：定义预处理宏常量
- `using namespace std;`：简化标准库名字书写

---

## 2. `#include` 是什么

## 2.1 作用
`#include` 是预处理指令，编译前会把头文件内容“展开”到当前位置。

```cpp
#include <iostream>
```

上面这句让你可以使用：
- `std::cout`
- `std::cin`
- `std::endl`

## 2.2 两种写法

### 写法A：尖括号
```cpp
#include <vector>
```
- 常用于标准库或系统头文件

### 写法B：双引号
```cpp
#include "my_header.h"
```
- 常用于自己项目里的头文件
- 会优先在当前工程路径找

## 2.3 常见头文件速查
- `#include <iostream>`：输入输出
- `#include <vector>`：动态数组
- `#include <string>`：字符串
- `#include <algorithm>`：排序、`max`、`min`
- `#include <queue>`：队列/优先队列
- `#include <stack>`：栈
- `#include <map>` / `<unordered_map>`：映射
- `#include <set>` / `<unordered_set>`：集合

---

## 3. `#define INTSIZE 100` 是什么

## 3.1 作用
`#define` 也是预处理指令，用于“文本替换”。

```cpp
#define INTSIZE 100
```

之后代码里所有 `INTSIZE` 会在编译前替换成 `100`。

## 3.2 优点与风险
优点：
- 写法短，老代码常见

风险：
- 不是类型安全的常量
- 不受作用域约束
- 调试时不直观

## 3.3 更推荐的现代写法

### 写法A：`const`
```cpp
const int INTSIZE = 100;
```

### 写法B：`constexpr`
```cpp
constexpr int INTSIZE = 100;
```

建议：
- 数值常量优先 `const/constexpr`
- `#define` 更常用于条件编译或头文件保护

## 3.4 你问的这两行：`#ifndef BTREE_H_INCLUDED` 和 `#define BTREE_H_INCLUDED`

这两行通常出现在头文件（`.h`）开头，配合文件末尾的 `#endif`，构成**头文件保护（include guard）**：

```cpp
#ifndef BTREE_H_INCLUDED
#define BTREE_H_INCLUDED

// 头文件正文（类声明、函数声明等）

#endif
```

作用：防止同一个头文件在一次编译中被重复包含，避免“重复定义”错误。

### 为什么需要它
比如 `A.h` 和 `B.h` 都 `#include "BTree.h"`，或者有多层嵌套包含时，编译器可能多次读到同一份声明。  
没有保护时，容易报错（重定义、重复声明冲突）。

### 这两行各自做了什么
- `#ifndef BTREE_H_INCLUDED`：如果宏 `BTREE_H_INCLUDED` 还没定义，才继续往下处理。
- `#define BTREE_H_INCLUDED`：立刻把这个宏定义出来，标记“这个头文件已经进来过了”。
- 下次再包含到这个头文件时，`#ifndef` 条件不成立，会直接跳到 `#endif`，正文不再重复展开。

### 宏名怎么取
- 不是必须叫 `BTREE_H_INCLUDED`，但要“全局唯一、语义清楚”。
- 常见风格：`文件名_路径_H_INCLUDED`，例如 `BTREE_H_INCLUDED`、`PROJECT_BTREE_H`。

### 和 `#pragma once` 的关系
`#pragma once` 也是防重复包含，写法更短：

```cpp
#pragma once
```

课堂和跨平台教材里常优先讲 `#ifndef/#define/#endif`，因为它是标准预处理机制，通用性更强。

---

## 4. `using namespace std;` 是什么

## 4.1 作用
把 `std` 命名空间里的名字整体引入当前作用域，之后可直接写：

```cpp
cout << "hello";
```

而不是：

```cpp
std::cout << "hello";
```

## 4.2 为什么课堂代码常写它
- 初学阶段更简洁
- 减少 `std::` 视觉负担

## 4.3 为什么工程里常谨慎使用
- 名字冲突风险更高（尤其大型项目）
- 可读性和可维护性会下降

## 4.4 更稳的替代方式

### 方式1：显式 `std::`
```cpp
std::cout << "hello" << std::endl;
```

### 方式2：按需引入
```cpp
using std::cout;
using std::cin;
using std::endl;
```

---

## 5. 竞赛/作业中常见文件头模板

## 5.1 基础模板（课程作业够用）
```cpp
#include <iostream>
#include <vector>
#include <string>
using namespace std;

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    return 0;
}
```

## 5.2 为什么常加这两句
```cpp
ios::sync_with_stdio(false);
cin.tie(nullptr);
```
- 提升 `cin/cout` 输入输出速度
- 在大输入场景更稳定

---

## 6. 常见误区

1. 只写了 `#include <iostream>` 却使用了 `vector`（应再引入 `<vector>`）
2. `#define` 滥用为所有常量定义
3. 在头文件（`.h`）里写 `using namespace std;` 导致全项目污染
4. 把 `#include "..."` 和 `#include <...>` 混用不当导致找不到头文件

---

## 7. 一页速记
- `#include`：引入声明，决定“能用哪些库功能”。
- `#define`：预处理替换，老写法常见，但常量更推荐 `const/constexpr`。
- `using namespace std;`：写起来快，但有命名冲突风险。
- 小项目/课堂可用 `using namespace std;`，工程项目建议显式 `std::` 或按需 `using`。
