# PyTorch ARM64 Wheel Builder

This repository builds PyTorch wheels for ARM64 architecture with CUDA support and uploads them to GitHub releases. The build process can be run via GitHub Actions workflows or locally using the provided Makefile.

## Features

- Builds PyTorch wheels for ARM64 with CUDA support
- Supports multiple Python versions (3.9, 3.10, 3.11, 3.12)
- Configurable CUDA architecture list (`TORCH_CUDA_ARCH_LIST`)
- Generates pip-compatible index files for easy installation
- Local build replication via Makefile

## Default CUDA Architectures

The default `TORCH_CUDA_ARCH_LIST` includes all ARM64 GPU architectures:

```
sm_75,sm_80,sm_86,sm_87,sm_88,sm_89,sm_90,sm_90a,sm_100,sm_100f,sm_100a,sm_103,sm_103f,sm_103a,sm_110,sm_110f,sm_110a,sm_120,sm_120f,sm_120a,sm_121,sm_121f,sm_121a
```

### Architecture Reference

| TORCH_CUDA_ARCH_LIST | GPU Arch | Year | Example GPU |
|---------------------|----------|------|-------------|
| sm_75 | 7.5 (Turing) | 2018 | Most RTX 20xx |
| sm_80, sm_86, sm_87, sm_88 | 8.0, 8.6, 8.7, 8.8 (Ampere) | 2020 | RTX 30xx, Axx |
| sm_89 | 8.9 (Ada) | 2022 | RTX 40xx, L4xx |
| sm_90, sm_90a | 9.0, 9.0a (Hopper) | 2022 | H100 |
| sm_100+ | 10.0+ (Blackwell) | 2024 | GB10, etc. |

## GitHub Actions Workflow

### Triggers

The workflow runs automatically on:
- **Release events**: When a new release is published
- **Manual dispatch**: Can be triggered manually from the Actions tab

### Workflow Inputs (Manual Dispatch)

When triggering manually, you can configure:

- `pytorch_version`: PyTorch git ref (tag/branch/commit) - default: `main`
- `cuda_version`: CUDA version - default: `13.0`
- `torch_cuda_arch_list`: Comma-separated CUDA architectures - default: all ARM64 GPU archs

### Runner Requirements

The workflow requires ARM64 runners. You can use:
- Self-hosted ARM64 runners (recommended)
- GitHub's public ARM64 runners (if available)

To use self-hosted runners, ensure your runner has the label `[self-hosted, linux, ARM64]`.

### Workflow Steps

1. Checks out the repository
2. Sets up Python (from matrix: 3.9, 3.10, 3.11, 3.12)
3. Installs CUDA 13.0 (or specified version)
4. Installs build dependencies (cmake, ninja, pyyaml, typing_extensions)
5. Clones PyTorch repository recursively
6. Sets build environment variables
7. Builds the wheel using `python setup.py bdist_wheel`
8. Uploads wheels as artifacts
9. Generates index files for pip compatibility
10. Uploads wheels and index to GitHub release (on release events)

## Local Build with Makefile

You can replicate the build process locally using the provided Makefile.

### Prerequisites

- ARM64 Linux system
- CUDA installed (default: `/usr/local/cuda-13.0`)
- Python 3.9, 3.10, 3.11, or 3.12
- Git
- Build tools (gcc, make, etc.)

### Makefile Targets

- `make build` - Build PyTorch wheel locally
- `make clean` - Clean build artifacts and cloned PyTorch directory
- `make install-deps` - Install build dependencies
- `make setup-cuda` - Verify CUDA environment setup
- `make help` - Show help message with current variable values

### Makefile Variables

You can override default values:

```bash
# Build specific PyTorch version
make build PYTORCH_VERSION=v2.1.0

# Use different CUDA version
make build CUDA_VERSION=12.4 CUDA_HOME=/usr/local/cuda-12.4

# Build for specific architectures only
make build TORCH_CUDA_ARCH_LIST="sm_89,sm_90"

# Use different Python interpreter
make build PYTHON=python3.11
```

### Example Local Build

```bash
# Install dependencies
make install-deps

# Verify CUDA setup
make setup-cuda

# Build wheel
make build

# Build specific version
make build PYTORCH_VERSION=v2.1.0 TORCH_CUDA_ARCH_LIST="sm_89,sm_90"
```

## Using Built Wheels

### From GitHub Releases

When wheels are uploaded to a release, an `index.html` and `index.txt` file are generated for pip compatibility.

#### Using index.html with --find-links

```bash
pip install torch --find-links https://github.com/OWNER/REPO/releases/download/v1.0.0/index.html
```

#### Using index.txt with --find-links

```bash
pip install torch --find-links https://github.com/OWNER/REPO/releases/download/v1.0.0/index.txt
```

#### In requirements.txt

```txt
--find-links https://github.com/OWNER/REPO/releases/download/v1.0.0/index.html
torch==2.1.0
```

#### Direct Download

You can also download wheels directly from the release assets and install:

```bash
pip install torch-2.1.0-cp311-cp311-linux_aarch64.whl
```

### From Local Build

If you built locally using the Makefile:

```bash
pip install dist/torch-*.whl
```

## Configuration

### Environment Variables

The build process uses these environment variables:

- `CUDA_HOME`: Path to CUDA installation (default: `/usr/local/cuda-13.0`)
- `TORCH_CUDA_ARCH_LIST`: Comma-separated list of CUDA architectures
- `USE_CUDA`: Set to `1` to enable CUDA
- `USE_CUDNN`: Set to `1` to enable cuDNN
- `MAX_JOBS`: Number of parallel build jobs (default: `$(nproc)`)

### Custom Architecture List

To build for specific architectures only, set `TORCH_CUDA_ARCH_LIST`:

```bash
# GitHub Actions (manual dispatch)
# Set torch_cuda_arch_list input to: sm_89,sm_90

# Makefile
make build TORCH_CUDA_ARCH_LIST="sm_89,sm_90"
```

## Troubleshooting

### CUDA Not Found

If CUDA is not found, ensure:
1. CUDA is installed at the expected path
2. `CUDA_HOME` is set correctly
3. CUDA binaries are in your PATH

### Build Fails

Common issues:
- Insufficient memory: Reduce `MAX_JOBS`
- Missing dependencies: Run `make install-deps`
- Submodule issues: Run `make clean` and rebuild

### ARM64 Runner Issues

If using self-hosted runners:
- Ensure runner is registered with labels: `self-hosted`, `linux`, `ARM64`
- Verify CUDA is installed on the runner
- Check runner has sufficient resources (CPU, RAM, disk)

## License

This repository is for building PyTorch wheels. PyTorch itself is licensed under the BSD-style license. See the [PyTorch repository](https://github.com/pytorch/pytorch) for details.


