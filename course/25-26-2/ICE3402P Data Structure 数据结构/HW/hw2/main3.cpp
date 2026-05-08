#include <iostream>
#include <vector>

using namespace std;

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    cin >> n;

    vector<int> inOrder(n), outOrder(n);
    for (int i = 0; i < n; i++) cin >> inOrder[i];
    for (int i = 0; i < n; i++) cin >> outOrder[i];

    vector<int> st;
    int j = 0;

    for (int i = 0; i < n; i++) {
        st.push_back(inOrder[i]);

        while (!st.empty() && j < n && st.back() == outOrder[j]) {
            st.pop_back();
            j++;
        }
    }

    if (j == n) cout << "YES\n";
    else cout << "NO\n";

    return 0;
}
