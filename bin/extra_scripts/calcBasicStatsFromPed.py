import sys
import argparse
from collections import OrderedDict

def extractBasicStatsPed(pedFile, bimFile, popIncId, popIncFile, isPopSummary, outPrefix):
    popBimDict = {}
    if popIncFile != "None":
        popIncList = fileToList(popIncFile)
    else: popIncList = [popIncId]
    if not isPopSummary:
        popBimDict = bimFileToDict(popIncList, bimFile)
    else:
        for pop in popIncList:
            popBimDict[pop]=0
    popStatDict, popSampleCountDict = readPedFile(popBimDict, pedFile, isPopSummary, outPrefix)
    if not isPopSummary:
        calcPopStats(popStatDict, popSampleCountDict, outPrefix)



def fileToList(popIncFile):
    popIncList = []
    with open(popIncFile) as source:
        for line in source:
            line = line.rstrip().split()
            popIncList.append(line[0])
    return popIncList

def bimFileToDict(popIncList, bimFile):
    popBimDict = OrderedDict()
    with open(bimFile) as source:
        for line in source:
            line = line.rstrip().split()
            for pop in popIncList:
                tmpDict = OrderedDict()
                tmpDict[line[4]] = 0
                tmpDict[line[5]] = 0
                tmpDict["hetero"] = 0
                if pop not in popBimDict:
                    popBimDict[pop] = []
                popBimDict[pop].append(tmpDict)
    return popBimDict
        

def readPedFile(popBimDict, pedFile, isPopSummary, outPrefix):
    popSampleDict = {}
    for pop in popBimDict:
        popSampleDict[pop] = 0
    with open(outPrefix+".indiv.summary","w") as dest:
        with open(pedFile) as source:
            for line in source:
                line = line.rstrip().split()
                if line[0] in popBimDict:
                    homo = 0
                    hetero = 0
                    missing = 0
                    popId = line[0]
                    sampleId = line[1]
                    line = line[6:]
                    snpCount = -1
                    popSampleDict[popId] += 1
                    for i in range(0, len(line), 2):
                        snpCount += 1
                        if line[i] == line[i+1] == "0":
                            missing += 1
                        elif line[i] == line[i+1]:
                            homo +=1
                            if not isPopSummary:
                                popBimDict[popId][snpCount][line[i]] += 2
                        else:
                            hetero += 1
                            if not isPopSummary:
                                popBimDict[popId][snpCount]["hetero"] += 1
                                popBimDict[popId][snpCount][line[i]] +=1
                                popBimDict[popId][snpCount][line[i+1]] += 1
                    dest.write(sampleId+"\t"+str(homo)+"\t"+str(hetero)+"\t"+str(missing)+"\t"+str(hetero+missing+homo)+"\n")
    return popBimDict, popSampleDict
    
def calcPopStats(popStatDict, popSampleCountDict, outPrefix):
    with open(outPrefix+".pop.summary","w") as popOut:
        for pop in popStatDict:
            averageObsHet = 0
            averageExpHet = 0
            averageMaf = 0
            totalGenoPerMarkerLists = popStatDict[pop]
            totalSnps = len(totalGenoPerMarkerLists)
            for genoDict in totalGenoPerMarkerLists:
                alleleCountList = [genoDict[k] for k in genoDict if k!= "hetero"]
                totalSamples = sum(alleleCountList)/2
                if totalSamples > 0:
                    averageObsHet += genoDict["hetero"]/totalSamples
                    averageExpHet +=  2*(alleleCountList[0]/sum(alleleCountList))*(alleleCountList[1]/sum(alleleCountList))
                    averageMaf += alleleCountList[0]/sum(alleleCountList)
        popOut.write(pop+"\t"+str(popSampleCountDict[pop])+"\t"+str(averageMaf/totalSnps)+"\t"+str(averageObsHet/totalSnps)+"\t"+str(averageExpHet/totalSnps)+"\n")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-p", "--ped", help="name of the ped file including the extension", type= str, required=True)
    parser.add_argument("-b","--bim", help="bim file generated from plink files used in -p argument", type= str,
                        required= True)
    parser.add_argument("-i","--pop", help="population id for which the summary statistics is to be calculated",
                        type=str, required= False, default="None")
    parser.add_argument("-P", "--POP", help="file with population ids (each population id on new line)", type=str,
                        required= False, default="None")
    parser.add_argument("--calcPopSummary", action="store_false")
    parser.add_argument("-o","--outPrefix", help="prefix of the output file to be generated", type=str, required=True)
    args = parser.parse_args()
    if len(sys.argv) == 1:
        parser.print_help(sys.stderr)
    elif args.pop=="None" and args.POP=="None":
        print("one of the flags, --pop or --POP is required")
        parser.print_help(sys.stderr)
    else:
        extractBasicStatsPed(args.ped, args.bim, args.pop, args.POP, args.calcPopSummary, args.outPrefix)

