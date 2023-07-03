import sys
import re
from Bio.Phylo.TreeConstruction import DistanceMatrix
from Bio.Phylo.TreeConstruction import DistanceTreeConstructor
from Bio import Phylo
import argparse
import numpy as np

def makeFstTree(inFiles, tree, outgroup, outPrefix):
    pairwiseFstDict = {}
    popList = []
    emptyList = [0]
    isWindowFst = False
    pattern1 = re.compile('(.*?)(.sampleId_vs_)(.*?)(.sampleId)(.*)')
    for inFile in inFiles:
        match1 = re.findall(pattern1,inFile)
        pop1 = match1[0][0]
        pop2 = match1[0][2]
        fstArray = []
        header = 0
        if pop1 not in popList:
            popList.append(pop1)
        if pop2 not in popList:
            popList.append(pop2)
        with open(inFile) as source:
            for line in source:
                line = line.rstrip().split()
                if header == 0:
                    isWindowFst = False if line[1]=="POS" else True
                    header += 1
                else:
                    if isWindowFst:
                        fstArray.append(float(line[5]))
                    else:
                        fstArray.append(float(line[2]))
        pairwiseFstDict[pop1+"_"+pop2] = np.nanmean(fstArray)
    popList.sort()
    distanceList = []
    dest = open(outPrefix+".fst.intree","w")
    dest.write(" "+str(len(popList))+"\n")
    for i,v in enumerate(popList):
        tmpList=[]
        col1 = v+" "*(10-len(v)) if len(v)<10 else v[:10]+" "
        dest.write(col1)
        for it,vt in enumerate(popList[:i]):
            fst = pairwiseFstDict[v+"_"+vt] if v+"_"+vt in pairwiseFstDict else pairwiseFstDict[vt+"_"+v]
            tmpList.append(round(fst,4))
        tmpList.append(0)
        tmpListW = ['{:.4f}'.format(x) for x in tmpList]
        dest.write(" ".join(tmpListW)+"\n")
        distanceList.append(tmpList[:])
    dm = DistanceMatrix(popList, distanceList)
    constructor = DistanceTreeConstructor()
    if tree == "UPGMA":
        tree = constructor.upgma(dm)
    else:
        tree = constructor.nj(dm)
    if outgroup != "none":
        tree.root_with_outgroup({"name": outgroup})
    Phylo.write(tree, outPrefix, "newick")
    dest.close()

if __name__=="__main__":
    parser = argparse.ArgumentParser(description="A small python script to generate NJ-based tree based on pairwise-Fst distances generated \
    using vcftools", epilog="author: Maulik Upadhyay (Upadhyay.maulik@gmail.com)")
    parser.add_argument("-i", "--inFiles", metavar = "String", nargs='+', help = "input fst files space separated", required = True)
    parser.add_argument("-t", "--tree", metavar = "String", help = "type of algorithms to be used in building tree: NJ or UPGMA (defualt = NJ) \
    ", default = "NJ", required = False)
    parser.add_argument("-r", "--outgroup", metavar = "String", help = "population name to be used as outgroup", \
                        default= "none", required = False)
    parser.add_argument("-o", "--outPrefix", metavar = "File", help = "output prefix", required = True)

    args = parser.parse_args()

    if len(sys.argv)==1:
        parser.print_help(sys.stderr)
        sys.exit(1)
    elif args.tree not in ["NJ", "UPGMA"]:
        print("ERROR: the tree option should either be NJ or UPGMA")
    else:
        makeFstTree(args.inFiles, args.tree, args.outgroup, args.outPrefix)
