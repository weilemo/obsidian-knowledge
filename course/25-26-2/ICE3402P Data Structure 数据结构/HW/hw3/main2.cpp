#include <iostream>
#include <queue>
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

    vector<int> nxt(n + 1, 0);
    queue<int> q;
    q.push(root);

    while (!q.empty()) {
        int sz = (int)q.size();
        int prev = 0;
        for (int i = 0; i < sz; i++) {
            int u = q.front();
            q.pop();

            if (prev != 0) nxt[prev] = u;
            prev = u;

            if (leftChild[u] != 0) q.push(leftChild[u]);
            if (rightChild[u] != 0) q.push(rightChild[u]);
        }
        if (prev != 0) nxt[prev] = 0;
    }

    for (int i = 1; i <= n; i++) {
        cout << nxt[i] << '\n';
    }

    return 0;
}
