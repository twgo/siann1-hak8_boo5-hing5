FROM ubuntu:16.04
MAINTAINER sih4sing5hong5

RUN apt-get update -qq
# 工具
RUN apt-get install -y python3 virtualenv g++ python3-dev libyaml-dev libxslt1-dev git subversion automake libtool zlib1g-dev libboost-all-dev libbz2-dev liblzma-dev libgoogle-perftools-dev libxmlrpc-c++.*-dev libpq-dev postgresql postgresql-contrib make 
RUN apt-get install -y libc6-dev-i386 linux-libc-dev gcc-multilib libx11-dev # libx11-dev:i386 # HTK
RUN apt-get install -y csh # SPTK

# Switch locale
RUN locale-gen zh_TW.UTF-8
ENV LC_ALL zh_TW.UTF-8

WORKDIR /usr/local/
RUN git clone https://github.com/sih4sing5hong5/kaldi.git
RUN apt-get install -y bzip2 wget
 # kaldi/tool
WORKDIR /usr/local/kaldi/tools
RUN make -j 4

WORKDIR /usr/local/kaldi/src
RUN apt-get install -y libatlas-dev libatlas-base-dev
# kaldi/src
# RUN ./configure && make depend -j 4 && make -j 4

# WORKDIR /usr/local/
RUN git clone https://github.com/sih4sing5hong5/hok8-bu7.git
RUN apt-get install -y python3-pip
RUN pip3 install --upgrade pip
RUN pip3 install tai5-uan5_gian5-gi2_hok8-bu7 hue7jip8 tw01
# WORKDIR /usr/local/hok8-bu7/
WORKDIR hok8-bu7/
RUN python3 manage.py migrate

# download twisas
# python manage.py 匯入台文語料庫2版 ~/git/gi2_liau7_khoo3/twisas2.json

# download tw01
# COPY tw01 tw01
# RUN python3 manage.py 匯入TW01 tw01

RUN python3 manage.py 匯出Kaldi格式資料 臺語 /usr/local/kaldi/egs/taiwanese/s5c

WORKDIR /usr/local/kaldi/egs/taiwanese/s5c
RUN apt-get install -y moreutils  # ts 指令
RUN bash -c 'time bash -x 走訓練.sh  2>&1 | ts "[%Y-%m-%d %H:%M:%S]" | tee log_run'
