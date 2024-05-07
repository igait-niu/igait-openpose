# OpenPose Dockerfiles
## CPU + Python API + CUDA + cuDNN (./Dockerfile)
CMake also seems to have issues with building to support CMake, which the work here seems to fix - however, it targets a now depreciated version of nvidia/cuda. By changing the target from nvidia/cuda:11.4.0-cudnn8-devel-ubuntu18.04 to nvidia/cuda:11.3.1-cudnn8-devel-ubuntu18.04, it now has a functional source image.

## CPU + Python API (./Dockerfile-CPU)
The above with some removed dependencies for GPU support, namely the usage of `caffe-cpu` instead of libcaffe-cuda-dev.

## Example Usage
- Start the Docker Container: (for the CUDA version, you may need to pass your GPUs with the `--gpus` flag)

  `docker run -t -d --name openpose ghcr.io/hiibolt/igait-openpose:latest`
- Open a bash shell in the container:

  `docker exec -it openpose bash`
- Run an inference:

  `./build/examples/openpose/openpose.bin --image_dir /openpose/examples/media --display 0 --write_images /output_images`
- Exit the container:

  `exit`
- Copy the output images to your current directory:

  `docker cp openpose:/output_images ./output_images`

## Expected Behaviour
### CPU
- With the above example usage commands, a body pose skeleton should be mapped onto each output image
  ![image](https://github.com/hiibolt/igait-openpose/assets/91273156/bce65308-1bc4-4ba3-bb69-3662785aec11)
- You may expect a significantly slower experience compared to CUDA acceleration, which OpenPose will warn you of. If you intend to only use CPU, you may safely discard this error.
### CUDA
- Running `nvidia-smi` should display readily available GPUs.
  ![image](https://github.com/hiibolt/igait-openpose/assets/91273156/3a1317c3-7c89-4ba8-8a82-abd8156785f5)
- Running an inference should debug output the availability and usage of at least one GPU
  ![image](https://github.com/hiibolt/igait-openpose/assets/91273156/1cf5832e-75ba-4062-a776-66ee32ec6f3d)
- With the above example command, a body pose skeleton should be mapped onto each output image
  ![image](https://github.com/hiibolt/igait-openpose/assets/91273156/abffec80-1ff5-49e1-bc9a-465bdcabbd03)

Developed by @hiibolt on GitHub
