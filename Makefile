ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
BUILD_DIR := $(ROOT_DIR)build

$(BUILD_DIR)/solve_dbg: solve.mojo common/io.mojo common/stringvector.mojo common/hashmap.mojo
	mojo build --no-optimization -O0 --debug-level full solve.mojo -o $(BUILD_DIR)/solve_dbg

$(BUILD_DIR)/solve: solve.mojo common/io.mojo common/stringvector.mojo common/hashmap.mojo
	mojo build solve.mojo -o $(BUILD_DIR)/solve

debug_nocache:
	mojo build --no-optimization -O0 --debug-level full solve.mojo -o $(BUILD_DIR)/solve_dbg

debug: $(BUILD_DIR)/solve_dbg

release: $(BUILD_DIR)/solve

clean:
	rm -rf $(BUILD_DIR)/*

$(info $(shell mkdir -p $(BUILD_DIR)))