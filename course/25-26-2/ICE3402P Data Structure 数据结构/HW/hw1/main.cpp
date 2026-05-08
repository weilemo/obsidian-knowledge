#include <iostream>

using namespace std;

struct Node {
    int val;
    Node* next;
    Node(int v) {
        val = v;
        next = nullptr;
    }
};

Node* reverseList(Node* head) {
    Node* pre = nullptr;
    Node* cur = head;
    while (cur != nullptr) {
        Node* nxt = cur->next;
        cur->next = pre;
        pre = cur;
        cur = nxt;
    }
    return pre;
}

void freeList(Node* head) {
    while (head != nullptr) {
        Node* nxt = head->next;
        delete head;
        head = nxt;
    }
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    int m, n;
    if (!(cin >> m >> n)) return 0;

    // 建立第一个数的链表
    Node* aHead = nullptr;
    Node* aTail = nullptr;
    for (int i = 0; i < m; i++) {
        int x;
        cin >> x;
        Node* p = new Node(x);
        if (aHead == nullptr) {
            aHead = aTail = p;
        } else {
            aTail->next = p;
            aTail = p;
        }
    }

    // 建立第二个数的链表
    Node* bHead = nullptr;
    Node* bTail = nullptr;
    for (int i = 0; i < n; i++) {
        int x;
        cin >> x;
        Node* p = new Node(x);
        if (bHead == nullptr) {
            bHead = bTail = p;
        } else {
            bTail->next = p;
            bTail = p;
        }
    }

    // 从低位开始相加：先逆置两个链表
    aHead = reverseList(aHead);
    bHead = reverseList(bHead);

    Node* cHead = nullptr;
    Node* cTail = nullptr;
    int carry = 0;

    Node* pa = aHead;
    Node* pb = bHead;

    while (pa != nullptr || pb != nullptr || carry != 0) {
        int sum = carry;
        if (pa != nullptr) {
            sum += pa->val;
            pa = pa->next;
        }
        if (pb != nullptr) {
            sum += pb->val;
            pb = pb->next;
        }

        Node* p = new Node(sum % 10);
        carry = sum / 10;

        if (cHead == nullptr) {
            cHead = cTail = p;
        } else {
            cTail->next = p;
            cTail = p;
        }
    }

    // 结果再逆置回正常顺序
    cHead = reverseList(cHead);

    bool first = true;
    Node* pc = cHead;
    while (pc != nullptr) {
        if (!first) cout << ' ';
        cout << pc->val;
        first = false;
        pc = pc->next;
    }
    cout << '\n';

    freeList(aHead);
    freeList(bHead);
    freeList(cHead);
    return 0;
}
