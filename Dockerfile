FROM ubuntu:16.04
MAINTAINER sih4sing5hong5

RUN apt-get update -qq
RUN apt-get install -y python3 virtualenv g++ python3-dev libyaml-dev libxslt1-dev git subversion automake libtool zlib1g-dev libboost-all-dev libbz2-dev liblzma-dev libgoogle-perftools-dev libxmlrpc-c++.*-dev libpq-dev postgresql postgresql-contrib make 
RUN apt-get install -y libc6-dev-i386 linux-libc-dev gcc-multilib libx11-dev # libx11-dev:i386 # HTK
RUN apt-get install -y csh # SPTK

# Switch locale
RUN locale-gen zh_TW.UTF-8
ENV LC_ALL zh_TW.UTF-8

WORKDIR /usr/local/
RUN git clone https://github.com/sih4sing5hong5/kaldi.git
RUN apt-get install -y bzip2 wget
WORKDIR /usr/local/kaldi/tools
RUN make -j 4
WORKDIR /usr/local/kaldi/src
RUN ./configure && make depend -j 4 && make -j 4
RUN git clone https://github.com/sih4sing5hong5/hok8-bu7.git
