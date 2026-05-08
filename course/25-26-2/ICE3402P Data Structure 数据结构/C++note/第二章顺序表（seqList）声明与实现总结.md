# 第二章顺序表（seqList）声明与实现总结

- 来源：`ICE3402P_2.pdf` 第 13-23 页
- 目标：把顺序表的类声明、核心实现和设计意图放在一份可复习笔记里

## 1. 这份实现的核心约定

1. 使用动态数组存储，成员指针是 `elem`。
2. 下标从 `1` 开始存有效数据，`elem[0]` 作为哨兵位（主要服务 `find`）。
3. `len` 是当前有效元素个数，`maxSize` 是当前最大可用下标（不是数组申请参数原值）。
4. 空间不够时调用 `doubleSpace()` 扩容。

## 2. 类声明（seqList.h）

```cpp
template <class elemType>
class seqList {
private:
    elemType *elem;
    int len;
    int maxSize;
    void doubleSpace();

public:
    seqList(int size = INITSIZE);
    bool isEmpty() const;
    bool isFull() const;
    int length() const;
    elemType get(int i) const;
    int find(const elemType &e) const;
    void insert(int i, const elemType &e);
    void remove(int i);
    void clear();
    ~seqList();
};
```

### 声明层重点

1. `doubleSpace()` 在 `private`：内部维护函数，不给外部直接调用。
2. `find(const elemType &e) const`：
   - 参数 `const &` 表示“只读 + 避免拷贝大对象”
   - 末尾 `const` 表示“不修改顺序表对象本身”
3. `insert(int i, const elemType &e)` 里 `e` 是输入值来源，真正被修改的是顺序表内部数组。

## 3. 构造与扩容实现

### 3.1 构造函数

```cpp
template <class elemType>
seqList<elemType>::seqList(int size) {
    elem = new elemType[size];
    if (!elem) throw illegalSize();
    maxSize = size - 1;
    len = 0;
}
```

解释：
1. 分配动态数组。
2. 预留 `elem[0]` 给哨兵，所以有效容量按 `size - 1` 计。
3. 初始长度为 0。

### 3.2 扩容函数 `doubleSpace`

```cpp
template <class elemType>
void seqList<elemType>::doubleSpace() {
    elemType *tmp = new elemType[2 * maxSize];
    if (!tmp) throw illegalSize();
    for (int i = 1; i <= len; i++) tmp[i] = elem[i];
    delete[] elem;
    elem = tmp;
    maxSize = 2 * maxSize - 1;
}
```

解释：
1. 申请更大新空间。
2. 复制有效数据区（`1..len`）。
3. 释放旧空间并切换指针。
4. 更新容量信息。

## 4. 查询与访问

### 4.1 `find`（哨兵优化）

```cpp
template <class elemType>
int seqList<elemType>::find(const elemType &e) const {
    int i;
    elem[0] = e;
    for (i = len; elem[i] != e; i--);
    return i;
}
```

说明：
1. 先把哨兵位设成目标值。
2. 从后往前找，保证一定能停（最差停在 `i=0`）。
3. 返回下标：`0` 表示未找到。

复杂度：
$$
T_{find}(n)=O(n)
$$

### 4.2 `get`

```cpp
template <class elemType>
elemType seqList<elemType>::get(int i) const {
    if (i < 1 || i > len) throw outOfBound();
    return elem[i];
}
```

说明：先做边界检查，再返回第 `i` 个元素。

## 5. 插入与删除

### 5.1 `insert`

```cpp
template <class elemType>
void seqList<elemType>::insert(int i, const elemType &e) {
    if (i < 1 || i > len + 1) return;
    if (len == maxSize) doubleSpace();
    for (int k = len + 1; k > i; k--) elem[k] = elem[k - 1];
    elem[i] = e;
    len++;
}
```

说明：
1. 位置非法直接返回。
2. 满了先扩容。
3. 从后往前搬移，避免覆盖原数据。
4. 写入新值并更新长度。

复杂度：
$$
T_{insert}(n)=O(n)
$$

### 5.2 `remove`

```cpp
template <class elemType>
void seqList<elemType>::remove(int i) {
    if (i < 1 || i > len) return;
    for (int k = i; k < len; k++) elem[k] = elem[k + 1];
    len--;
}
```

说明：删除后把后续元素整体前移一位。

复杂度：
$$
T_{remove}(n)=O(n)
$$

## 6. 易错点清单（按这份实现）

1. 忘记 `elem[0]` 是哨兵位，导致下标和容量理解混乱。
2. `insert` 搬移方向写反（应从后往前）。
3. `doubleSpace` 复制范围写成 `0..len`，破坏哨兵语义。
4. `find`/`get` 的 `const` 写法漏掉，导致常对象无法调用。
5. 只记“改了表”，忽略“参数 `e` 是只读输入，不是修改目标”。

## 7. 一页速记

- 存储：动态数组 + 哨兵位 `elem[0]`
- 状态：`len`（当前长度），`maxSize`（最大可用下标）
- 扩容：`doubleSpace`（私有）
- 查询：`find(const T& e) const`，失败返回 `0`
- 插入：先扩容，后移，再赋值
- 删除：前移覆盖
- 复杂度：查找/插入/删除均为 $O(n)$

