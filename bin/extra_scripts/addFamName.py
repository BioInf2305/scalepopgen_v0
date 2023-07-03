import sys
import argparse

def addPopIdToFam(in_fam_file,pop_id_file,out_fam_file):
    new_fam_dict={}
    if out_fam_file != "NA":
        dest = open(out_fam_file,"w")
    else:
        new_dest_name=in_fam_file.replace(".fam",".addSnpId.bim")
        dest = open(new_dest_name,"w")
    with open(pop_id_file) as pop_id_source:
        for line in pop_id_source:
            line=line.rstrip().split("\t")
            new_fam_dict[line[0]]=line[1]
    with open(in_fam_file) as in_fam_source:
        for lin in in_fam_source:
            lin=lin.rstrip().split(" ")
            lin[0]=new_fam_dict[lin[0]]
            dest.write(" ".join(lin)+"\n")
    dest.close()

if __name__=="__main__":
    parser = argparse.ArgumentParser(description="A small python script to replace \
    snp id in the bim file", epilog="author: Maulik Upadhyay (Upadhyay.maulik@gmail.com)")
    parser.add_argument("-f", "--famF", metavar = "File", help = "plink bim file", required= True)
    parser.add_argument("-p", "--popId", metavar = "File", help = "user supplied file to replace snp id", required= True)
    parser.add_argument("-o", "--outFamF", metavar = "File", help = "updated plink bim file", default="NA", required= False)

    args = parser.parse_args()

    if len(sys.argv)==1:
        parser.print_help(sys.stderr)
        sys.exit(1)
    else:
        addPopIdToFam(args.famF,args.popId,args.outFamF)
