import matplotlib.pyplot as plt
import os

def main():
    dirname = os.path.dirname(os.path.abspath(__file__))
    in_dir = dirname + "/../test/in/"
    out_dir = dirname + "/../test/out/"
    score_prog = dirname + "/calc_score.out"

    tests = 0

    scores    = []
    score_min = int(1e18)
    score_max = int(-1e18)
    score_sum = 0

    min_case = ""
    max_case = ""

    for file in os.listdir(out_dir):
        if len(file) < 4 or file[4:] != ".txt":
            continue

        tests += 1
        score = int(os.popen("cat " + in_dir + file + " " +
                             out_dir + file + " | " + score_prog).read())
        score_sum += score
        scores.append(score)

        if score < score_min:
            score_min = score
            min_case = file
        if score > score_max:
            score_max = score
            max_case = file

    assert tests > 0

    print("lowest : ", f"{score_min:,}", "(" + min_case + ")")
    print("highest: ", f"{score_max:,}", "(" + max_case + ")")
    print("average: ", f"{score_sum // tests:,}")

    plt.figure(figsize=(12, 9), dpi=100)
    plt.hist(scores, bins="auto", ec="black")
    plt.savefig(dirname + "/../score_dist.png")

if __name__ == "__main__":
    main()
