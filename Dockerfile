
FROM nvidia/cuda:10.1-devel-ubuntu16.04

ENV HOME /root

# make directories
run mkdir $HOME/git && mkdir $HOME/install

# copy files
COPY data/* $HOME/install/

# install packages
RUN apt-get update -y && apt-get install -yq build-essential apt-utils gcc-4.8 gcc-4.9 \
g++-4.8 g++-4.9 wget git vim linux-headers-4.4.0-194 linux-headers-4.4.0-194-generic \
libxi-dev libxmu-dev libglu1-mesa-dev kmod libxml2

# setup gcc versions
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 60 && \
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 50 && \
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.8 60 && \
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.9 50 && \
update-alternatives --set gcc /usr/bin/gcc-4.9 && \
update-alternatives --set g++ /usr/bin/g++-4.9 

# append variables to the bashrc
RUN echo "export PATH=/usr/local/cuda/bin:$PATH" >> $HOME/.bashrc && \
echo "export LD_LIBRARY_PATH=/usr/local/cuda/lib64" >> $HOME/.bashrc && \
echo "export RTE_SDK=$HOME/install/dpdk-16.11/build" >> $HOME/.bashrc

# setup dpdk
RUN cd $HOME/install && tar -xzvf dpdk-16.11.tar.gz && \
cd dpdk-16.11 &&  make config T=x86_64-native-linuxapp-gcc && \
make RTE_KERNELDIR=/lib/modules/4.4.0-194-generic/build && \
ln -s $HOME/install/dpdk-16.11/mk $HOME/install/dpdk-16.11/build/mk && \
ln -s $HOME/install/dpdk-16.11/build $HOME/install/dpdk-16.11/build/x86_64-native-linuxapp-gcc

# setup cuda sdk
# RUN cd $HOME/install && sh cuda_6.5.14_linux_64.run -silent --override --toolkit --samples && \
#ln -s /usr/local/cuda-6.5 /usr/local/cuda && \
#/usr/local/cuda/bin/nvcc --version

RUN cd $HOME/install && sh cuda_10.1.105_418.39_linux.run --silent --samples --samplespath=/usr/local/cuda-10.1/ && \
ln -s /usr/local/cuda-10.1 /usr/local/cuda

# setup megakv    
RUN cd $HOME/git && git clone https://github.com/pzrq/megakv.git && \
update-alternatives --set gcc /usr/bin/gcc-4.8 && \
update-alternatives --set g++ /usr/bin/g++-4.8

RUN export PATH=/usr/local/cuda/bin:$PATH && \
export LD_LIBRARY_PATH=/usr/local/cuda/lib64 && \
export RTE_SDK=$HOME/install/dpdk-16.11/build && \
cd $HOME/git/megakv/libgpuhash && make && cd $HOME/git/megakv/src && make
