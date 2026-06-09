#include <algorithm>
#include <iostream>
#include <vector>
using namespace std;

struct Student {
    long long id;
    int theory;
    int lab;
};

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    cin >> n;

    vector<Student> students(n);
    for (int i = 0; i < n; i++) {
        cin >> students[i].id >> students[i].theory >> students[i].lab;
    }

    sort(students.begin(), students.end(), [](const Student& x, const Student& y) {
        int sx = x.theory + x.lab;
        int sy = y.theory + y.lab;
        if (sx != sy) return sx > sy;
        if (x.lab != y.lab) return x.lab > y.lab;
        return x.id < y.id;
    });

    for (const Student& student : students) {
        cout << student.id << ' ' << student.theory + student.lab << '\n';
    }

    return 0;
}
