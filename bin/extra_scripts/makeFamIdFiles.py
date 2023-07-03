import sys
import argparse

def addPopIdToFam(in_fam_file, pop_id_include_file, pop_id_exclude_file):
    new_fam_dict = {}
    pop_incl_list = []
    pop_excl_list = []
    if pop_id_include_file != "none":
        pop_incl_list = fileToList(pop_id_include_file)
    if pop_id_exclude_file != "none":
        pop_excl_list = fileToList(pop_id_exclude_file)
    with open(in_fam_file) as source:
        for line in source:
            line = line.rstrip().split()
            if line[1] not in pop_excl_list:
                if len(pop_incl_list) > 0:
                    if line[1] in pop_incl_list:
                        if line[1] not in new_fam_dict:
                            new_fam_dict[line[1]] = []
                        new_fam_dict[line[1]].append(line[0])
                else:
                    if line[1] not in new_fam_dict:
                        new_fam_dict[line[1]] = []
                    new_fam_dict[line[1]].append(line[0])
    for pop in new_fam_dict:
        with open(pop+".sampleId.txt","w") as dest:
            dest.write("\n".join(new_fam_dict[pop])+"\n")

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
    parser.add_argument("-m", "--mapF", metavar = "File", help = "map file (sample id, popid at each new line)", required= True)
    parser.add_argument("-P", "--popIncl", metavar = "File", help = "file of the populations to include (one pop per \
                        line)",default="none", required= False)
    parser.add_argument("-p", "--popExcl", metavar = "File", help = "file of the populations to exclude (one pop per \
                        line)", default="none", required= False)

    args = parser.parse_args()

    if len(sys.argv)==1:
        parser.print_help(sys.stderr)
        sys.exit(1)
    else:
        addPopIdToFam(args.mapF,args.popIncl,args.popExcl)
