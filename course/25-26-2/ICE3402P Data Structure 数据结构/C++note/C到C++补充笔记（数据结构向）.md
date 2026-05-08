# C 到 C++ 补充笔记（数据结构向）

- 适用课程：ICE3402P Data Structure
- 适用人群：学过 C、尚未系统学过 C++
- 写作原则：不默认已知术语；每个知识点先直观解释，再给语法与示例

## 0. 为什么要补这 7 块
数据结构课程里，你会频繁写“结构 + 操作”的代码。C++ 的这 7 块对应的就是最常用能力：

1. 输入输出：能正确读入测试数据
2. 引用与 `const`：函数参数传递高效且安全
3. 重载与默认参数：接口更清晰
4. `class`：把“数据 + 操作”封装成结构工具
5. STL：减少重复造轮子
6. `auto` 与范围 `for`：写法简洁，少犯类型错误
7. RAII 与智能指针：减少内存泄漏与悬空指针

---

## 1. `cin/cout` 与 `getline`

### 1.1 直观理解
- `cin`：从键盘“拿数据”
- `cout`：向屏幕“送数据”
- `getline`：一次读取一整行文本（含空格）

### 1.2 基本写法
```cpp
#include <iostream>
using namespace std;

int main() {
    int a;
    cout << "请输入 a: ";
    cin >> a;               // 读取一个整数
    cout << "a=" << a << '\n';
    return 0;
}
```

### 1.3 和 C 的对应关系
- `cin >> a;` 对应 `scanf("%d", &a);`
- `cout << a;` 对应 `printf("%d", a);`

### 1.4 常见坑：`cin >>` 后紧跟 `getline`
`cin >> n` 会留下一个换行符在输入缓冲区里，导致下一次 `getline` 读到空行。

```cpp
#include <iostream>
#include <string>
#include <limits>
using namespace std;

int main() {
    int n;
    string line;

    cin >> n;
    cin.ignore(numeric_limits<streamsize>::max(), '\n'); // 清掉残留换行
    getline(cin, line);

    cout << "n=" << n << ", line=" << line << '\n';
}
```

---

## 2. 引用 `&` 与 `const`

### 2.1 直观理解
- 引用（`T&`）就是“别名”，不是新对象。
- `const` 表示“只读承诺”：我不会改它。

### 2.2 参数传递三种方式
```cpp
void f1(int x);            // 值传递：会拷贝
void f2(int& x);           // 引用传递：可修改实参
void f3(const int& x);     // 常量引用：不拷贝且不修改
```

### 2.3 实战建议
- 小类型（`int`, `char`）可值传递
- 大对象（`string`, `vector`）优先 `const T&`
- 需要在函数里改实参时用 `T&`

### 2.4 示例
```cpp
#include <iostream>
#include <vector>
using namespace std;

int sum(const vector<int>& v) { // 不拷贝，不修改
    int s = 0;
    for (int x : v) s += x;
    return s;
}

void addOne(int& x) { x += 1; } // 直接修改外部变量
```

---

## 3. 函数重载与默认参数

### 3.1 直观理解
- 重载：同一个函数名，处理不同参数类型/个数。
- 默认参数：调用时可省略一部分参数。

### 3.2 重载示例
```cpp
int add(int a, int b) { return a + b; }
double add(double a, double b) { return a + b; }
```

### 3.3 默认参数示例
```cpp
int power(int x, int p = 2) {
    int r = 1;
    for (int i = 0; i < p; ++i) r *= x;
    return r;
}
```

### 3.4 注意事项
- 默认参数建议只在声明处写一次
- 默认参数从右向左连续提供，不能“跳着省略”
- 重载和默认参数同时用时，注意避免调用歧义

---

## 4. `class`（构造/析构）

### 4.1 直观理解
`class` 就是把“数据”和“操作这些数据的函数”打包在一起。

### 4.2 最小可用类
```cpp
#include <iostream>
#include <string>
using namespace std;

class Student {
private:
    string name;
    int age;

public:
    Student(const string& n, int a) : name(n), age(a) {} // 构造函数
    ~Student() {}                                         // 析构函数

    void print() const {
        cout << name << " " << age << '\n';
    }
};
```

### 4.3 数据结构课里的用法
- `Stack` 类：成员是数组或链表，方法有 `push/pop/top`
- `Queue` 类：方法有 `enqueue/dequeue/front`
- `Tree` 类：封装遍历、插入、删除

---

## 5. `vector`、`string`、`map`（STL）

### 5.1 `vector`（动态数组）
```cpp
#include <vector>
using namespace std;

vector<int> v;
v.push_back(10);
v.push_back(20);
int n = (int)v.size();
```

适用场景：元素数量不固定、需要按下标访问。

### 5.2 `string`（字符串）
```cpp
#include <string>
using namespace std;

string s = "hello";
s += " world";
```

适用场景：比 C 的字符数组更安全易用。

### 5.3 `map` 与 `unordered_map`
```cpp
#include <map>
#include <unordered_map>
using namespace std;

map<string, int> mp;              // 有序
unordered_map<string, int> ump;   // 无序，平均更快
```

- `map`：键有序，底层常见为平衡树
- `unordered_map`：哈希表，平均查找快

---

## 6. `auto` 与范围 `for`

### 6.1 `auto`
让编译器自动推导类型，减少长类型书写。

```cpp
auto x = 10;       // int
auto y = 3.14;     // double
```

### 6.2 范围 `for`
```cpp
for (auto x : v) {        // 拷贝元素
    cout << x << ' ';
}

for (auto& x : v) {       // 引用，可修改
    x *= 2;
}

for (const auto& x : v) { // 常量引用，不拷贝不修改
    cout << x << ' ';
}
```

实战建议：
- 只读遍历优先 `const auto&`
- 需要修改时用 `auto&`

---

## 7. RAII 与智能指针

### 7.1 直观理解
RAII 的核心是：资源跟对象生命周期绑定。对象离开作用域，资源自动释放。

常见资源：
- 堆内存
- 文件句柄
- 互斥锁

### 7.2 为什么比手写 `new/delete` 更安全
手写 `new/delete` 容易出现：
- 忘记 `delete`（泄漏）
- 重复 `delete`（未定义行为）
- 异常路径没释放

### 7.3 `unique_ptr` 与 `shared_ptr`
```cpp
#include <memory>
using namespace std;

auto p1 = make_unique<int>(42);   // 独占所有权
auto p2 = make_shared<int>(7);    // 共享所有权
```

建议：
- 默认优先 `unique_ptr`
- 确有共享需求再用 `shared_ptr`

---

## 8. 从 C 迁移到 C++ 的常见误区

1. 把 C++ 当“语法更多的 C”
2. 明明可用 `vector/string`，仍坚持手写底层数组管理
3. 大对象总是值传递，造成大量拷贝
4. 忽略 `const`，导致接口语义不清
5. 滥用裸指针而不用 RAII

---

## 9. 一段综合小例子（可直接编译）
```cpp
#include <iostream>
#include <string>
#include <vector>
#include <unordered_map>
#include <limits>
using namespace std;

class Counter {
private:
    unordered_map<string, int> freq;

public:
    void add(const string& word, int delta = 1) {
        freq[word] += delta;
    }

    void print() const {
        for (const auto& kv : freq) {
            cout << kv.first << ": " << kv.second << '\n';
        }
    }
};

int main() {
    int n;
    cin >> n;
    cin.ignore(numeric_limits<streamsize>::max(), '\n');

    Counter c;
    for (int i = 0; i < n; ++i) {
        string line;
        getline(cin, line);
        c.add(line);
    }

    c.print();
    return 0;
}
```

---

## 10. 复习检查单（考前 10 分钟）
- 我能解释 `cin >>` 和 `getline` 的区别吗？
- 我知道什么时候用 `const T&` 吗？
- 我能写出一个含构造函数的简单类吗？
- 我会用 `vector/string/map` 完成基础题吗？
- 我知道 `auto&` 与 `const auto&` 的区别吗？
- 我理解为什么“默认优先 RAII”吗？

---
