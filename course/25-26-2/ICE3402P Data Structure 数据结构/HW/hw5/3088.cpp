#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, q;
    cin >> n >> q;

    vector<int> a(n);
    for (int i = 0; i < n; i++) cin >> a[i];

    while (q--) {
        int x;
        cin >> x;

        int l = 0, r = n - 1;
        int ans = n;
        while (l <= r) {
            int mid = l + (r - l) / 2;
            if (a[mid] >= x) {
                ans = mid;
                r = mid - 1;
            } else {
                l = mid + 1;
            }
        }

        if (ans == n) cout << 0 << '\n';
        else cout << ans + 1 << '\n';
    }

    return 0;
}
