# Base Layer
#  Due to depreciation of 11.4.0, we must use 11.3.1.
FROM nvidia/cuda:11.3.1-cudnn8-devel-ubuntu18.04

# Package Downloads
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    python3-dev python3-pip python3-setuptools git g++ wget make libprotobuf-dev protobuf-compiler libopencv-dev \
    libgoogle-glog-dev libboost-all-dev libcaffe-cuda-dev libhdf5-dev libatlas-base-dev ffmpeg

# Python Dependancies
RUN pip3 install --upgrade pip
RUN pip3 install numpy opencv-python 

# Replace CMake with a CUDA-compatible version
RUN wget https://github.com/Kitware/CMake/releases/download/v3.16.0/cmake-3.16.0-Linux-x86_64.tar.gz && \
    tar xzf cmake-3.16.0-Linux-x86_64.tar.gz -C /opt && \
    rm cmake-3.16.0-Linux-x86_64.tar.gz
ENV PATH="/opt/cmake-3.16.0-Linux-x86_64/bin:${PATH}"

# Grab OpenPose
WORKDIR /openpose
RUN git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose.git .

# Download Models
RUN cd /openpose/models/pose/body_25 && wget -O pose_iter_584000.caffemodel -c https://www.dropbox.com/s/3x0xambj2rkyrap/pose_iter_584000.caffemodel?dl=0
RUN cd /openpose/models/face && wget -O pose_iter_116000.caffemodel-c https://www.dropbox.com/s/d08srojpvwnk252/pose_iter_116000.caffemodel?dl=0
RUN cd /openpose/models/hand && wget -O pose_iter_102000.caffemodel -c https://www.dropbox.com/s/gqgsme6sgoo0zxf/pose_iter_102000.caffemodel?dl=0

# Remove Download Capabilities from OpenPose
RUN sed -i 's/executeShInItsFolder "getModels.sh"/# executeShInItsFolder "getModels.sh"/g' /openpose/scripts/ubuntu/install_openpose_JetsonTX2_JetPack3.1.sh
RUN sed -i 's/executeShInItsFolder "getModels.sh"/# executeShInItsFolder "getModels.sh"/g' /openpose/scripts/ubuntu/install_openpose_JetsonTX2_JetPack3.3.sh
RUN sed -i 's/download_model("BODY_25"/# download_model("BODY_25"/g' /openpose/CMakeLists.txt
RUN sed -i 's/78287B57CF85FA89C03F1393D368E5B7/# 78287B57CF85FA89C03F1393D368E5B7/g' /openpose/CMakeLists.txt
RUN sed -i 's/download_model("body (COCO)"/# download_model("body (COCO)"/g' /openpose/CMakeLists.txt
RUN sed -i 's/5156d31f670511fce9b4e28b403f2939/# 5156d31f670511fce9b4e28b403f2939/g' /openpose/CMakeLists.txt
RUN sed -i 's/download_model("body (MPI)"/# download_model("body (MPI)"/g' /openpose/CMakeLists.txt
RUN sed -i 's/2ca0990c7562bd7ae03f3f54afa96e00/# 2ca0990c7562bd7ae03f3f54afa96e00/g' /openpose/CMakeLists.txt
RUN sed -i 's/download_model("face"/# download_model("face"/g' /openpose/CMakeLists.txt
RUN sed -i 's/e747180d728fa4e4418c465828384333/# e747180d728fa4e4418c465828384333/g' /openpose/CMakeLists.txt
RUN sed -i 's/download_model("hand"/# download_model("hand"/g' /openpose/CMakeLists.txt
RUN sed -i 's/a82cfc3fea7c62f159e11bd3674c1531/# a82cfc3fea7c62f159e11bd3674c1531/g' /openpose/CMakeLists.txt

# Build OpenPose
WORKDIR /openpose/build
RUN cmake -DBUILD_PYTHON=ON .. && make -j `nproc`
WORKDIR /openpose

#
# /ᐠ - ˕ -マ
# 
# @hiibolt on GitHub
#
