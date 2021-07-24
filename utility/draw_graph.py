import numpy as np
import matplotlib.pyplot as plt
import os

def main(testcase_name):
    dirname = os.path.dirname(os.path.abspath(__file__))
    in_dir = dirname + "/../test/in/" + testcase_name + ".txt"
    out_dir = dirname + "/../test/snapshot/"
    score_prog = dirname + "/../executable/calc_score.out"
    files = len(os.listdir(out_dir))

    data = [0] * files

    for file in os.listdir(out_dir):
        if len(file) < 4 or file[4:] != ".txt":
            files -= 1
            continue
        # int("0000.txt"[:4]) = int("0000") = 0
        data[int(file[:4])] = int(os.popen("cat " + in_dir +
                                           " " + out_dir + file + " | " + score_prog).read())

    assert max(data[:files]) != min(data[:files])

    plt.figure(figsize=(12, 9), dpi=100)
    plt.title("Score changes", fontsize=25)
    plt.xlabel("time [10 ms]", fontsize=20)
    plt.ylabel("score", fontsize=20)
    plt.plot([i for i in range(files)], data[:files])
    plt.yticks(np.arange(min(data[:files]), max(data[:files]),
                         step=(max(data[:files]) - min(data[:files])) // 5))
    plt.savefig(dirname + "/../score_graph.png")

if __name__ == "__main__":
    main(input())
