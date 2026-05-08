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

    int n;
    if (!(cin >> n)) return 0;

    Node* head = nullptr;
    Node* tail = nullptr;

    for (int i = 0; i < n; i++) {
        int x;
        cin >> x;
        Node* p = new Node(x);
        if (head == nullptr) {
            head = tail = p;
        } else {
            tail->next = p;
            tail = p;
        }
    }

    head = reverseList(head);

    Node* cur = head;
    for (int i = 0; i < n; i++) {
        if (i > 0) cout << ' ';
        cout << cur->val;
        cur = cur->next;
    }
    cout << '\n';

    freeList(head);
    return 0;
}
