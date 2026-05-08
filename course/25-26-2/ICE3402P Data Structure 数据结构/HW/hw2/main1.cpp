#include <iostream>
#include <vector>

using namespace std;

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    cin >> n;

    vector<long long> h(n + 1);
    for (int i = 1; i <= n; i++) {
        cin >> h[i];
    }

    // ans[i] 表示第 i 个箱子右边第一个更高箱子的编号
    vector<int> ans(n + 1, 0);

    // 用 vector 当栈，里面存下标
    vector<int> st;

    for (int i = n; i >= 1; i--) {
        while (!st.empty() && h[st.back()] <= h[i]) {
            st.pop_back();
        }

        if (!st.empty()) ans[i] = st.back();
        else ans[i] = 0;

        st.push_back(i);
    }

    for (int i = 1; i <= n; i++) {
        if (i > 1) cout << ' ';
        cout << ans[i];
    }
    cout << '\n';

    return 0;
}
