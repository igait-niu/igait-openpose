# OpenPose Singularity Container for iGait Pipeline

This directory contains a multi-stage Singularity build for OpenPose with CUDA 12.8 support on Ubuntu 22.04.

## Built Images

- **`openpose-base.sif`** (6.1 GB) - Base image with CUDA 12.8, system packages, and CMake
- **`igait-openpose.sif`** (6.7 GB) - Complete OpenPose installation with Python bindings

## Quick Start

The images are already built! To use OpenPose:

```bash
# Test GPU access
singularity exec --nv igait-openpose.sif nvidia-smi

# Run OpenPose on a video
singularity exec --nv \
  --bind /path/to/data:/data \
  igait-openpose.sif \
  /openpose/build/examples/openpose/openpose.bin \
  --video /data/input.mp4 \
  --write_json /data/output/
```

## Building from Source

If you need to rebuild the containers:

### Prerequisites

- Singularity/Apptainer installed with fakeroot support
- NVIDIA GPU with CUDA 12.8 drivers
- At least 20GB of free disk space
- Network access to download packages

### Step 1: Clone OpenPose and Apply Patches

```bash
cd /lstr/sahara/zwlab/jw/igait-pipeline/igait-openpose

# Initialize OpenPose submodule if not already done
cd openpose
git submodule update --init --recursive
cd ..
```

The OpenPose source has already been patched for CUDA 12.8 compatibility:
- ✅ CMake version requirements updated (2.8/3.0 → 3.5)
- ✅ Old GPU architectures removed (KEPLER sm_35, sm_37)
- ✅ Modern GPU architectures added (AMPERE sm_89, sm_90)

### Step 2: Build Base Image

```bash
# Set cache directories to use Lustre filesystem
export SINGULARITY_CACHEDIR=/lstr/sahara/zwlab/jw/.singularity-cache
export SINGULARITY_TMPDIR=/lstr/sahara/zwlab/jw/.singularity-tmp
mkdir -p "$SINGULARITY_CACHEDIR" "$SINGULARITY_TMPDIR"

# Build base image (~10-15 minutes)
singularity build --fakeroot openpose-base.sif openpose-base.def
```

The base image includes:
- NVIDIA CUDA 12.8 with cuDNN 9
- Ubuntu 22.04 LTS
- System packages (OpenCV, Boost, HDF5, Atlas, etc.)
- Python 3.10 with numpy and opencv-python
- CMake 4.1.2 from Kitware repository

### Step 3: Build OpenPose Image

```bash
# Build OpenPose on top of base image (~30-45 minutes)
singularity build --fakeroot igait-openpose.sif openpose.def
```

Or use the convenience script:

```bash
./build.sh
```

The OpenPose image includes:
- Pre-downloaded model files (Body_25, face, hand)
- Compiled OpenPose with CUDA 12.8 support
- Python bindings (optional)
- GPU architectures: Maxwell, Pascal, Volta, Turing, Ampere (sm_50 through sm_90)

## Build Details

### CUDA 12.8 Compatibility Patches

The following patches were applied to make OpenPose compatible with CUDA 12.8:

1. **CMakeLists.txt files** - Updated minimum CMake version to 3.5:
   - `/openpose/CMakeLists.txt`
   - `/openpose/3rdparty/caffe/CMakeLists.txt`
   - `/openpose/3rdparty/pybind11/CMakeLists.txt`
   - `/openpose/3rdparty/pybind11/tools/pybind11Tools.cmake`

2. **CUDA Architecture Configuration** - Removed deprecated architectures:
   - `/openpose/cmake/Cuda.cmake` - Set `KEPLER=""` (removed sm_35, sm_37)
   - `/openpose/3rdparty/caffe/cmake/Cuda.cmake` - Set `KEPLER=""` (removed sm_35, sm_37)
   - Added newer AMPERE architectures: `AMPERE="80 86 89 90"`

3. **System Dependencies**:
   - Added `libc6-dev` for missing system headers
   - Added `linux-libc-dev` for kernel headers

### Multi-Stage Build Benefits

The multi-stage approach provides:
- **Faster rebuilds** - Base image cached with all system packages
- **Easier debugging** - Isolates package installation from compilation
- **Smaller iterations** - Only rebuild OpenPose layer when source changes

## Troubleshooting

### CUDA Error 999

If you see `Cuda check failed (999 vs. 0): unknown error`:
- Make sure you're using `--nv` flag with singularity
- Verify CUDA drivers are loaded: `nvidia-smi`
- Check GPU is accessible: `singularity exec --nv igait-openpose.sif nvidia-smi`

### Out of Space Errors

If the build fails with disk space errors:
- Set `SINGULARITY_TMPDIR` to a filesystem with more space
- Clean up old build artifacts: `rm -rf /lstr/sahara/zwlab/jw/.singularity-tmp/*`

### CMake Version Errors

If you see `Compatibility with CMake < 3.5 has been removed`:
- The OpenPose source may have been re-cloned
- Re-apply the patches listed above manually

## Integration with iGait Pipeline

The OpenPose container is used in Stage 4 (Pose Estimation) of the iGait pipeline:

```rust
// igait-pipeline/src/stages/s4_pose_estimation.rs
const PATH_TO_OPENPOSE_SIF: &str = "/lstr/sahara/zwlab/jw/igait-pipeline/igait-openpose/igait-openpose.sif";
```

The pipeline automatically:
1. Binds the output directory to `/outputs` in the container
2. Runs OpenPose with `--nv` for GPU access
3. Processes both front and side camera views
4. Outputs JSON keypoints and annotated videos

## Authors

- Built by @hiibolt with assistance from GitHub Copilot
- Original OpenPose by CMU Perceptual Computing Lab
- CUDA 12.8 compatibility patches applied November 2024

## License

OpenPose is licensed under the CMU license. See `/openpose/LICENSE` for details.
