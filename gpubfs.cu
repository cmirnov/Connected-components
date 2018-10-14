#include <iostream>
#include <fstream>
#include <vector>
#include <stdio.h>

using namespace std;

__global__ void bfs(int n, int m, int q_size, int level, int *dist, int *neib, int *off, int *q_size_new, int *q_prev, int *q_next) {
	int tid = blockIdx.x * blockDim.x + threadIdx.x;
	if (tid < q_size) {
		int u = q_prev[tid];
		for (int i = off[u]; i < (u == n - 1 ? 2 * m : off[u + 1]); ++i) {
			int v = neib[i];
			if (dist[v] == INT_MAX && atomicMin(&dist[v], level + 1) == INT_MAX) {
				int position = atomicAdd(q_size_new, 1);
				q_next[position] = v;
			} 
		}
	}
}

void readInt(int &n, int &m) {
	ifstream fin_n("data/nums.txt");
	fin_n >> n >> m;
}

void readGraph(int *neib, int *off, int n, int m) {
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
	int idx = 0;
	for (int i = 0; i < n; ++i) {
		off[i] = idx;
		for (int j = 0; j < vert[i].size(); ++j) {
			neib[idx] = vert[i][j];
			idx++;
		}
	}

}

int main() {
	int n, m;
	readInt(n, m);
	int *neib, *off;
	neib = (int*)malloc(2 * m * sizeof(int));
	off = (int*)malloc(n * sizeof(int));
	readGraph(neib, off, n, m);
	int dist[n], q_prev[n];
	for (int i = 0; i < n; ++i) {
		dist[i] = INT_MAX;
	}
	int ans = 0;
	int size_new[1] = {0};
	int *d_dist, *d_neib, *d_off, *d_q_prev, *d_q_next, *q_size_new;;
	cudaMalloc(&d_dist, n * sizeof(int));
	cudaMalloc(&d_neib, 2 * m * sizeof(int));
	cudaMalloc(&d_off, n * sizeof(int));
	cudaMalloc(&d_q_prev, n * sizeof(int));
	cudaMalloc(&d_q_next, n * sizeof(int));
	cudaMalloc(&q_size_new, sizeof(int));
	clock_t beg = clock();
	for (int i = 0; i < n; ++i) {
		if (dist[i] == INT_MAX) {
			ans++;
			dist[i] = 0;
			int q_size = 0;
			int level = 0;
			
			for (int j = 0; j < (i == n - 1 ? 2 * m - off[i] : off[i + 1] - off[i]); ++j) {
				q_prev[j] = neib[off[i] + j];
				q_size++;
			} 
			while (q_size > 0) {
				cudaMemcpy(q_size_new, size_new, sizeof(int), cudaMemcpyHostToDevice);
				cudaMemcpy(d_dist, dist, n * sizeof(int), cudaMemcpyHostToDevice);
				cudaMemcpy(d_neib, neib, 2 * m * sizeof(int), cudaMemcpyHostToDevice);
				cudaMemcpy(d_off, off, n * sizeof(int), cudaMemcpyHostToDevice);
				cudaMemcpy(d_q_prev, q_prev, n * sizeof(int), cudaMemcpyHostToDevice);
				bfs<<<255, 255>>>(n, m, q_size, level, d_dist, d_neib, d_off, q_size_new, d_q_prev, d_q_next);

				level++;

				cudaMemcpy(size_new, q_size_new, sizeof(int), cudaMemcpyDeviceToHost);
				q_size = size_new[0];
				size_new[0] = 0;
				cudaMemcpy(q_prev, d_q_next, n * sizeof(int), cudaMemcpyDeviceToHost);
				cudaMemcpy(dist, d_dist, n * sizeof(int), cudaMemcpyDeviceToHost);
			}
		}
	}
	cout << float(clock() - beg) / CLOCKS_PER_SEC << endl;
	cout << ans << endl;
	return 0;
}
