# Base Layer
# Due to depreciation of 11.4.0, we must use 11.3.1.
FROM nvidia/cuda:11.1.1-cudnn8-devel-ubuntu20.04

# 如果你在中国，将镜像站提供的sources.list保存到dockerfile同目录下，使用apt镜像仓库以加快下载/节省流量。
# COPY ./sources.list /etc/apt/sources.list

# Package Downloads
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    python3-dev python3-pip python3-setuptools git g++ wget make libprotobuf-dev protobuf-compiler libopencv-dev \
    libgoogle-glog-dev libboost-all-dev libhdf5-dev libatlas-base-dev ffmpeg

# Python Dependancies
RUN pip3 install --upgrade pip
# RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
RUN pip3 install numpy opencv-python 

# Replace CMake with a CUDA-compatible version: https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html
RUN wget --progress=bar https://github.com/Kitware/CMake/releases/download/v3.29.5/cmake-3.29.5-linux-x86_64.tar.gz && \
    tar xzf cmake-3.29.5-linux-x86_64.tar.gz -C /opt && \
    rm cmake-3.29.5-linux-x86_64.tar.gz
ENV PATH="/opt/cmake-3.29.5-linux-x86_64/bin:$PATH"

# Grab OpenPose
ENV OPENPOSE_DIR="/home/openpose"
WORKDIR $OPENPOSE_DIR
RUN git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose.git .
RUN sed -i 's/sudo //g' $OPENPOSE_DIR/scripts/ubuntu/install_deps.sh && bash $OPENPOSE_DIR/scripts/ubuntu/install_deps.sh

# Download Models
RUN cd $OPENPOSE_DIR/models/pose/body_25 && wget --progress=bar -O pose_iter_584000.caffemodel -c https://www.dropbox.com/s/3x0xambj2rkyrap/pose_iter_584000.caffemodel?dl=0
RUN cd $OPENPOSE_DIR/models/face && wget --progress=bar -O pose_iter_116000.caffemodel -c https://www.dropbox.com/s/d08srojpvwnk252/pose_iter_116000.caffemodel?dl=0
RUN cd $OPENPOSE_DIR/models/hand && wget --progress=bar -O pose_iter_102000.caffemodel -c https://www.dropbox.com/s/gqgsme6sgoo0zxf/pose_iter_102000.caffemodel?dl=0

# Remove Download Capabilities from OpenPose
RUN sed -i 's/executeShInItsFolder "getModels.sh"/# executeShInItsFolder "getModels.sh"/g' $OPENPOSE_DIR/scripts/ubuntu/install_openpose_JetsonTX2_JetPack3.1.sh
RUN sed -i 's/executeShInItsFolder "getModels.sh"/# executeShInItsFolder "getModels.sh"/g' $OPENPOSE_DIR/scripts/ubuntu/install_openpose_JetsonTX2_JetPack3.3.sh
RUN sed -i 's/download_model("BODY_25"/# download_model("BODY_25"/g' $OPENPOSE_DIR/CMakeLists.txt
RUN sed -i 's/78287B57CF85FA89C03F1393D368E5B7/# 78287B57CF85FA89C03F1393D368E5B7/g' $OPENPOSE_DIR/CMakeLists.txt
RUN sed -i 's/download_model("body (COCO)"/# download_model("body (COCO)"/g' $OPENPOSE_DIR/CMakeLists.txt
RUN sed -i 's/5156d31f670511fce9b4e28b403f2939/# 5156d31f670511fce9b4e28b403f2939/g' $OPENPOSE_DIR/CMakeLists.txt
RUN sed -i 's/download_model("body (MPI)"/# download_model("body (MPI)"/g' $OPENPOSE_DIR/CMakeLists.txt
RUN sed -i 's/2ca0990c7562bd7ae03f3f54afa96e00/# 2ca0990c7562bd7ae03f3f54afa96e00/g' $OPENPOSE_DIR/CMakeLists.txt
RUN sed -i 's/download_model("face"/# download_model("face"/g' $OPENPOSE_DIR/CMakeLists.txt
RUN sed -i 's/e747180d728fa4e4418c465828384333/# e747180d728fa4e4418c465828384333/g' $OPENPOSE_DIR/CMakeLists.txt
RUN sed -i 's/download_model("hand"/# download_model("hand"/g' $OPENPOSE_DIR/CMakeLists.txt
RUN sed -i 's/a82cfc3fea7c62f159e11bd3674c1531/# a82cfc3fea7c62f159e11bd3674c1531/g' $OPENPOSE_DIR/CMakeLists.txt

# Build OpenPose
WORKDIR $OPENPOSE_DIR/gpu_build
RUN cmake -DBUILD_PYTHON=ON .. && make -j `nproc`
WORKDIR $OPENPOSE_DIR/cpu_build
RUN cmake -DBUILD_PYTHON=ON -DGPU_MODE=CPU_ONLY -DOWNLOAD_HAND_MODEL=OFF -DOWNLOAD_FACE_MODEL=OFF .. && make -j `nproc`

# clean apt
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR $OPENPOSE_DIR

LABEL maintainer="hiibolt, AClon"
LABEL version="0.1"
LABEL description="OpenPose Docker Image, built on CUDA 11.1.1, cuDNN 8, and Ubuntu 20.04. Built files are in `openpose/gpu_build` and `openpose/cpu_build`. Use CUDA 11.1 for Easymocap."
LABEL url="https://github.com/igait-niu/igait-openpose/blob/main/Dockerfile"
LABEL image_size="13.09 GB"
