#include <iostream>
#include <vector>

using namespace std;

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    long long targetId;
    char plan;
    int n;

    if (!(cin >> targetId)) return 0;
    cin >> plan;
    cin >> n;

    vector<long long> req(n);
    for (int i = 0; i < n; i++) {
        cin >> req[i];
    }

    int limit = 0;
    if (plan == 'a') limit = 3;
    else if (plan == 'b') limit = 6;
    else limit = 9; // plan == 'c'

    vector<int> ans(n, 0);

    // 只记录“成功处理”的目标用户请求下标
    vector<int> okPos;
    int head = 0;

    for (int i = 0; i < n; i++) {
        if (req[i] != targetId) {
            ans[i] = 0;
            continue;
        }

        // 维护最近 10 个请求位置（i-9 到 i）内的成功次数
        while (head < (int)okPos.size() && okPos[head] < i - 9) {
            head++;
        }

        int used = (int)okPos.size() - head;
        if (used < limit) {
            ans[i] = 1;
            okPos.push_back(i);
        } else {
            ans[i] = -1;
        }
    }

    for (int i = 0; i < n; i++) {
        if (i > 0) cout << ' ';
        cout << ans[i];
    }
    cout << '\n';

    return 0;
}
