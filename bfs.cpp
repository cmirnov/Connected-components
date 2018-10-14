#include <bits/stdc++.h>

using namespace std;

void readInt(int &n, int &m) {
	ifstream fin_n("data/nums.txt");
	fin_n >> n >> m;
}

void readGraph(unsigned long long *neib, int n, int m) {
	ifstream fin_g("data/graph.txt");
	vector<vector<int> > vert;
	vert.resize(n);
	for (int i = 0; i < m; ++i) {
		int u, v;
		fin_g >> u >> v;
		u--, v--;
		neib[i] = ((unsigned long long)u << 32) + v; 
	}
}

int main() {
	int n, m;
	readInt(n, m);
	ifstream fin_g("data/graph.txt");
	vector<vector<int> > vert;
	vert.resize(n);
	for (int i = 0; i < m; ++i) {
		int u, v;
		fin_g >> u >> v;
		u--, v--;
		vert[u].push_back(v);
		vert[v].push_back(u);
	}
	vector<int> used(n, false);
	clock_t beg = clock();
	int ans = 0;
	for (int i = 0; i < n; ++i) {
		if (!used[i]) {
			ans++;
			queue<int> q;
			q.push(i);
			used[i] = true;
			while (q.size()) {
				int u = q.front();
				q.pop();
				for (auto v : vert[u]) {
					if (!used[v]) {
						q.push(v);
						used[v] = true;
					}
				}
			}
		}
	}	
	cout << (float)(clock() - beg) / CLOCKS_PER_SEC << endl;;
	cout << ans;
}
