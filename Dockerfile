# FROM nvidia/cuda:10.1-devel-ubuntu16.04
# FROM nvidia/cuda:10.1-devel-ubuntu16.04
FROM ubuntu:14.04

USER root

ENV HOME="/root" \
    GITUSER="kiliakis" \
    REMOTEUSER="kiliakis" \
    CPUCORES="40" \
    HOST="ubuntu" \
    DOMAIN="local" 

WORKDIR $HOME

# make directories
RUN mkdir $HOME/git && mkdir $HOME/install

# copy data
COPY data/gpgpusim-vm-data/install/* $HOME/install/
COPY data/gpgpusim-vm-data/simulations-gpgpu $HOME/ 
# COPY data/cuda_9.0.176_384.81_linux.run $HOME/install/
# copy files
# COPY data/* $HOME/install/
# COPY data/.bashrc data/.git-completion.bash data/.git-prompt.sh $HOME/

# install packages
RUN apt-get update -y && apt-get install -yq build-essential apt-utils wget vim htop \
    software-properties-common xutils-dev build-essential bison \
    zlib1g-dev flex libglu1-mesa-dev binutils-gold libboost-system-dev \
    libboost-filesystem-dev libopenmpi-dev openmpi-bin libopenmpi-dev \
    gfortran torque-server torque-client torque-mom torque-pam \
    freeglut3 freeglut3-dev git curl python

# python-pip python-dev
# install python packages
# RUN add-apt-repository ppa:deadsnakes/ppa && \
    # apt-get update -y && \
    # apt-get -yq install python3.7 python

# RUN cd $HOME/install && curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o get-pip.py && \
    # python get-pip.py && \
RUN python -m pip install pyyaml numpy cycler

# python3.7-pip && \
# python3.7 -m pip install pyyaml numpy cycler


#RUN cd git && git clone https://github.com/NVIDIA/cuda-samples.git cuda-11.2-samples && \
#    cd cuda-11.2-samples && git checkout -b v11.2

# install dot files
RUN cd $HOME/git && git clone --branch=gpusim https://github.com/kiliakis/config.git && cd config && \
cp -r .bashrc .vim .vimrc .gitconfig .git-* $HOME/ 
# source $HOME/.bashrc

#install cuda

RUN cd install && sh cuda_9.0.176_384.81_linux.run --silent --override --samples --samplespath=/root
# --toolkit --toolkitpath=/root/install/cuda-10.1 


# torque set-up
RUN /etc/init.d/torque-mom stop \
    /etc/init.d/torque-scheduler stop \
    /etc/init.d/torque-server stop \
    pbs_server -f -t create \
    killall pbs_server \
    echo "$IP    ${HOST}.${DOMAIN}" >> /etc/hosts \
    echo "${HOST}.${DOMAIN}" > /etc/torque/server_name \
    echo "${HOST}.${DOMAIN}" > /var/spool/torque/server_priv/acl_svr/acl_hosts \
    echo "root@${HOST}.${DOMAIN}" > /var/spool/torque/server_priv/acl_svr/operators \
    echo "root@${HOST}.${DOMAIN}" > /var/spool/torque/server_priv/acl_svr/managers \
    echo "${HOST}.${DOMAIN} np=${CPUCORES}" > /var/spool/torque/server_priv/nodes \
    echo "${HOST}.${DOMAIN}" > /var/spool/torque/mom_priv/config \
    /etc/init.d/torque-server start \
    /etc/init.d/torque-scheduler start \
    /etc/init.d/torque-mom start \
    qmgr -c 'set server scheduling = true' \
    qmgr -c 'set server keep_completed = 60' \
    qmgr -c 'set server mom_job_sync = true' \
    qmgr -c 'create queue batch' \
    qmgr -c 'set queue batch queue_type = execution' \
    qmgr -c 'set queue batch started = true' \
    qmgr -c 'set queue batch enabled = true' \
    qmgr -c 'set queue batch resources_default.walltime = 1:00:00' \
    qmgr -c 'set queue batch resources_default.nodes = 1' \
    qmgr -c 'set server default_queue = batch' \
    qmgr -c 'set server submit_hosts = ${HOST}' \
    qmgr -c 'set server allow_node_submit = true'

#compile sdk
# RUN cd $HOME/NVIDIA_CUDA-10.1_Samples && make -j -i -k; exit 0
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
# RUN cd $HOME && git clone https://github.com/accel-sim/gpu-app-collection.git

# # COPY data/setup_environment $HOME/gpu-app-collection/src/

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
#     cd $HOME/gpu-app-collection && \
#     make all -i -j -C ./src; exit 0
#     sh get_data.sh; exit 0

# RUN ln -s $HOME/NVIDIA_CUDA-10.1_Samples/bin/x86_64/linux/release $HOME/gpu-app-collection/bin/10.1/release/sdk
# RUN cd $HOME/gpu-app-collection && git clone https://github.com/kiliakis/native-gpu-benchmarks.git
# COPY data/finalize_installation.sh $HOME/

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
