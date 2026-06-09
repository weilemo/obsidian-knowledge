#include <algorithm>
#include <iostream>
#include <vector>
using namespace std;

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    cin >> n;

    vector<long long> a(n);
    vector<long long> values;
    values.reserve(n);

    for (int i = 0; i < n; i++) {
        cin >> a[i];
        values.push_back(a[i]);
    }

    sort(values.begin(), values.end());
    values.erase(unique(values.begin(), values.end()), values.end());

    for (int i = 0; i < n; i++) {
        int rank = (int)(lower_bound(values.begin(), values.end(), a[i]) - values.begin()) + 1;
        if (i > 0) cout << ' ';
        cout << rank;
    }
    cout << '\n';

    return 0;
}
