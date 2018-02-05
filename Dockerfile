FROM ubuntu:16.04
MAINTAINER sih4sing5hong5

ENV CPU_CORE 4

# 準備環境
RUN apt-get update -qq
RUN apt-get install -y python3 g++ python3-dev libyaml-dev libxslt1-dev git subversion automake libtool zlib1g-dev libboost-all-dev libbz2-dev liblzma-dev libgoogle-perftools-dev libxmlrpc-c++.*-dev make  # 工具
RUN apt-get install -y libc6-dev-i386 linux-libc-dev gcc-multilib libx11-dev # libx11-dev:i386 # HTK
RUN apt-get install -y csh # SPTK
RUN apt-get install -y bzip2 wget  # kaldi/tool
RUN apt-get install -y libatlas-dev libatlas-base-dev  # kaldi/src
RUN apt-get install -y moreutils  # ts 指令
RUN apt-get install -y python3-pip
RUN pip3 install --upgrade pip

## Switch locale
RUN apt-get install -y locales
RUN locale-gen zh_TW.UTF-8
ENV LC_ALL zh_TW.UTF-8

## 用會著的python套件
RUN pip3 install tai5-uan5_gian5-gi2_hok8-bu7 hue7jip8 tw01

# 安裝kaldi
WORKDIR /usr/local/
RUN git clone https://github.com/sih4sing5hong5/kaldi.git

WORKDIR /usr/local/kaldi/tools
RUN make -j $CPU_CORE

WORKDIR /usr/local/kaldi/src
RUN ./configure && make depend -j $CPU_CORE && make -j $CPU_CORE


WORKDIR /usr/local/
RUN git clone https://github.com/sih4sing5hong5/hok8-bu7.git

WORKDIR /usr/local/hok8-bu7/
RUN python3 manage.py migrate

# 掠語料
# download twisas
# python manage.py 匯入台文語料庫2版 ~/git/gi2_liau7_khoo3/twisas2.json

# download tw01
# COPY tw01 tw01
# RUN python3 manage.py 匯入TW01 tw01

RUN python3 manage.py 匯出Kaldi格式資料 臺語 /usr/local/kaldi/egs/taiwanese/s5c

WORKDIR /usr/local/kaldi/egs/taiwanese/s5c
RUN bash -c 'time bash -x 走訓練.sh  2>&1 | ts "[%Y-%m-%d %H:%M:%S]" | tee log_run'
