#include <iostream>
#include <stack>
#include <vector>

using namespace std;

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    vector<long long> val(n + 1);
    vector<int> leftChild(n + 1, 0), rightChild(n + 1, 0), indeg(n + 1, 0);

    for (int i = 1; i <= n; i++) {
        int l, r;
        cin >> val[i] >> l >> r;
        leftChild[i] = l;
        rightChild[i] = r;
        if (l != 0) indeg[l]++;
        if (r != 0) indeg[r]++;
    }

    int root = 1;
    for (int i = 1; i <= n; i++) {
        if (indeg[i] == 0) {
            root = i;
            break;
        }
    }

    vector<long long> preorder;
    preorder.reserve(n);

    stack<int> st;
    st.push(root);
    while (!st.empty()) {
        int u = st.top();
        st.pop();
        preorder.push_back(val[u]);

        if (rightChild[u] != 0) st.push(rightChild[u]);
        if (leftChild[u] != 0) st.push(leftChild[u]);
    }

    for (int i = 0; i < (int)preorder.size(); i++) {
        if (i) cout << ' ';
        cout << preorder[i];
    }
    cout << '\n';

    return 0;
}
