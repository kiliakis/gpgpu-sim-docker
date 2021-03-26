FROM nvidia/cuda:10.1-devel-ubuntu16.04

USER root

ENV HOME="/root" \
    GITUSER="kiliakis" \
    CPUCORES="10" \
    HOST="ubuntu" \
    DOMAIN="local" 

WORKDIR $HOME

# make directories
RUN mkdir $HOME/git && mkdir $HOME/install

# copy files
# COPY data/* $HOME/install/
# COPY data/.bashrc data/.git-completion.bash data/.git-prompt.sh $HOME/

# install packages
RUN apt-get update -y && apt-get install -yq build-essential apt-utils wget vim htop \
    software-properties-common xutils-dev build-essential bison \
    zlib1g-dev flex libglu1-mesa-dev binutils-gold libboost-system-dev \
    libboost-filesystem-dev libopenmpi-dev openmpi-bin libopenmpi-dev \
    gfortran torque-server torque-client torque-mom torque-pam

# python-pip python-dev
# install python packages
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update -y && \
    apt-get -yq install python3.7 python python-pip
# python3.7-pip && \
# python3.7 -m pip install pyyaml numpy cycler

RUN apt-get install -yq git

#RUN cd git && git clone https://github.com/NVIDIA/cuda-samples.git cuda-11.2-samples && \
#    cd cuda-11.2-samples && git checkout -b v11.2

# install dot files
RUN cd $HOME/git && git clone --branch=gpusim-docker https://github.com/kiliakis/config.git && cd config && \
cp -r .bashrc .vim .vimrc .gitconfig .git-* $HOME/ 
# source $HOME/.bashrc

#install cuda
COPY data/cuda_10.1.105_418.39_linux.run $HOME/install/
RUN cd install && sh cuda_10.1.105_418.39_linux.run --silent --override --samples --samplespath=/root
# --toolkit --toolkitpath=/root/install/cuda-10.1 

#compile sdk
RUN cd $HOME/NVIDIA_CUDA-10.1_Samples && make -j -i -k; exit 0  
# RUN cd $HOME/install && 



# install gpgpusim (optional)
# RUN cd $HOME && git clone https://github.com/$GITUSER/gpgpu-sim.git && \
#     cd gpgpu-sim && \
#     source setup_environment && \
#     make

# install simulations-gpgpu
# RUN cd $HOME && git clone --recurse-submodules https://github.com/kiliakis/simulations-gpgpu.git && \
#    cd simulations-gpgpu/benchmarks/src/cuda/rodinia-3.1/ && \
#    git checkout master

#install gpu-app-collection
RUN cd $HOME && git clone https://github.com/accel-sim/gpu-app-collection.git
    
COPY data/setup_environment $HOME/gpu-app-collection/src/
RUN cd gpu-app-collection && \
    cp $HOME/install/setup_environment src/ && \
    /bin/bash -c "source ./src/setup_environment"
# make all -i -j -C ./src; \
# sh get_data.sh; exit 0

# . src/setup_environment; \
# /bin/bash -c "source ./src/setup_environment"; \

# setup gcc versions
# RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 60 && \
# update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 50 && \
# update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.8 60 && \
# update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.9 50 && \
# update-alternatives --set gcc /usr/bin/gcc-4.9 && \
# update-alternatives --set g++ /usr/bin/g++-4.9 

# append variables to the bashrc
# RUN echo "export PATH=/usr/local/cuda/bin:$PATH" >> $HOME/.bashrc && \
# echo "export LD_LIBRARY_PATH=/usr/local/cuda/lib64" >> $HOME/.bashrc && \
# echo "export RTE_SDK=$HOME/install/dpdk-16.11/build" >> $HOME/.bashrc

# setup dpdk
# RUN cd $HOME/install && tar -xzvf dpdk-16.11.tar.gz && \
# cd dpdk-16.11 &&  make config T=x86_64-native-linuxapp-gcc && \
# make RTE_KERNELDIR=/lib/modules/4.4.0-194-generic/build && \
# ln -s $HOME/install/dpdk-16.11/mk $HOME/install/dpdk-16.11/build/mk && \
# ln -s $HOME/install/dpdk-16.11/build $HOME/install/dpdk-16.11/build/x86_64-native-linuxapp-gcc

# setup cuda sdk
# RUN cd $HOME/install && sh cuda_6.5.14_linux_64.run -silent --override --toolkit --samples && \
#ln -s /usr/local/cuda-6.5 /usr/local/cuda && \
#/usr/local/cuda/bin/nvcc --version

# RUN cd $HOME/install && sh cuda_10.1.105_418.39_linux.run --silent --samples --samplespath=/usr/local/cuda-10.1/ && \
# ln -s /usr/local/cuda-10.1 /usr/local/cuda

# setup megakv    
# RUN cd $HOME/git && git clone https://github.com/pzrq/megakv.git && \
# update-alternatives --set gcc /usr/bin/gcc-4.8 && \
# update-alternatives --set g++ /usr/bin/g++-4.8

# RUN export PATH=/usr/local/cuda/bin:$PATH && \
# export LD_LIBRARY_PATH=/usr/local/cuda/lib64 && \
# export RTE_SDK=$HOME/install/dpdk-16.11/build && \
# cd $HOME/git/megakv/libgpuhash && make && cd $HOME/git/megakv/src && make
