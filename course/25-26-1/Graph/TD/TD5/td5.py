import numpy as np
import networkx as nx

dict_G1 = {
    0: [1, 4],
    1: [0, 2, 3],
    2: [0, 1, 3, 4 ,6],
    3: [1, 2, 5],
    4: [0, 2],
    5: [3, 6],
    6: [2, 5]
}
G1 = nx.Graph(dict_G1)
bfs_tree_1 = nx.bfs_tree(G1, source=2)
nx.draw(bfs_tree_1, with_labels=True)