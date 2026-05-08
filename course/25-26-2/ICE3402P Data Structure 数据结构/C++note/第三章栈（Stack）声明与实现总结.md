# 第三章栈（Stack）声明与实现总结

- 来源：`ICE3402P_3.pdf` 第 1-51 页（聚焦栈；第 55 页后转入队列，不纳入本笔记）
- 目标：整理第三章中“顺序栈 + 链式栈 + 应用”的声明、实现与算法主线

## 1. 栈的抽象定义

栈是线性结构，遵循后进先出（LIFO）。

典型操作：
- `initialize`
- `isEmpty`
- `isFull`
- `top`
- `push`
- `pop`
- `destroy`

## 2. 顺序栈 `seqStack`（数组实现）

### 2.1 类声明要点

```cpp
template <class elemType>
class seqStack {
private:
    elemType *array;
    int Top;
    int maxSize;
    void doubleSpace();

public:
    seqStack(int initSize = 100);
    bool isEmpty() { return Top == -1; }
    bool isFull() { return Top == maxSize - 1; }
    elemType top();
    void push(const elemType &e);
    void pop();
    ~seqStack() { delete[] array; }
};
```

设计解释：
1. `Top` 指向当前栈顶下标，空栈时 `Top = -1`。
2. `doubleSpace()` 是内部扩容工具，放在 `private`。
3. `push(const elemType &e)` 用只读引用，减少大对象拷贝。

### 2.2 关键实现逻辑

```cpp
seqStack(int initSize) {
    array = new elemType[initSize];
    if (!array) throw illegalSize();
    Top = -1;
    maxSize = initSize;
}

elemType top() {
    if (isEmpty()) throw outOfBound();
    return array[Top];
}

void push(const elemType &e) {
    if (isFull()) doubleSpace();
    array[++Top] = e;
}

void pop() {
    if (Top == -1) throw outOfBound();
    Top--;
}
```

复杂度（均摊视角）：
$$
T_{top}=T_{pop}=O(1),\quad T_{push}=O(1)\text{ (amortized)}
$$

单次触发扩容时：
$$
T_{push}=O(n)
$$

## 3. 链式栈 `linkStack`（链表实现）

### 3.0 实现约定：栈顶放在链表头部

本章链式栈采用“`Top` 指向链表第一个结点”的约定。这样做的直接好处是：

1. `push` 不用遍历，直接头插即可。
2. `pop` 不用遍历，直接删除头结点即可。
3. 两个核心操作都保持为常数时间。

对应关系：
- 栈顶 = `Top` 指向的结点
- 次栈顶 = `Top->next` 指向的结点
- 空栈 = `Top == NULL`

### 3.1 结点与类声明

```cpp
template <class elemType>
class Node {
    friend class linkStack<elemType>;
private:
    elemType data;
    Node *next;
public:
    Node() { next = NULL; }
    Node(const elemType &x, Node *p = NULL) { data = x; next = p; }
};

template <class elemType>
class linkStack {
private:
    Node<elemType> *Top;
public:
    linkStack() { Top = NULL; }
    bool isEmpty() { return Top == NULL; }
    bool isFull() { return false; }
    elemType top();
    void push(const elemType &e);
    void pop();
    ~linkStack();
};
```

### 3.2 关键实现逻辑

```cpp
elemType top() {
    if (!Top) throw outOfBound();
    return Top->data;
}

void push(const elemType &e) {
    Top = new Node<elemType>(e, Top);
}

void pop() {
    if (!Top) throw outOfBound();
    Node<elemType> *tmp = Top;
    Top = Top->next;
    delete tmp;
}

~linkStack() {
    Node<elemType> *tmp;
    while (Top) {
        tmp = Top;
        Top = Top->next;
        delete tmp;
    }
}
```

`push` 里新结点的 `next` 之所以设为旧 `Top`，就是为了把“旧栈顶”挂到“新栈顶”后面，保持原有栈元素不丢失，并满足 LIFO。

复杂度：
$$
T_{top}=T_{push}=T_{pop}=O(1)
$$

## 4. 顺序栈 vs 链式栈

1. 顺序栈：空间连续，缓存友好；但扩容时有搬移成本。
2. 链式栈：单次操作稳定 `O(1)`；但结点有指针额外开销，局部性较弱。
3. 两者都遵循同一抽象操作接口，核心差别在存储方式。

## 5. 第三章应用主线

### 5.1 字符逆序输出（栈的直接应用）

流程：
1. 逐字符入栈。
2. 再不断 `top+pop` 输出。

结果：输出顺序与输入相反。

### 5.2 括号匹配（`(` 与 `)`）

规则：
1. 遇到 `(` 入栈。
2. 遇到 `)`：若栈空则报错；否则弹出一个 `(`。
3. 扫描结束后若栈不空，说明左括号多余。

复杂度：
$$
T(n)=O(n)
$$

### 5.3 后缀表达式求值 `calcPost`

规则：
1. 扫描后缀串。
2. 遇操作数入栈。
3. 遇操作符弹出两个数 `op1, op2`，计算 `op1 \;op\; op2`，结果入栈。
4. 扫描结束，栈顶即结果。

复杂度：
$$
T(n)=O(n)
$$

### 5.4 中缀转后缀 `inToSufForm`

核心：用“运算符栈”维护优先级和括号。

规则摘要：
1. 数字直接输出到后缀串。
2. `(` 直接入栈。
3. `)` 触发弹栈到 `(` 为止（`(` 不输出）。
4. 遇 `* /`：弹出栈中同优先级运算符后再入栈。
5. 遇 `+ -`：弹出直到 `(` 或栈底标记 `#`。
6. 扫描结束，把栈内剩余运算符依次输出。

复杂度：
$$
T(n)=O(n)
$$

## 6. 易错点清单（第三章高频）

1. 空栈时直接 `top/pop`，未做边界检查。
2. 忘记链式栈析构释放所有结点，导致内存泄漏。
3. 后缀求值时操作数顺序写反（应先弹 `op2`，再弹 `op1`）。
4. 中缀转后缀时忽略 `(` 和 `#` 的停止条件，导致多弹或死循环。
5. 顺序栈扩容后未正确维护 `maxSize` 与 `Top`。
6. 把“触发扩容的单次 `push` 是 `O(n)`”和“均摊 `push` 是 `O(1)`”混为一谈。

## 7. 一页速记

- 栈特性：LIFO
- 顺序栈：`Top=-1` 空；`push` 可能触发扩容
- 链式栈：`Top` 指向栈顶结点；`push/pop` 改 `Top`
- 括号匹配：左括号入栈，右括号配对弹栈
- 后缀求值：操作数入栈，操作符弹两次再压回
- 中缀转后缀：运算符栈 + 优先级 + 括号控制
