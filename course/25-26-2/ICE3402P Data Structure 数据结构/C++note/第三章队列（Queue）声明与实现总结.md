# 第三章队列（Queue）声明与实现总结

- 来源：`ICE3402P_3.pdf` 第 55-79 页（队列部分）
- 目标：整理第三章队列的抽象定义、顺序循环队列与链式队列的声明与实现

## 1. 队列的抽象定义

队列遵循先进先出（FIFO）。

典型操作：
- `initialize`
- `isEmpty`
- `isFull`
- `front`
- `enQueue`
- `deQueue`
- `destroy`

## 2. 顺序循环队列 `seqQueue`（数组实现）

### 2.1 类声明要点

```cpp
template <class elemType>
class seqQueue {
private:
    elemType *array;
    int maxSize;
    int Front, Rear;
    void doubleSpace();

public:
    seqQueue(int size = 10);
    bool isEmpty();
    bool isFull();
    elemType front();
    void enQueue(const elemType &x);
    void deQueue();
    ~seqQueue();
};
```

关键成员含义：
1. `Front`：队头下标（读头元素位置）。
2. `Rear`：队尾“下一可写位置”下标。
3. 用循环数组避免频繁整体搬移。

### 2.2 构造与判空判满

```cpp
seqQueue(int size) {
    array = new elemType[size];
    if (!array) throw illegalSize();
    maxSize = size;
    Front = Rear = 0;
}

bool isEmpty() { return Front == Rear; }

bool isFull() { return (Rear + 1) % maxSize == Front; }
```

说明：
1. 该实现采用“空一格”策略区分空和满。
2. 所以最多只能存 `maxSize - 1` 个元素。

判定公式：
$$
\text{empty} \iff Front = Rear
$$

$$
\text{full} \iff (Rear + 1) \bmod maxSize = Front
$$

### 2.3 `front` / `enQueue` / `deQueue`

```cpp
elemType front() {
    if (isEmpty()) throw outOfBound();
    return array[Front];
}

void enQueue(const elemType &x) {
    if (isFull()) doubleSpace();
    array[Rear] = x;
    Rear = (Rear + 1) % maxSize;
}

void deQueue() {
    if (isEmpty()) throw outOfBound();
    Front = (Front + 1) % maxSize;
}
```

复杂度（均摊）：
$$
T_{front}=T_{deQueue}=O(1),\quad T_{enQueue}=O(1)\text{ (amortized)}
$$

触发扩容的单次 `enQueue`：
$$
T_{enQueue}=O(n)
$$

## 3. 链式队列 `linkQueue`（链表实现）

### 3.1 结点与类声明

```cpp
template <class elemType>
class Node {
    friend class linkQueue<elemType>;
private:
    elemType data;
    Node *next;
public:
    Node() { next = NULL; }
    Node(const elemType &x, Node *p = NULL) { data = x; next = p; }
};

template <class elemType>
class linkQueue {
private:
    Node<elemType> *Front, *Rear;
public:
    linkQueue() { Front = Rear = NULL; }
    bool isEmpty() { return !Front; }
    bool isFull() { return false; }
    elemType front();
    void enQueue(const elemType &x);
    void deQueue();
    ~linkQueue();
};
```

设计解释：
1. `Front` 指向队头结点，`Rear` 指向队尾结点。
2. 空队时二者都为 `NULL`。
3. 不需连续空间，`isFull()` 常直接返回 `false`（忽略系统内存耗尽极端情况）。

### 3.2 关键实现逻辑

```cpp
elemType front() {
    if (isEmpty()) throw outOfBound();
    return Front->data;
}

void enQueue(const elemType &x) {
    if (!Rear)
        Front = Rear = new Node<elemType>(x);
    else {
        Rear->next = new Node<elemType>(x);
        Rear = Rear->next;
    }
}

void deQueue() {
    if (isEmpty()) throw outOfBound();
    Node<elemType> *tmp = Front;
    Front = Front->next;
    delete tmp;
    if (!Front) Rear = NULL;
}

~linkQueue() {
    Node<elemType> *p = Front;
    while (p) {
        Front = Front->next;
        delete p;
        p = Front;
    }
}
```

复杂度：
$$
T_{front}=T_{enQueue}=T_{deQueue}=O(1)
$$

## 4. 顺序循环队列 vs 链式队列

1. 顺序循环队列：
- 优点：内存连续，访问局部性好。
- 注意：有“空一格”容量损失，且扩容时可能搬移。

2. 链式队列：
- 优点：不依赖连续空间，入队/出队稳定 `O(1)`。
- 注意：每个结点有指针开销，内存局部性较弱。

## 5. 队列操作的本质语义

1. `front`：读队头，不出队。  
2. `enQueue`：从队尾插入。  
3. `deQueue`：从队头删除。  

这三点共同保证 FIFO。

## 6. 易错点清单（第三章队列高频）

1. 把 `Rear` 当成“最后一个元素下标”，和“下一可写位置”语义混淆。
2. 循环队列忘记取模：`(index + 1) % maxSize`。
3. `isFull` 条件写错成 `Rear == Front`（那是空队条件）。
4. `deQueue` 后队列变空时没把 `Rear` 置回 `NULL`（链式实现）。
5. `front()` 在空队列上调用未做异常/边界处理。
6. 忘记析构释放链式队列结点，导致内存泄漏。

## 7. 一页速记

- 队列特性：FIFO
- 顺序循环队列：
  - 空：`Front == Rear`
  - 满：`(Rear + 1) % maxSize == Front`
  - 需要取模前进
- 链式队列：
  - `Front` 读头，`Rear` 追尾
  - 出队删头，入队接尾
- 常见复杂度：`front/enQueue/deQueue` 常为 $O(1)$（顺序队列扩容为均摊）

