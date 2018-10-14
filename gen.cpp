#include <bits/stdc++.h>

using namespace std;

int main() {
	ofstream num("data/nums.txt");
	ofstream graph("data/graph.txt");
	int n, m, k = 16;
	n = 10;
	m = k * n;  
	num << n << " " << m;  
	std::random_device rd;  //Will be used to obtain a seed for the random number engine
    std::mt19937 gen(rd()); //Standard mersenne_twister_engine seeded with rd()
    std::uniform_int_distribution<> dis(1, n);
	for (int i = 0; i < n; ++i) {
		for (int j = 0; j < k; ++j) {
			graph << i + 1 << " " << dis(gen) << endl;
		}
	}
}
