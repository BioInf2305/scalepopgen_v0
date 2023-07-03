import os
import sys
from jinja2 import Environment, FileSystemLoader
import re

environment = Environment(loader=FileSystemLoader("../templates/"))
template = environment.get_template("pedToPopgen.html")

lines = []
pwd = os.getcwd()
baseDirPath = "/".join(os.getcwd().split("/")[:-1])

def main(paramFile, figurePath, htmlOut):
    dagFigure = figurePath
    with open(paramFile, 'r') as f:
        for line in f:
            emptyList = []
            line = line.rstrip()
            pattern = re.compile('([^\=]+)(\=)(.*)')
            match = re.findall(pattern, line)
            if len(match)>0:
                if len(match[0]) == 3:
                    emptyList.append(match[0][0].strip())
                    if "baseDir" not in match[0][2]:
                        emptyList.append(match[0][2].strip())
                    else:
                        newVar = match[0][2].strip()
                        newVar= newVar.replace("${baseDir}",baseDirPath)
                        emptyList.append(newVar)
                elif len(match[0])>3:
                    print("more than 3 columns at "+line)
                lines.append(emptyList[:])
                del emptyList[:]
    with open(htmlOut, 'w') as f:
        f.write(template.render( lines = lines, dagFigure = dagFigure))

if __name__ == '__main__':
    main(sys.argv[1],sys.argv[2], sys.argv[3])
