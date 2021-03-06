# C++
CXX     = g++
STD     = -std=gnu++17
WFLAGS  = -fmax-errors=1 -Wall -Wextra -Wno-unknown-pragmas -Wcast-align -Wcast-qual -Wconversion -Wdisabled-optimization -Wdouble-promotion -Wfloat-equal -Winit-self -Winvalid-pch -Wlogical-op -Wmultichar -Wpedantic -Wredundant-decls -Wshadow -Wsign-promo -Wunused-const-variable
OFLAGS  = -O2
DFLAGS  = -O0 -g3 -D_GLIBCXX_DEBUG -D_FORTIFY_SOURCE=2 -ftrapv -fsanitize=undefined
TFLAGS  = -pthread

# command
OPEN      = /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe /c start
VISUALIZE = cargo run --manifest-path $(VISUALIZER_DIR)/Cargo.toml --release --bin vis
GENERATE  = cargo run --manifest-path $(VISUALIZER_DIR)/Cargo.toml --release --bin gen
PYTHON    = python3
FFMPEG    = ffmpeg
DEBUGGER  = gdb

# directory
TEST_IN_DIR    = test/in
TEST_OUT_DIR   = test/out
SNAPSHOT_DIR   = test/snapshot
PNG_DIR        = png
VISUALIZER_DIR = visualizer
EXECUTABLE_DIR = executable
SRC_DIR        = src
UTILITY_DIR    = utility

# source file
SRC            = $(SRC_DIR)/main.cpp
CALC_SCORE_SRC = $(UTILITY_DIR)/calc_score.cpp

# filename
SVG_NAME   = out.svg
PNG_NAME   = out.png
MOV_NAME   = vis.mov
GRAPH_NAME = score_graph.png
DIST_NAME  = score_dist.png
TMP        = tmp.txt

# executable
NORMAL_OUT     = $(EXECUTABLE_DIR)/normal.out
DEBUG_OUT      = $(EXECUTABLE_DIR)/debug.out
PARALLEL_OUT   = $(EXECUTABLE_DIR)/parallel.out
SNAPSHOT_OUT   = $(EXECUTABLE_DIR)/snapshot.out
CALC_SCORE_OUT = $(EXECUTABLE_DIR)/calc_score.out

# default
case  = 0000
files = 500

all:	$(NORMAL_OUT) $(DEBUG_OUT) $(PARALLEL_OUT) $(SNAPSHOT_OUT) $(CALC_SCORE_OUT)
clean:
	rm -f $(NORMAL_OUT) $(DEBUG_OUT) $(PARALLEL_OUT) $(SNAPSHOT_OUT) $(CALC_SCORE_OUT) $(TMP)

# compilation
$(NORMAL_OUT): $(SRC)
	$(CXX) $(STD) $(WFLAGS) $(OFLAGS) $(SRC) -o $(NORMAL_OUT)
$(DEBUG_OUT): $(SRC)
	$(CXX) $(STD) $(WFLAGS) $(DFLAGS) $(SRC) -o $(DEBUG_OUT)
$(PARALLEL_OUT): $(SRC)
	$(CXX) $(STD) $(WFLAGS) $(OFLAGS) -DPARALLEL $(SRC) $(TFLAGS) -o $(PARALLEL_OUT)
$(SNAPSHOT_OUT): $(SRC)
	$(CXX) $(STD) $(WFLAGS) $(OFLAGS) -DSNAPSHOT $(SRC) $(TFLAGS) -o $(SNAPSHOT_OUT)
$(CALC_SCORE_OUT): $(CALC_SCORE_SRC)
	$(CXX) $(STD) $(WFLAGS) $(OFLAGS) $(CALC_SCORE_SRC) -o $(CALC_SCORE_OUT)

gen:
	rm -f $(TMP); \
	rm -f $(TEST_IN_DIR)/*; \
	i=0 \
	&& while [ "$$i" -lt $(files) ]; do \
		echo "$$i" >> $(TMP) \
		&& i=$$(( i + 1 )); \
	done \
	&& $(GENERATE) $(TMP) \
	&& mv in/* $(TEST_IN_DIR)/ \
	&& rm -rf in

normal: $(NORMAL_OUT) $(CALC_SCORE_OUT)
	rm -f $(TMP); \
	rm -f $(PNG_NAME); \
	$(NORMAL_OUT) < $(TEST_IN_DIR)/$(case).txt > $(TMP) \
	&& cat $(TMP) \
	&& $(VISUALIZE) $(TEST_IN_DIR)/$(case).txt $(TMP) \
	&& $(FFMPEG) -width 1024 -i $(SVG_NAME) $(PNG_NAME) 2> /dev/null \
	&& rm -f $(SVG_NAME) \
	&& $(OPEN) $(PNG_NAME)

debug: $(DEBUG_OUT)
	$(DEBUG_OUT) < $(TEST_IN_DIR)/$(case).txt

debugger: $(DEBUG_OUT)
	$(DEBUGGER) $(DEBUG_OUT) -ex "start < $(TEST_IN_DIR)/$(case).txt"
	@# $(DEBUGGER) $(DEBUG_OUT) -o "break set -n main" -o "process launch -i $(TEST_IN_DIR)/$(case).txt"

graph: $(SNAPSHOT_OUT) $(CALC_SCORE_OUT)
	rm -f $(GRAPH_NAME); \
	rm -f $(SNAPSHOT_DIR)/*; \
	$(SNAPSHOT_OUT) < $(TEST_IN_DIR)/$(case).txt \
	&& echo $(case) | $(PYTHON) $(UTILITY_DIR)/draw_graph.py \
	&& $(OPEN) $(GRAPH_NAME)

mov: $(SNAPSHOT_OUT) $(CALC_SCORE_OUT)
	rm -f $(MOV_NAME); \
	rm -f $(GRAPH_NAME); \
	rm -f $(SNAPSHOT_DIR)/* $(PNG_DIR)/*; \
	$(SNAPSHOT_OUT) < $(TEST_IN_DIR)/$(case).txt \
	&& for file in $(SNAPSHOT_DIR)/*; do \
		$(VISUALIZE) $(TEST_IN_DIR)/$(case).txt $${file} \
		&& $(FFMPEG) -width 1024 -i $(SVG_NAME) $(PNG_DIR)/$$(basename $${file} .txt).png 2> /dev/null; \
	done \
	&& rm -f $(SVG_NAME) \
	&& $(FFMPEG) -i $(PNG_DIR)/%04d.png -vcodec libx264 $(MOV_NAME) \
	&& $(OPEN) $(MOV_NAME) \
	&& echo $(case) | $(PYTHON) $(UTILITY_DIR)/draw_graph.py \
	&& $(OPEN) $(GRAPH_NAME)

multi: $(PARALLEL_OUT) $(CALC_SCORE_OUT)
	rm -f $(TEST_OUT_DIR)/*; \
	rm -f $(DIST_NAME); \
	$(PARALLEL_OUT) \
	&& $(PYTHON) $(UTILITY_DIR)/calc_multi_scores.py \
	&& $(OPEN) $(DIST_NAME)
