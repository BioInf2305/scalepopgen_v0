import sys
import argparse
from pysam import VariantFile


def map_to_dict(sampleMap):
    map_dict = {}
    with open(sampleMap) as source:
        for line in source:
            line = line.rstrip().split()
            map_dict[line[0]] = line[1]
    return map_dict


def anc_to_dict(anc):
    derived_allele_dict = {}
    with open(anc) as source:
        for line in source:
            line = line.rstrip().split()
            derived_allele_dict[int(line[1])] = int(line[3])
    return derived_allele_dict


def pop_file_to_list(pop):
    pop_list = []
    with open(pop) as source:
        for line in source:
            line = line.rstrip().split()
            pop_list.append(line[0])
    return pop_list


def create_local_count_dict(pop_list):
    local_count_dict = {}
    for pop in pop_list:
        local_count_dict[pop] = [0, 0]
    return local_count_dict


def vcf_to_swpfinder2(vcfIn, sampleMap, anc, pop, createRecomb, createGrid, outprefix):
    map_dict = map_to_dict(sampleMap)
    if anc != "ref":
        derived_allele_dict = anc_to_dict(anc)
    file_pointer_dict = {}
    init_cm = {}
    fold_g = "0" if anc != "ref" else "1"
    vcf_pntr = VariantFile(vcfIn)
    vcf_samples = list(vcf_pntr.header.samples)
    if pop == "all":
        pop_list = list(set(map_dict.values()))
    elif ".txt" in pop:
        pop_list = pop_file_to_list(pop)
    else:
        pop_list = [pop]
    for popId in pop_list:
        file_pointer_dict[popId] = [open(outprefix + "__" + popId + ".freq", "w")]
        file_pointer_dict[popId][0].write(
            "position" + "\t" + "x" + "\t" + "n" + "\t" + "folded" + "\n"
        )
        init_cm[popId] = 0.0
        if createRecomb:
            file_pointer_dict[popId].append(
                open(outprefix + "__" + popId + ".recomb", "w")
            )
            file_pointer_dict[popId][1].write("position" + "\t" + "rate" + "\n")
        if createGrid:
            file_pointer_dict[popId].append(open(popId + ".grid", "w"))
    for rec in vcf_pntr.fetch():
        derived_allele = (
            derived_allele_dict.get(int(rec.pos), "NP") if anc != "ref" else 1
        )
        fold, derived_allele = (
            (fold_g, derived_allele) if derived_allele != "NP" else ("1", 1)
        )
        local_count_dict = create_local_count_dict(pop_list)
        for sample in map_dict:
            gt = rec.samples[sample]["GT"]
            if gt != (None, None):
                local_count_dict[map_dict[sample]][0] += gt.count(derived_allele)
                local_count_dict[map_dict[sample]][1] += 2
        for popId in pop_list:
            if local_count_dict[popId][0] > 0 or fold == "0":
                file_pointer_dict[popId][0].write(
                    str(rec.pos)
                    + "\t"
                    + str(local_count_dict[popId][0])
                    + "\t"
                    + str(local_count_dict[popId][1])
                    + "\t"
                    + fold
                    + "\n"
                )
                if createRecomb:
                    if init_cm[popId] == 0.0:
                        file_pointer_dict[popId][1].write(
                            str(rec.pos) + "\t" + str(init_cm[popId]) + "\n"
                        )
                    else:
                        file_pointer_dict[popId][1].write(
                            str(rec.pos)
                            + "\t"
                            + str((rec.pos - init_cm[popId]) / 1000000)
                            + "\n"
                        )
                    init_cm[popId] = rec.pos
                if createGrid:
                    file_pointer_dict[popId][2].write(str(rec.pos) + "\n")
    for popId in pop_list:
        for ptr in file_pointer_dict[popId]:
            ptr.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="convert vcf to input of sweepfinder2",
        epilog="author: Maulik Upadhyay (Upadhyaya.maulik@gmail.com)",
    )

    parser.add_argument(
        "-V", "--vcf", metavar="File", help="input vcf file", required=True
    )
    parser.add_argument(
        "-M",
        "--map",
        metavar="File",
        help="map file with first column as sample and second column as pop",
        required=True,
    )
    parser.add_argument(
        "-a",
        "--anc",
        default="ref",
        help="if available provide ancestral alleles file",
    )
    parser.add_argument(
        "-p",
        "--pop",
        metavar="Str",
        help="pop for which sweepfinder2 input is to be created",
        default="all",
        required=False,
    )
    parser.add_argument(
        "-r",
        "--recomb",
        default=False,
        help="whether or not to create recomb map file",
        action="store_true",
    )
    parser.add_argument(
        "-g",
        "--grid",
        default=False,
        help="whether or not to create grid file",
        action="store_true",
    )
    parser.add_argument(
        "-o",
        "--outprefix",
        metavar="Str",
        help="prefix for the output files",
        required=True,
    )
    args = parser.parse_args()
    if len(sys.argv) == 1:
        parser.print_help(sys.stderr)
        sys.exit(1)
    else:
        vcf_to_swpfinder2(
            args.vcf,
            args.map,
            args.anc,
            args.pop,
            args.recomb,
            args.grid,
            args.outprefix,
        )
