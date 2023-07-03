import sys
import argparse

def addSnpIdToBim(in_bim_file,snp_id_file,out_bim_file):
    new_snp_dict = {}
    new_chrm_dict = {}
    if out_bim_file != "NA":
        dest = open(out_bim_file,"w")
    else:
        new_dest_name = in_bim_file.replace(".bim",".addSnpId.bim")
        dest = open(new_dest_name,"w")
    if snp_id_file!="NA":
        with open(snp_id_file) as snp_id_source:
            for line in snp_id_source:
                line=line.rstrip().split("\t")
                if line[1] not in new_snp_dict:
                    new_snp_dict[line[1]] = {}
                new_snp_dict[line[1]][line[2]] = line[3]
                new_chrm_dict[line[0]] = line[1]
    with open(in_bim_file) as in_bim_source:
        for lin in in_bim_source:
            lin = lin.rstrip().split("\t")
            if snp_id_file !="NA":
                lin[1] = new_snp_dict[new_chrm_dict[lin[0]]][line[3]]
            else:
                lin[1] = lin[0]+"_"+lin[3]
            dest.write("\t".join(lin)+"\n")

if __name__=="__main__":
    parser = argparse.ArgumentParser(description="A small python script to replace \
    snp id in the bim file", epilog="author: Maulik Upadhyay (Upadhyay.maulik@gmail.com)")
    parser.add_argument("-b", "--bim", metavar = "File", help = "plink bim file", required= True)
    parser.add_argument("-s", "--snpId", metavar = "File", help = "user supplied file to replace snp id", default = "NA", required= False)
    parser.add_argument("-o", "--outBim", metavar = "File", help = "updated plink bim file", default="NA", required= False)

    args = parser.parse_args()

    if len(sys.argv)==1:
        parser.print_help(sys.stderr)
        sys.exit(1)
    else:
        addSnpIdToBim(args.bim,args.snpId,args.outBim)
