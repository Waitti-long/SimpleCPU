import sys
import re

DEBUG = False

cmd = {"NOP": 0, "LD": 1, "LN": 2, "CP": 3, "ST": 4, "SHL": 5, "ADD": 6, "SUB": 7, "JZ": 8, "JB": 9, "JMP": 10,
       "XOR": 11, "OR": 12, "AND": 13, "SHR": 14, "NOT": 15, "PUSH": 16, "POP": 17}
reg = {"$0": 1, "$1": 4, "BP": 2, "SP": 3}

if __name__ == '__main__':
    lines = None
    file_name = "1.asm"
    if not DEBUG:
        if len(sys.argv) <= 1:
            print("require file name")
            exit(1)
        file_name = sys.argv[1]
    file = open(file_name, "r", encoding="utf-8")
    lines = file.readlines()
    file.close()
    st = 0
    labels = {}

    for line in lines:
        if line.endswith(":"):
            raise Exception("require code after label")
        if line.endswith(":\n"):
            labels[line[:-2]] = st
            continue
        st += 1
    st = 0
    print("CONTENT BEGIN")
    for line in lines:
        if line.endswith(":\n"):
            continue
        strs = list(filter(lambda x: x not in ["", "\n", None],
                           re.split(r"([A-Z]+) ([0-9A-Z$]+),? ?([0-9A-Z$]+)?", line)))
        # print(strs)
        res = ""
        res += bin(cmd[strs[0]])[2:].zfill(5)
        if len(strs) == 1:
            res += "00000000000"
        else:
            if strs[1] in reg:
                res += bin(reg[strs[1]])[2:].zfill(3)
            else:
                res += "000"
            if len(strs) == 3:
                if strs[2] in reg:
                    res += bin(reg[strs[2]])[2:].zfill(8)
                else:
                    res += bin(int(strs[2]))[2:].zfill(8)
            else:
                if strs[1] in labels:
                    res += bin(labels[strs[1]])[2:].zfill(8)
                elif strs[1] not in reg:
                    res += bin(int(strs[1]))[2:].zfill(8)
                else:
                    res += "00000000"
        # print(res)
        print("\t" + hex(st)[2:].zfill(4), ":", hex(int(res, 2))[2:].zfill(4).upper() + ";")
        st += 1
    print("\t[%s..0FFF] : 0000;" % (hex(st)[2:].zfill(4).upper()))
    print("END;")
