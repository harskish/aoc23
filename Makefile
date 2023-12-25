ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
BUILD_DIR := $(ROOT_DIR)build

debug_nocache: clean
	mojo build --no-optimization -O0 --debug-level full solve.mojo -o $(BUILD_DIR)/solve_dbg

clean:
	rm -rf $(BUILD_DIR)/*

$(info $(shell mkdir -p $(BUILD_DIR)))