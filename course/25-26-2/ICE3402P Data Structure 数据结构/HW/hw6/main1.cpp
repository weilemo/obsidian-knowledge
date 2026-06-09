#include <algorithm>
#include <iostream>
#include <vector>
using namespace std;

struct Record {
    long long level;
    long long time;
    int id;
};

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    cin >> n;

    vector<Record> records(n);
    for (int i = 0; i < n; i++) {
        cin >> records[i].level >> records[i].time;
        records[i].id = i + 1;
    }

    stable_sort(records.begin(), records.end(), [](const Record& x, const Record& y) {
        if (x.level != y.level) return x.level > y.level;
        return x.time < y.time;
    });

    for (const Record& record : records) {
        cout << record.id << '\n';
    }

    return 0;
}
