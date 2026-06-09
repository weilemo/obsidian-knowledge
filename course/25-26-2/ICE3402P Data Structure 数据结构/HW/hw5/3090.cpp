#include <iostream>
#include <vector>
using namespace std;

struct Node {
    int val;
    Node* left;
    Node* right;
    Node(int v) : val(v), left(nullptr), right(nullptr) {}
};

void insertBST(Node*& root, int x) {
    if (root == nullptr) {
        root = new Node(x);
        return;
    }

    Node* cur = root;
    while (true) {
        if (x < cur->val) {
            if (cur->left == nullptr) {
                cur->left = new Node(x);
                return;
            }
            cur = cur->left;
        } else {
            if (cur->right == nullptr) {
                cur->right = new Node(x);
                return;
            }
            cur = cur->right;
        }
    }
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, k;
    cin >> n >> k;

    Node* root = nullptr;
    for (int i = 0; i < n; i++) {
        int x;
        cin >> x;
        insertBST(root, x);
    }

    vector<int> path;
    Node* cur = root;
    bool found = false;

    while (cur != nullptr) {
        path.push_back(cur->val);
        if (cur->val == k) {
            found = true;
            break;
        } else if (k < cur->val) {
            cur = cur->left;
        } else {
            cur = cur->right;
        }
    }

    if (!found) path.push_back(-1);

    for (int i = 0; i < (int)path.size(); i++) {
        if (i) cout << ' ';
        cout << path[i];
    }
    cout << '\n';

    return 0;
}
