# OpenPose Dockerfiles
## CPU + Python API + CUDA + cuDNN (./Dockerfile)
CMake also seems to have issues with building to support CMake, which the work here seems to fix - however, it targets a now depreciated version of nvidia/cuda. By changing the target from nvidia/cuda:11.4.0-cudnn8-devel-ubuntu18.04 to nvidia/cuda:11.3.1-cudnn8-devel-ubuntu18.04, it now has a functional source image.

## CPU + Python API (./Dockerfile-CPU)
The above with some removed dependencies for GPU support, namely the usage of `caffe-cpu` instead of libcaffe-cuda-dev.