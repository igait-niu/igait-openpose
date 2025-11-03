# OpenPose CUDA 12.8 Build Notes

## Summary

Successfully built OpenPose with CUDA 12.8 support on Ubuntu 22.04 using Singularity containers.

## Key Challenges Solved

### 1. CMake Version Compatibility
**Problem**: Modern CMake (4.1.2) removed support for projects declaring CMake < 3.5  
**Solution**: Updated all CMakeLists.txt files to require CMake 3.5:
- OpenPose main CMakeLists.txt
- Caffe submodule CMakeLists.txt
- pybind11 CMakeLists.txt (including test files)
- pybind11Tools.cmake

### 2. CUDA Architecture Compatibility
**Problem**: CUDA 12.8 dropped support for old GPU architectures (compute_35, sm_35, sm_37)  
**Solution**: Patched CUDA configuration files to remove KEPLER architectures:
- `/openpose/cmake/Cuda.cmake` - Set `KEPLER=""`
- `/openpose/3rdparty/caffe/cmake/Cuda.cmake` - Set `KEPLER=""`
- Added modern AMPERE architectures: sm_89, sm_90

### 3. Missing System Headers
**Problem**: Compilation failed with missing `sys/cdefs.h` and `bits/ss_flags.h`  
**Solution**: Added `libc6-dev` and `linux-libc-dev` packages to the build environment

### 4. Lustre Filesystem Issues
**Problem**: Singularity build failures due to /tmp space limitations and filesystem incompatibilities  
**Solution**: 
- Redirected SINGULARITY_CACHEDIR and SINGULARITY_TMPDIR to Lustre
- Used multi-stage build to cache base image
- Reduced parallel compilation jobs from unlimited to 32

### 5. Python Version Mismatch
**Problem**: Python 3.6.8 (system default) couldn't import packages installed for Python 3.12  
**Solution**: Updated pipeline to explicitly use `python3.12` and `pip3.12`

### 6. GPU Access in Container
**Problem**: OpenPose couldn't access GPU (CUDA error 999)  
**Solution**: Changed from `apptainer run` to `singularity exec --nv` with proper GPU passthrough

## Build Statistics

- **Base image size**: 6.1 GB
- **Final image size**: 6.7 GB
- **Base image build time**: ~10-15 minutes
- **OpenPose build time**: ~30-45 minutes
- **Total patches applied**: 10+ files modified

## Files Modified Locally

All modifications were made to the local OpenPose clone before container build:

```
openpose/CMakeLists.txt
openpose/cmake/Cuda.cmake
openpose/3rdparty/caffe/CMakeLists.txt
openpose/3rdparty/caffe/cmake/Cuda.cmake
openpose/3rdparty/pybind11/CMakeLists.txt
openpose/3rdparty/pybind11/tools/pybind11Tools.cmake
openpose/3rdparty/pybind11/tests/*/CMakeLists.txt (7 files)
```

## Container Usage

```bash
# Test GPU access
singularity exec --nv igait-openpose.sif nvidia-smi

# Run OpenPose
singularity exec --nv \
  --bind /data:/data \
  igait-openpose.sif \
  /openpose/build/examples/openpose/openpose.bin \
  --video /data/input.mp4 \
  --write_json /data/output/
```

## Integration with iGait Pipeline

The container is used in stage 4 (Pose Estimation):
- Automatically called by the Rust pipeline
- Processes both front and side camera views
- Outputs JSON keypoints and annotated videos

## Date

November 2, 2024
