import sys

def main(squareMatIn, squareMatId, numPop, squareMatOut):
    with open(squareMatOut, "w") as dest:
        dest.write(numPop+"\n")
        dict_record = {}
        lineCount = 0
        with open(squareMatId) as source:
            for line in source:
                lineCount += 1
                line = line.rstrip().split()
                if(len(line[1]))>=10:
                    sampleId = line[1][:9]+" "
                else:
                    addSpace = 10-len(line[1])
                    sampleId = line[1]+" "*addSpace
                dict_record[lineCount] = sampleId
        newLineCount = 0
        with open(squareMatIn) as source:
            for line in source:
                newLineCount += 1
                line = line.rstrip().split()
                floatList = line[0:]
                formatFloatList = list(map(lambda i:format(float(i),'.4f'), floatList))
                floatToStrList = list(map(lambda i:str(i), formatFloatList))
                dest.write(dict_record[newLineCount]+" ".join(floatToStrList)+"\n")

if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])
