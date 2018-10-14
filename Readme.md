**Implimentation algorithms from following articales:**

* Jyothish Soman, Kothapalli Kishore, and P J Narayanan "A Fast GPU Algorithm for Graph Connectivity"

* Lijuan Luo Martin Wong Wen-mei Hwu "An Effective GPU Implementation of Breadth-First Search"

**Requirements:**

* g++11

* nvcc

**Benchmarking**

* In additional to these two algorithms, serial BFS algorithms was implimented to compare GPU and CPU algorithms efficencies.

* All mesurmants were done on syntatic date. The generator may be found in gen.cpp

* There are 3 different graph topologies: 
	- each node has at least 1 edge (fig. 1)
	- each node has at least 4 edges (fig. 2)
	- each node has at least 16 edges (fig. 3)

* The graph size range is from 10 nodes to 10000 nodes

[!](fig. 1) [1-edge.png]

[!](fig. 2) [4-edges.png]

[!](fig. 3) [16-edges.png]

**Conclusion**

* The Fast GPU algorithm is preferable for big graphs

* The Fast GPU algorithm is preferable for graphs with big node degrees 

* GPU BFS is more efficient on small graphs
