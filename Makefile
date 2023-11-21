ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
BUILD_DIR := $(ROOT_DIR)build

$(BUILD_DIR)/sort_dbg: sort.mojo
	mojo build --no-optimization -O0 --debug-level full sort.mojo -o $(BUILD_DIR)/sort_dbg

$(BUILD_DIR)/sort: sort.mojo
	mojo build sort.mojo -o $(BUILD_DIR)/sort

debug: $(BUILD_DIR)/sort_dbg

release: $(BUILD_DIR)/sort

clean:
	rm -rf $(BUILD_DIR)/*

$(info $(shell mkdir -p $(BUILD_DIR)))