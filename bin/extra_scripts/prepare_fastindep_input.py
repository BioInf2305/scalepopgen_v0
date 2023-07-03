import sys
from collections import OrderedDict


def prepare_input(matrix_in, indi_f, fast_indep_in):
    indi_list = []
    sample_dict = {}
    with open(indi_f) as source:
        for line in source:
            line = line.rstrip().split()
            indi_list.append(line[0])
    header = 0
    with open(matrix_in) as source:
        for line in source:
            if header == 0:
                header += 1
            else:
                line = line.split()
                if line[0] not in sample_dict:
                    sample_dict[line[0]] = ["0"] * len(indi_list)
                    sample_dict[line[0]][indi_list.index(line[0])] = "10000"
                if line[1] not in sample_dict:
                    sample_dict[line[1]] = ["0"] * len(indi_list)
                    sample_dict[line[1]][indi_list.index(line[1])] = "10000"
                sample_dict[line[0]][indi_list.index(line[1])] = str(line[2])
                sample_dict[line[1]][indi_list.index(line[0])] = str(line[2])
    with open(fast_indep_in, "w") as dest:
        dest.write(" " + " ".join(indi_list) + "\n")
        for indi in indi_list:
            dest.write(indi + " " + " ".join(sample_dict[indi]) + "\n")


if __name__ == "__main__":
    prepare_input(sys.argv[1], sys.argv[2], sys.argv[3])
