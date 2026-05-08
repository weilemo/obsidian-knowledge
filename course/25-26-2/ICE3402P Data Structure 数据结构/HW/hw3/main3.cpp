#include <iostream>
#include <stack>
#include <string>
#include <vector>

using namespace std;

struct BigInt {
    static const int BASE = 1000000000;
    vector<int> d; // little-endian

    BigInt() { d.push_back(0); }

    void trim() {
        while (d.size() > 1 && d.back() == 0) d.pop_back();
    }

    void mul10() {
        long long carry = 0;
        for (int i = 0; i < (int)d.size(); i++) {
            long long cur = 1LL * d[i] * 10 + carry;
            d[i] = (int)(cur % BASE);
            carry = cur / BASE;
        }
        if (carry) d.push_back((int)carry);
    }

    void addSmall(int x) {
        long long carry = x;
        int i = 0;
        while (carry > 0) {
            if (i == (int)d.size()) d.push_back(0);
            long long cur = 1LL * d[i] + carry;
            d[i] = (int)(cur % BASE);
            carry = cur / BASE;
            i++;
        }
    }

    void div10() {
        long long rem = 0;
        for (int i = (int)d.size() - 1; i >= 0; i--) {
            long long cur = rem * BASE + d[i];
            d[i] = (int)(cur / 10);
            rem = cur % 10;
        }
        trim();
    }

    void addBig(const BigInt &other) {
        int n = max((int)d.size(), (int)other.d.size());
        if ((int)d.size() < n) d.resize(n, 0);
        long long carry = 0;
        for (int i = 0; i < n; i++) {
            long long cur = carry + d[i] + (i < (int)other.d.size() ? other.d[i] : 0);
            d[i] = (int)(cur % BASE);
            carry = cur / BASE;
        }
        if (carry) d.push_back((int)carry);
    }

    string toString() const {
        string s = std::to_string(d.back());
        for (int i = (int)d.size() - 2; i >= 0; i--) {
            string part = std::to_string(d[i]);
            s += string(9 - part.size(), '0') + part;
        }
        return s;
    }
};

struct Frame {
    int id;
    bool backtrack;
};

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    vector<int> val(n + 1, 0), leftChild(n + 1, 0), rightChild(n + 1, 0), indeg(n + 1, 0);

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

    BigInt sum;
    BigInt cur;

    stack<Frame> st;
    st.push({root, false});

    while (!st.empty()) {
        Frame f = st.top();
        st.pop();

        if (!f.backtrack) {
            cur.mul10();
            cur.addSmall(val[f.id]);
            st.push({f.id, true});

            if (leftChild[f.id] == 0 && rightChild[f.id] == 0) {
                sum.addBig(cur);
            } else {
                if (rightChild[f.id] != 0) st.push({rightChild[f.id], false});
                if (leftChild[f.id] != 0) st.push({leftChild[f.id], false});
            }
        } else {
            cur.div10();
        }
    }

    cout << sum.toString() << '\n';
    return 0;
}
