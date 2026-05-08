# 第二章链表（linkList）声明与实现总结

- 来源：`ICE3402P_2.pdf` 第 38-52、55 页
- 目标：把链表模板类的声明、核心实现、复杂度和易错点整理为一份可复习笔记

## 1. 这份实现的核心约定

1. 使用**带头结点**的单链表。
2. `head` 不存有效数据，`head->next` 才是第 1 个元素。
3. 逻辑下标从 1 开始。
4. 链表不需要预分配连续空间，所以 `isFull()` 恒为 `false`。

## 2. 结点与类声明（linkList.h）

### 2.1 结点模板 `node`

```cpp
template <class elemType>
class node {
    friend class linkList<elemType>;
private:
    elemType data;
    node *next;
public:
    node(): next(NULL) {}
    node(const elemType &e, node *N = NULL) { data = e; next = N; }
};
```

要点：
1. `data` 存元素值，`next` 存后继地址。
2. `friend` 让 `linkList` 可访问 `node` 私有成员。

### 2.2 链表模板类 `linkList`

```cpp
template <class elemType>
class linkList {
private:
    node<elemType> *head;
public:
    linkList();
    bool isEmpty() const;
    bool isFull() const { return false; }
    int length() const;
    elemType get(int i) const;
    int find(const elemType &e) const;
    void insert(int i, const elemType &e);
    void remove(int i, elemType &e);
    void reverse();
    void clear();
    ~linkList();
};
```

声明层重点：
1. `find(const elemType &e) const`：只读查找，不改对象。
2. `insert(..., const elemType &e)`：`e` 是只读输入值。
3. `remove(int i, elemType &e)`：把被删元素通过引用参数带回调用者。

## 3. 基础实现

### 3.1 构造与判空

```cpp
template <class elemType>
linkList<elemType>::linkList() {
    head = new node<elemType>();
}

template <class elemType>
bool linkList<elemType>::isEmpty() const {
    return head->next == NULL;
}
```

解释：
1. 构造时先建头结点。
2. 判空只看 `head->next` 是否为空。

## 4. 插入与删除

### 4.1 按位置插入 `insert(i, e)`

```cpp
template <class elemType>
void linkList<elemType>::insert(int i, const elemType &e) {
    if (i < 1) return;
    int j = 0;
    node<elemType> *p = head;
    while (p && j < i - 1) { p = p->next; j++; }
    if (!p) return;
    p->next = new node<elemType>(e, p->next);
}
```

解释：
1. 先找到第 `i-1` 个结点 `p`。
2. 头插到 `p` 后面：新结点 `next` 指向旧 `p->next`。
3. 再改 `p->next` 指向新结点。

关键操作复杂度：
- 已知前驱结点 `p` 时，插入是 $O(1)$。
- 按位序找前驱需要遍历，整体常见是 $O(n)$。

### 4.2 按位置删除 `remove(i, e)`

```cpp
template <class elemType>
void linkList<elemType>::remove(int i, elemType &e) {
    if (i < 1) return;
    node<elemType> *p = head;
    int j = 0;
    while (p && j < i - 1) { p = p->next; j++; }
    if (!p) return;

    node<elemType> *q = p->next;
    if (!q) return;
    e = q->data;
    p->next = q->next;
    delete q;
}
```

解释：
1. 仍先找前驱 `p`。
2. `q = p->next` 是待删结点。
3. 断链 + 释放：`p->next = q->next; delete q;`。

## 5. 查询与访问

### 5.1 `length`

```cpp
template <class elemType>
int linkList<elemType>::length() const {
    int count = 0;
    node<elemType> *p = head->next;
    while (p) { count++; p = p->next; }
    return count;
}
```

### 5.2 `get(i)`

```cpp
template <class elemType>
elemType linkList<elemType>::get(int i) const {
    if (i < 1) throw outOfBound();
    int j = 1;
    node<elemType> *p = head->next;
    while (p && j < i) { p = p->next; j++; }
    if (p) return p->data;
    throw outOfBound();
}
```

### 5.3 `find(e)`

```cpp
template <class elemType>
int linkList<elemType>::find(const elemType &e) const {
    int i = 1;
    node<elemType> *p = head->next;
    while (p) {
        if (p->data == e) break;
        i++; p = p->next;
    }
    if (p) return i;
    return 0;
}
```

复杂度（链表顺序访问特性）：
$$
T_{get}(n)=T_{find}(n)=O(n)
$$

## 6. 清空、头插批量插入、逆置

### 6.1 `clear`
兄弟协同法

```cpp
template <class elemType>
void linkList<elemType>::clear() {
    node<elemType> *p, *q;
    p = head->next;
    head->next = NULL;
    while (p) {
        q = p->next;
        delete p;
        p = q;
    }
}
```

### 6.2 头插法批量插入（课件扩展）

```cpp
template <class elemType>
void linkList<elemType>::insert(const elemType a[], int n) {
    node<elemType> *tmp;
    for (int i = 0; i < n; i++) {
        tmp = new node<elemType>(a[i], head->next);
        head->next = tmp;
    }
}
```

特点：每次都插到表头，最终顺序与原数组相反。

### 6.3 `reverse`（就地逆置）

```cpp
template <class elemType>
void linkList<elemType>::reverse() {
    node<elemType> *p, *q;
    p = head->next;
    head->next = NULL;
    while (p) {
        q = p->next;
        p->next = head->next;
        head->next = p;
        p = q;
    }
}
```

思路：把原链表结点逐个“头插”到新表头，实现逆序。

## 7. 易错点清单

1. 忘记链表是带头结点，导致第 1 个元素定位错误。
2. `insert/remove` 没先找前驱就直接改 `next`。
3. 删除时漏掉 `if (!q) return`，会空指针访问。
4. `remove` 断链后忘记 `delete q`，造成内存泄漏。
5. 批量头插后误以为顺序不变（实际上会反转）。
6. `get/find` 当成随机访问写成 $O(1)$（链表是顺序访问，通常 $O(n)$）。

## 8. 一页速记

- 结构：`head` 头结点 + `next` 串联
- 插入：找前驱 -> 新结点接后继 -> 前驱指向新结点
- 删除：找前驱 -> 保存待删 -> 改链 -> `delete`
- 查找/按位访问：遍历，通常 $O(n)$
- 已知前驱时局部插删：$O(1)$
- 逆置：逐结点头插

