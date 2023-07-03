import re
import sys
from collections import OrderedDict


def main_function(input_log_files):
    k_value_dict = OrderedDict()
    with open("pong_input.map", "w") as dest:
        for file_name in input_log_files:
            with open(file_name) as source:
                for line in source:
                    if line.startswith("CV"):
                        line = line.rstrip()
                        pattern = re.compile("CV error \(K=([0-9]+)\):\s+(.*)")
                        match = re.findall(pattern, line)
                        k_value = int(match[0][0])
                        record_list = [
                            "run"
                            + str(k_value)
                            + "\t"
                            + str(k_value)
                            + "\t"
                            + file_name
                        ]
                        k_value_dict[k_value] = record_list[:]
        k_value_list = list(k_value_dict.keys())
        sortedk_val_list = sorted(k_value_list)
        check_order_list = [
            "err" if (sortedk_val_list[i] - sortedk_val_list[i - 1]) > 1 else "ok"
            for i in range(1, len(sortedk_val_list))
        ]
        if "err" in check_order_list:
            print(
                "k values are not consecutives, check which k value has not generated ADMIXTURE Q file"
            )
            sys.exit(1)
        else:
            for k in sortedk_val_list:
                k_record_list = k_value_dict[k]
                dest.write("\t".join(k_record_list))
                dest.write("\n")


if __name__ == "__main__":
    main_function(sys.argv[1:])
