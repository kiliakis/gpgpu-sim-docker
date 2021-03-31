FROM 172.9.0.240:5000/evolve-zeppelin-gpu:0.9.0.4.3
# FROM nvidia/cuda:10.1-devel-ubuntu16.04

USER root

# ENV HOME="/root" \
#     GITUSER="kiliakis" \
#     CPUCORES="10" \
#     HOST="ubuntu" \
#     DOMAIN="local" 

WORKDIR /root

# copy files
# COPY data/* /root/install/
# COPY data/.bashrc data/.git-completion.bash data/.git-prompt.sh /root/

# install packages
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update -y &&  apt-get install -yq build-essential apt-utils wget vim htop \
    software-properties-common xutils-dev build-essential bison \
    zlib1g-dev flex libglu1-mesa-dev binutils-gold libboost-system-dev \
    libboost-filesystem-dev libopenmpi-dev openmpi-bin libopenmpi-dev \
    gfortran torque-server torque-client torque-mom torque-pam \
    freeglut3 freeglut3-dev git curl python3.7 python

# python-pip python-dev
# install python packages
# RUN add-apt-repository ppa:deadsnakes/ppa && \
#     apt-get update -y && \
#     apt-get -yq install python3.7 python

RUN mkdir /root/install && \
    cd /root/install && curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o get-pip.py && \
    python get-pip.py && \
    python -m pip install pyyaml numpy cycler

# python3.7-pip && \
# python3.7 -m pip install pyyaml numpy cycler


#RUN cd git && git clone https://github.com/NVIDIA/cuda-samples.git cuda-11.2-samples && \
#    cd cuda-11.2-samples && git checkout -b v11.2

# install dot files
RUN mkdir /root/git && \
    cd /root/git && git clone --branch=gpusim-docker https://github.com/kiliakis/config.git && cd config && \
    cp -r .bashrc .vim .vimrc .gitconfig .git-* /root/ 
# source /root/.bashrc

COPY data/finalize_installation.sh /root/

#install cuda
COPY data/cuda_10.1.105_418.39_linux.run /root/install/
RUN cd install && sh cuda_10.1.105_418.39_linux.run --silent --override --samples --samplespath=/root

#compile sdk
RUN cd /root/NVIDIA_CUDA-10.1_Samples && make -j -i -k; exit 0

#install gpu-app-collection
RUN cd /root && git clone https://github.com/accel-sim/gpu-app-collection.git && \
    cd /gpu-app-collection && git clone https://github.com/kiliakis/native-gpu-benchmarks.git
    

# RUN export CUDA_INSTALL_PATH=/usr/local/cuda && \
#     cd gpu-app-collection && \
#     /bin/bash -c "source ./src/setup_environment"
# RUN export CUDA_INSTALL_PATH=/usr/local/cuda && \
#     export BINDIR=/root/gpu-app-collection/src/..//bin/10.1   && \
#     export MAKE_ARGS="GENCODE_SM10= GENCODE_SM13= GENCODE_SM20= GENCODE_SM20= CUBLAS_LIB=cublas_static CUDNN_LIB=cudnn_static" && \
#     export GPUAPPS_SETUP_ENVIRONMENT_WAS_RUN=1&& \
#     export GPUAPPS_ROOT=/root/gpu-app-collection/src/../  && \
#     export CUDA_PATH=/usr/local/cuda&& \
#     export NVDIA_COMPUTE_SDK_LOCATION=&& \
#     export CUDA_VERSION=10.1  && \
#     export CUDA_VERSION_MAJOR=10  && \
#     export CUDAHOME=/usr/local/cuda   && \
#     export BINSUBDIR=release  && \
#     export CUDA_CPPFLAGS="-gencode=arch=compute_30,code=compute_30 -gencode=arch=compute_35,code=compute_35 -gencode=arch=compute_50,code=compute_50 -gencode=arch=compute_60,code=compute_60 -gencode=arch=compute_62,code=compute_62 -gencode=arch=compute_70,code=compute_70 -gencode=arch=compute_75,code=compute_75 --cudart shared"  && \
#     export NVCC_ADDITIONAL_ARGS="--cudart shared"   && \
#     export GENCODE_FLAGS="-gencode=arch=compute_30,code=compute_30 -gencode=arch=compute_35,code=compute_35 -gencode=arch=compute_50,code=compute_50 -gencode=arch=compute_60,code=compute_60 -gencode=arch=compute_62,code=compute_62 -gencode=arch=compute_70,code=compute_70 -gencode=arch=compute_75,code=compute_75" && \
#     cd /root/gpu-app-collection && \
#     make all -i -j -C ./src; exit 0

# RUN ln -s /root/NVIDIA_CUDA-10.1_Samples/bin/x86_64/linux/release /root/gpu-app-collection/bin/10.1/release/sdk && \
#     cd /root/gpu-app-collection && git clone https://github.com/kiliakis/native-gpu-benchmarks.git

