#include <iostream>
#include <fstream>
#include <vector>
#include <stdio.h>
#include <algorithm>
#include <time.h>

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


__global__ void select_winner_odd(int *parent, unsigned long long *edge_list, int *mark, int *flag, int e_num) {
	int tid = blockIdx.x * blockDim.x + threadIdx.x;
	if (tid < e_num) {
		unsigned long long temp = edge_list[tid];
		int u, v;
		u = temp & 0xffffffff;
		v = temp >> 32;
		if (parent[u] != parent[v]) {
			parent[max(parent[u], parent[v])] = parent[min(parent[u], parent[v])];
			*flag = 1; 
		} else {
			mark[tid] = 1;
		}  
	}
}

__global__ void select_winner_even(int *parent, unsigned long long *edge_list, int *mark, int *flag, int e_num) {
	int tid = blockIdx.x * blockDim.x + threadIdx.x;
	if (tid < e_num) {
		unsigned long long temp = edge_list[tid];
		unsigned int u, v;
		u = temp & 0xffffffff;
		v = (temp >> 32) & 0xffffffff;
		if (parent[u] != parent[v]) {
			parent[min(parent[u], parent[v])] = parent[max(parent[u], parent[v])];
			*flag = 1; 
		} else {
			mark[tid] = 1;
		}  
	}
}

__global__ void jump(int *parent, int v_num, int *flag) {
	int tid = blockIdx.x * blockDim.x + threadIdx.x;
	if (tid < v_num) {	
		int p = parent[tid];
		int p_p = parent[p];
		if (p != p_p) {
			parent[tid] = p_p;
			(*flag) = 1;
		}
	}
}

int main() {	
	int n, m;
	readInt(n, m);
	unsigned long long *h_edge_list, *d_edge_list;
	h_edge_list = (unsigned long long*)malloc(m * sizeof(unsigned long long));
	readGraph(h_edge_list, n, m);
	int h_parent[n], *d_parent;
	int h_mark[m], *d_mark;
	for (int i = 0; i < n; ++i) {
		h_parent[i] = i;
	}
	for (int i = 0; i < m; ++i) {
		h_mark[i] = 0;
	}
	int flag[1], *d_flag;
	int count = 0;
	clock_t beg = clock();
	do {
		flag[0] = 0;
		cudaMalloc(&d_parent, n * sizeof(int));
		cudaMalloc(&d_edge_list, m * sizeof(unsigned long long));
		cudaMalloc(&d_mark, m * sizeof(int));
		cudaMalloc(&d_flag, sizeof(int));

		cudaMemcpy(d_parent, h_parent, n * sizeof(int), cudaMemcpyHostToDevice);
		cudaMemcpy(d_edge_list, h_edge_list, m * sizeof(unsigned long long), cudaMemcpyHostToDevice);
		cudaMemcpy(d_mark, h_mark, m * sizeof(int), cudaMemcpyHostToDevice);
		cudaMemcpy(d_flag, flag, sizeof(int), cudaMemcpyHostToDevice);

		if (count) {
			select_winner_odd<<<256, 256>>>(d_parent, d_edge_list, d_mark, d_flag, m);
		} else {
			select_winner_even<<<256, 256>>>(d_parent, d_edge_list, d_mark, d_flag, m);
		}
        cudaThreadSynchronize();

		cudaMemcpy(flag, d_flag, sizeof(int), cudaMemcpyDeviceToHost);
		cudaMemcpy(h_parent, d_parent, n * sizeof(int), cudaMemcpyDeviceToHost);

		cudaFree(&d_parent);
		cudaFree(&d_edge_list);	
		cudaFree(&d_mark);
		cudaFree(&d_flag);

		if (!flag[0]) {
			break;
		}
		count ^= 1;
		do {
			flag[0] = 0;
			cudaMalloc(&d_flag, sizeof(int));
			cudaMalloc(&d_parent, n * sizeof(int));
			cudaMemcpy(d_flag, flag, sizeof(int), cudaMemcpyHostToDevice);
			cudaMemcpy(d_parent, h_parent, n * sizeof(int), cudaMemcpyHostToDevice);
			jump<<<256, 256>>>(d_parent, n, d_flag);
        	cudaThreadSynchronize();	
			cudaMemcpy(flag, d_flag, sizeof(int), cudaMemcpyDeviceToHost);
			cudaMemcpy(h_parent, d_parent, n * sizeof(int), cudaMemcpyDeviceToHost);
			cudaFree(&d_flag);
			cudaFree(&d_parent);
		} while(flag[0]);
	} while(flag);
	cout << float(clock() - beg) / CLOCKS_PER_SEC << endl;
	sort(h_parent, h_parent + n);
	cout << unique(h_parent, h_parent + n) - h_parent;
}
