FROM ubuntu:trusty
MAINTAINER ryepdx

RUN apt-get -y -q update
RUN apt-get -y install language-pack-en-base
RUN dpkg-reconfigure locales
RUN apt-get -y install software-properties-common curl wget
RUN wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key | apt-key add -
RUN add-apt-repository "deb http://llvm.org/apt/trusty/ llvm-toolchain-trusty-3.7 main"
RUN add-apt-repository -y ppa:ethereum/ethereum-qt
RUN add-apt-repository -y ppa:ethereum/ethereum
RUN add-apt-repository -y ppa:ethereum/ethereum-dev
RUN apt-add-repository -y ppa:george-edison55/cmake-3.x
RUN apt-get -y -q update
RUN apt-get -y -q upgrade

RUN apt-get install -y -q build-essential libgmp3-dev golang git cmake libboost-all-dev libgmp-dev libleveldb-dev libminiupnpc-dev libreadline-dev libncurses5-dev libcurl4-openssl-dev libcryptopp-dev libjson-rpc-cpp-dev libmicrohttpd-dev libjsoncpp-dev libargtable2-dev llvm-3.7-dev libedit-dev mesa-common-dev ocl-icd-libopencl1 opencl-headers libgoogle-perftools-dev qtbase5-dev qt5-default qtdeclarative5-dev libqt5webkit5-dev libqt5webengine5-dev ocl-icd-dev libv8-dev
RUN cd ~ && git clone https://github.com/ethereum/go-ethereum

RUN cd ~ && git clone https://github.com/ethereum/webthree-helpers && webthree-helpers/scripts/ethupdate.sh --no-push --simple-pull --project solidity && webthree-helpers/scripts/ethbuild.sh --no-git --cores 2 --project solidity

ENV GOPATH /root/go
RUN mkdir -p ~/go; echo "export GOPATH=\$HOME/go" >> ~/.bashrc
RUN cd ~/go-ethereum && make geth

RUN apt-get -y -q update
RUN apt-get install -q -y git python python-pip
RUN pip completion --bash >> ~/.bashrc
RUN export WORKON_HOME=~/.virtualenvs && mkdir ~/.virtualenvs && echo "export WORKON_HOME=\$WORKON_HOME" >> ~/.bashrc && echo "source /usr/local/bin/virtualenvwrapper.sh" >> ~/.bashrc && echo "export PIP_VIRTUALENV_BASE=\$WORKON_HOME" >> ~/.bashrc 
RUN pip install virtualenvwrapper
RUN /bin/bash -c 'source /usr/local/bin/virtualenvwrapper.sh && mkvirtualenv makerdao && workon makerdao && pip install mkdocs'
COPY init.sh init.sh
RUN chmod +x init.sh
RUN apt-get -y -q install vim

RUN ln -s ~/solidity/build/solc/solc /bin/solc
RUN ln -s ~/go-ethereum/build/bin/geth /bin/geth

# IPFS
RUN echo "export PATH=\$GOPATH/bin:\$PATH:" >> ~/.bashrc && echo "export PATH=\$PATH:/usr/local/opt/go/libexec/bin" >> ~/.bashrc
RUN GOPATH=/root/go && go get -u github.com/ipfs/go-ipfs/cmd/ipfs

ENTRYPOINT ["ssh-agent", "bash"]
