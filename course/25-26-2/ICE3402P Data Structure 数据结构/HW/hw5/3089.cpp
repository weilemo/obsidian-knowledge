#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

int kthSmallest(const vector<int>& a, const vector<int>& b, int k) {
    int n = (int)a.size();
    int m = (int)b.size();
    int i = 0, j = 0;

    while (true) {
        if (i == n) return b[j + k - 1];
        if (j == m) return a[i + k - 1];
        if (k == 1) return min(a[i], b[j]);

        int half = k / 2;
        int ni = min(i + half, n) - 1;
        int nj = min(j + half, m) - 1;

        if (a[ni] <= b[nj]) {
            int removed = ni - i + 1;
            i = ni + 1;
            k -= removed;
        } else {
            int removed = nj - j + 1;
            j = nj + 1;
            k -= removed;
        }
    }
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, m, q;
    cin >> n >> m >> q;

    vector<int> a(n), b(m);
    for (int i = 0; i < n; i++) cin >> a[i];
    for (int i = 0; i < m; i++) cin >> b[i];

    while (q--) {
        int k;
        cin >> k;
        cout << kthSmallest(a, b, k) << '\n';
    }

    return 0;
}
