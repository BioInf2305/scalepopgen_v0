import sys
import numpy as np
import matplotlib.pyplot as plt
import statsmodels.api as sm
from collections import OrderedDict

def readFstOutFile(inFile,chromIndexFile,window,outFile):
    windowBp = int(window)
    chromSize = OrderedDict()
    chromPosFstDict = OrderedDict()
    header = 0
    dest = open(outFile, "w")
    with open(chromIndexFile) as source:
        for line in source:
            line = line.rstrip().split()
            if line[0] not in chromSize:
                chromSize[line[0]] = int(line[1])
    with open(inFile) as source:
        for line in source:
            if header == 0:
                header += 1
            else:
                line = line.rstrip().split()
                if line[0] not in chromPosFstDict:
                    chromPosFstDict[line[0]] = {}
                chromPosFstDict[line[0]][int(line[1])] = max(0,float(line[2]))
    for chrom in chromPosFstDict:
        lowess = sm.nonparametric.lowess(list(chromPosFstDict[chrom].values()), list(chromPosFstDict[chrom].keys()), frac = windowBp/chromSize[chrom])
        oriValues = list(chromPosFstDict[chrom].values())
        oriKeys   = list(chromPosFstDict[chrom].keys())
        smoothValues = list(lowess[:,1])
        for i in range(len(oriKeys)):
            dest.write(chrom+"\t"+str(oriKeys[i])+"\t"+str(oriValues[i])+"\t"+str(smoothValues[i])+"\n")
        """
        fig, ax = plt.subplots( nrows = 1, ncols = 1)
        ax.plot(list(chromPosFstDict[chromKey].keys()),list(chromPosFstDict[chromKey].values()),"+")
        ax.plot(lowess[:,0], lowess[:,1])
        fig.savefig("chrom1.png")
        plt.close(fig)
        """

if __name__ == "__main__":
    readFstOutFile(sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4])
