import sys
import argparse

def addPopIdToFam(in_fam_file, pop_id_include_file, pop_id_exclude_file):
    new_fam_dict = {}
    pop_incl_list = []
    pop_excl_list = []
    if pop_id_include_file != "NA":
        pop_incl_list = fileToList(pop_id_include_file)
    if pop_id_exclude_file != "NA":
        pop_excl_list = fileToList(pop_id_exclude_file)
    with open(in_fam_file) as source:
        for line in source:
            line = line.rstrip().split()
            if line[0] not in pop_excl_list:
                if len(pop_incl_list) > 0:
                    if line[0] in pop_incl_list:
                        if line[0] not in new_fam_dict:
                            new_fam_dict[line[0]] = []
                        new_fam_dict[line[0]].append(line[1])
                else:
                    if line[0] not in new_fam_dict:
                        new_fam_dict[line[0]] = []
                    new_fam_dict[line[0]].append(line[1])
    popNames = list(new_fam_dict.keys())
    for popMain in new_fam_dict:
        with open(popMain+".sampleId.txt","w") as dest:
            dest.write("\n".join(new_fam_dict[popMain])+"\n")
        with open("Exclude_"+popMain+".txt","w") as dest1:
            for popRem in popNames:
                if popRem != popMain:
                    dest1.write("\n".join(new_fam_dict[popRem])+"\n")


def fileToList(in_file):
    out_list = []
    with open(in_file) as source:
        for line in source:
            line = line.rstrip().split()
            out_list.append(line[0])
    return out_list


if __name__=="__main__":
    parser = argparse.ArgumentParser(description="Prepare \
    input file for the pairwise fst analysis", epilog="author: Maulik Upadhyay (Upadhyay.maulik@gmail.com)")
    parser.add_argument("-f", "--famF", metavar = "File", help = "plink bim file", required= True)
    parser.add_argument("-P", "--popIncl", metavar = "File", help = "file of the populations to include (one pop per line)",default="NA", required= False)
    parser.add_argument("-p", "--popExcl", metavar = "File", help = "file of the populations to exclude (one pop per line)", default="NA", required= False)

    args = parser.parse_args()

    if len(sys.argv)==1:
        parser.print_help(sys.stderr)
        sys.exit(1)
    else:
        addPopIdToFam(args.famF,args.popIncl,args.popExcl)
