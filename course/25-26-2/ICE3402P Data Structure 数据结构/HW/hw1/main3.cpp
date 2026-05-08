#include <iostream>
#include <vector>

using namespace std;

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, m;
    if (!(cin >> n >> m)) return 0;

    vector<int> A(n), B(m);
    for (int i = 0; i < n; i++) cin >> A[i];
    for (int i = 0; i < m; i++) cin >> B[i];

    vector<int> C;
    int i = 0, j = 0;

    while (i < n || j < m) {
        if (i == n) {
            int x = B[j];
            C.push_back(x);
            while (j < m && B[j] == x) j++;
        } else if (j == m) {
            int x = A[i];
            C.push_back(x);
            while (i < n && A[i] == x) i++;
        } else if (A[i] == B[j]) {
            // 同时出现就都跳过
            int x = A[i];
            while (i < n && A[i] == x) i++;
            while (j < m && B[j] == x) j++;
        } else if (A[i] < B[j]) {
            int x = A[i];
            C.push_back(x);
            while (i < n && A[i] == x) i++;
        } else {
            int x = B[j];
            C.push_back(x);
            while (j < m && B[j] == x) j++;
        }
    }

    if (C.empty()) {
        cout << "Empty\n";
    } else {
        for (int k = 0; k < (int)C.size(); k++) {
            if (k > 0) cout << ' ';
            cout << C[k];
        }
        cout << '\n';
    }

    return 0;
}
