FROM nvidia/cuda:10.1-devel-ubuntu16.04

USER ROOT

ENV HOME="/root" \
    GITUSER="kiliakis" \
    CPUCORES="8" \
    HOST="ubuntu" \
    DOMAIN="local" 

WORKDIR $HOME

# make directories
run mkdir $HOME/git && mkdir $HOME/install

# copy files
COPY data/* $HOME/install/
# COPY data/.bashrc data/.git-completion.bash data/.git-prompt.sh $HOME/

# install packages
RUN apt-get update -y && apt-get install -yq build-essential apt-utils wget vim htop \
    software-properties-common xutils-dev build-essential bison \
    zlib1g-dev flex libglu1-mesa-dev binutils-gold libboost-system-dev \
    libboost-filesystem-dev libopenmpi-dev openmpi-bin libopenmpi-dev \
    gfortran torque-server torque-client torque-mom torque-pam \
    python-pip python-dev

# install python packages
RUN pip install pyyaml numpy cycler

# install dot files
RUN cd $HOME/git && git clone --branch=gpusim https://github.com/${GITUSER}/config.git && cd config && \
    cp -r .bashrc .vim .vimrc .gitconfig .git-* $HOME/ && \
    source $HOME/.bashrc

# install gpgpusim (optional)
# RUN cd $HOME && git clone https://github.com/$GITUSER/gpgpu-sim.git && \
#     cd gpgpu-sim && \
#     source setup_environment && \
#     make

# install simulations-gpgpu
RUN cd $HOME && git clone --recurse-submodules https://github.com/$GITUSER/simulations-gpgpu.git && \
    cd simulations-gpgpu/benchmarks/src/cuda/rodinia-3.1/ && \
    git checkout master

#install gpu-app-collection
# RUN cd $HOME && git clone https://github.com/$GITUSER/gpu-app-collection.git

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
