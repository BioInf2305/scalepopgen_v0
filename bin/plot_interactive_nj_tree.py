import sys
import argparse
import toytree
import toyplot
import numpy as np


def plot_interactive_tree(newickfile, pop_color_file, out_prefix):
    newick = ""
    pop_color_dict = {}
    color_list = []
    with open(pop_color_file) as source:
        for line in source:
            line = line.rstrip().split()
            pop_color_dict[line[0]] = line[2]
    with open(newickfile) as source:
        for line in source:
            line = line.rstrip()
            newick = line
    tre1 = toytree.tree(newick, tree_format=1)
    pop_list = tre1.get_tip_labels()
    for pop in pop_list:
        color_list.append(pop_color_dict[pop])
    canvas, axes, mark = tre1.draw(height=350, node_hover=True, node_sizes=10, tip_labels_align=True, tip_labels_colors=color_list)
    toyplot.html.render(canvas,out_prefix+".html")

if __name__ == "__main__":
    plot_interactive_tree(sys.argv[1], sys.argv[2], sys.argv[3])
