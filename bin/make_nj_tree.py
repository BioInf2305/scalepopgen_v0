import sys
from Bio.Phylo.TreeConstruction import DistanceMatrix
from Bio.Phylo.TreeConstruction import DistanceTreeConstructor
from Bio import Phylo
import argparse


def make_fst_tree(in_file, tree, outgroup, out_prefix):
    pairwise_fst_dict = {}
    pop_list = []
    header = 0
    with open(in_file) as source:
        for line in source:
            if header == 0:
                header += 1
            else:
                line = line.rstrip().split()
                pop1 = line[0]
                pop2 = line[1]
                fst = float(line[2])
                if pop1 not in pop_list:
                    pop_list.append(pop1)
                if pop2 not in pop_list:
                    pop_list.append(pop2)
                pairwise_fst_dict[pop1 + "_" + pop2] = fst
    pop_list.sort()
    distance_list = []
    dest = open(out_prefix + ".fst.intree", "w")
    dest.write(" " + str(len(pop_list)) + "\n")
    for i, v in enumerate(pop_list):
        tmp_list = []
        col1 = v + " " * (10 - len(v)) if len(v) < 10 else v[:10] + " "
        dest.write(col1)
        for it, vt in enumerate(pop_list[:i]):
            fst = (
                pairwise_fst_dict[v + "_" + vt]
                if v + "_" + vt in pairwise_fst_dict
                else pairwise_fst_dict[vt + "_" + v]
            )
            tmp_list.append(round(fst, 4))
        tmp_list.append(0)
        tmp_list_w = ["{:.4f}".format(x) for x in tmp_list]
        dest.write(" ".join(tmp_list_w) + "\n")
        distance_list.append(tmp_list[:])
    dm = DistanceMatrix(pop_list, distance_list)
    constructor = DistanceTreeConstructor()
    if tree == "UPGMA":
        tree = constructor.upgma(dm)
    else:
        tree = constructor.nj(dm)
    if outgroup != "none":
        tree.root_with_outgroup({"name": outgroup})
    Phylo.write(tree, out_prefix, "newick")
    dest.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="A small python script to generate NJ-based tree based on pairwise-Fst distances generated \
    using vcftools",
        epilog="author: Maulik Upadhyay (Upadhyay.maulik@gmail.com)",
    )
    parser.add_argument(
        "-i",
        "--in_file",
        metavar="String",
        help="plink generated global pairwise fst values between each pair of population",
        required=True,
    )
    parser.add_argument(
        "-t",
        "--tree",
        metavar="String",
        help="type of algorithms to be used in building tree: NJ or UPGMA (defualt = NJ) \
    ",
        default="NJ",
        required=False,
    )
    parser.add_argument(
        "-r",
        "--outgroup",
        metavar="String",
        help="population name to be used as outgroup",
        default="none",
        required=False,
    )
    parser.add_argument(
        "-o", "--out_prefix", metavar="File", help="output prefix", required=True
    )

    args = parser.parse_args()

    if len(sys.argv) == 1:
        parser.print_help(sys.stderr)
        sys.exit(1)
    elif args.tree not in ["NJ", "UPGMA"]:
        print("ERROR: the tree option should either be NJ or UPGMA")
    else:
        make_fst_tree(args.in_file, args.tree, args.outgroup, args.out_prefix)
