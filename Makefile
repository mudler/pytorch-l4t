# PyTorch Wheel Builder Makefile
# This Makefile replicates the GitHub Actions workflow for local builds

# Default values
PYTORCH_VERSION ?= main
CUDA_VERSION ?= 13.0
CUDA_HOME ?= /usr/local/cuda-13.0
# https://docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/index.html#gpu-feature-list
TORCH_CUDA_ARCH_LIST_SM ?= sm_75,sm_80,sm_86,sm_87,sm_88,sm_89,sm_90,sm_90a,sm_100,sm_100f,sm_100a,sm_103,sm_103f,sm_103a,sm_110,sm_110f,sm_110a,sm_120,sm_120f,sm_120a,sm_121,sm_121f,sm_121a
PYTHON ?= python3
PYTORCH_DIR ?= pytorch-src
DIST_DIR ?= dist

# Convert sm_XX format to numeric format using conversion script
# Use the script relative to the Makefile location
MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
CONVERT_SCRIPT := $(MAKEFILE_DIR)scripts/convert_arch_list.sh
TORCH_CUDA_ARCH_LIST := $(shell $(CONVERT_SCRIPT) "$(TORCH_CUDA_ARCH_LIST_SM)")

.PHONY: build clean install-deps setup-cuda help

help:
	@echo "PyTorch ARM64 Wheel Builder"
	@echo ""
	@echo "Usage:"
	@echo "  make build                    - Build PyTorch wheel"
	@echo "  make clean                    - Clean build artifacts"
	@echo "  make install-deps             - Install build dependencies"
	@echo "  make setup-cuda               - Setup CUDA environment"
	@echo ""
	@echo "Variables:"
	@echo "  PYTORCH_VERSION=$(PYTORCH_VERSION)"
	@echo "  CUDA_VERSION=$(CUDA_VERSION)"
	@echo "  CUDA_HOME=$(CUDA_HOME)"
	@echo "  TORCH_CUDA_ARCH_LIST_SM=$(TORCH_CUDA_ARCH_LIST_SM)"
	@echo "  TORCH_CUDA_ARCH_LIST (numeric)=$(TORCH_CUDA_ARCH_LIST)"
	@echo "  PYTHON=$(PYTHON)"

build: install-deps
	@echo "Building PyTorch wheel..."
	@echo "PyTorch version: $(PYTORCH_VERSION)"
	@echo "CUDA version: $(CUDA_VERSION)"
	@echo "CUDA architectures (sm_XX): $(TORCH_CUDA_ARCH_LIST_SM)"
	@echo "CUDA architectures (numeric): $(TORCH_CUDA_ARCH_LIST)"
	@if [ ! -d "$(PYTORCH_DIR)" ]; then \
		echo "Cloning PyTorch..."; \
		git clone --recursive https://github.com/pytorch/pytorch.git $(PYTORCH_DIR); \
	fi
	cd $(PYTORCH_DIR) && \
		git fetch --all && \
		git checkout $(PYTORCH_VERSION) && \
		git submodule update --init --recursive
	@echo "Setting build environment..."
	@echo "Using TORCH_CUDA_ARCH_LIST=$(TORCH_CUDA_ARCH_LIST)"
	cd $(PYTORCH_DIR) && \
		CUDA_HOME=$(CUDA_HOME) \
		TORCH_CUDA_ARCH_LIST="$(TORCH_CUDA_ARCH_LIST)" \
		USE_CUDA=1 \
		USE_CUDNN=1 \
		MAX_JOBS=$$(nproc) \
		$(PYTHON) setup.py bdist_wheel
	@mkdir -p $(DIST_DIR)
	@cp $(PYTORCH_DIR)/dist/*.whl $(DIST_DIR)/
	@echo "Wheel built successfully! Find it in $(DIST_DIR)/"

clean:
	@echo "Cleaning build artifacts..."
	rm -rf $(PYTORCH_DIR)
	rm -rf $(DIST_DIR)
	@echo "Clean complete."

install-deps:
	@echo "Installing build dependencies..."
	$(PYTHON) -m pip install --upgrade pip
	$(PYTHON) -m pip install cmake ninja pyyaml typing_extensions
	@echo "Build dependencies installed."

setup-cuda:
	@echo "Setting up CUDA environment..."
	@echo "CUDA_HOME: $(CUDA_HOME)"
	@if [ ! -d "$(CUDA_HOME)" ]; then \
		echo "Warning: CUDA_HOME $(CUDA_HOME) does not exist."; \
		echo "Please install CUDA $(CUDA_VERSION) or set CUDA_HOME to the correct path."; \
		exit 1; \
	fi
	@echo "CUDA setup complete."
	@echo "Add to your PATH: $(CUDA_HOME)/bin"
	@echo "Add to your LD_LIBRARY_PATH: $(CUDA_HOME)/lib64"

