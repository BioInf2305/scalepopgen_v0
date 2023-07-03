import sys
import argparse
import re
import numpy as np

def calcDi(inFiles, numSnps, outFile ):
    fstWindowDict = {}
    pattern1 = re.compile('([0-9A-Za-z\._]+?)\.(sampleId)_vs_([0-9A-Za-z\._]+?)\.(sampleId).weir.fst')
    popList = []
    dest = open(outFile,"w")
    for inFile in inFiles:
        match1 = re.findall(pattern1,inFile)
        pop1 = match1[0][0]
        pop2 = match1[0][2]
        header = 0
        tmpFstWindowDict = {}
        tmpFstWindowDict[pop1] = {}
        tmpFstWindowDict[pop2] = {}
        fstTmpList = []
        if pop1 not in popList:
            popList.append(pop1)
        if pop2 not in popList:
            popList.append(pop2)
        with open(inFile) as source:
            for line in source:
                line = line.rstrip().split()
                if header == 0:
                    header += 1
                else:
                    windowRange = line[1]+"_"+line[2]
                    tmpFstWindowDict[pop1][line[0]] = {}
                    if int(line[3]) >= int(numSnps):
                        tmpFstWindowDict[pop1][windowRange] = max(0,float(line[5]))
                        tmpFstWindowDict[pop2][windowRange] = max(0,float(line[5]))
                        fstTmpList.append(max(0, float(line[5])))
                    else:
                        tmpFstWindowDict[pop1][windowRange] = 0
                        tmpFstWindowDict[pop2][windowRange] = 0
        fstMean = np.nanmean(fstTmpList)
        fstStd = np.nanstd(fstTmpList)
        chrms = tmpFstWindowDict[pop1]
        for chrm in chrms:
            windows = tmpFstWindowDict[pop1][chrm]
            for window in windows:
                correctedFst = (tmpFstWindowDict[pop1][window] - fstMean)/fstStd
                if chrm not in fstWindowDict:
                    fstWindowDict[chrm] = {}
                if window not in fstWindowDict[chrm]:
                    fstWindowDict[chrm][window] = {}
                if pop1 not in fstWindowDict[chrm][window]:
                    fstWindowDict[chrm][window][pop1] = 0
                if pop2 not in fstWindowDict[chrm][window]:
                    fstWindowDict[chrm][window][pop2] = 0
                fstWindowDict[chrm][window][pop1] += correctedFst
                fstWindowDict[chrm][window][pop2] += correctedFst
    for chrm in fstWindowDict:
        windowDict = fstWindowDict[chrm]
        for window in windowDict:
            begin = window.split("_")[0]
            end = window.split("_")[1]
            dest.write(chrm+"\t"+begin+"\t"+end)
            for pop in popList:
                dest.write("\t"+str(fstWindowDict[chrm][window][pop]))
            dest.write("\n")

if __name__=="__main__":
    parser = argparse.ArgumentParser(description="A small python script to calculate di value (Akey et al., 2010) based on pairwise-Fst distances \
    generated in non-overlapping windows using vcftools", epilog="author: Maulik Upadhyay (Upadhyay.maulik@gmail.com)")
    parser.add_argument("-i", "--inFiles", metavar = "String", nargs='+', help = "input fst files space separated", required = True)
    parser.add_argument("-n", "--numSnps", metavar = "Int", help = "minimum SNPs must be present in a window", default= 0, required = False)
    parser.add_argument("-o", "--outFile", metavar = "File", help = "output file to write the Di statistics", required = True)
    args = parser.parse_args()

    if len(sys.argv)==1:
        parser.print_help(sys.stderr)
        sys.exit(1)
    else:
        makeFstTree(args.inFiles, args.numSnps, args.outFile)
