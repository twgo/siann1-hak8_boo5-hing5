FROM ubuntu:16.04

MAINTAINER sih4sing5hong5

ENV CPU_CORE 4

# 準備環境
RUN \
  apt-get update -qq && \
  apt-get install -y \
  python3 g++ python3-dev libyaml-dev libxslt1-dev git subversion automake libtool zlib1g-dev libboost-all-dev libbz2-dev liblzma-dev libgoogle-perftools-dev libxmlrpc-c++.*-dev make \
  libc6-dev-i386 linux-libc-dev gcc-multilib libx11-dev \
  csh \
  bzip2 wget \
  libatlas-dev libatlas-base-dev \
  moreutils \
  python3-pip \
  normalize-audio sox

#  apt-get install -y python3 g++ python3-dev libyaml-dev libxslt1-dev git subversion automake libtool zlib1g-dev libboost-all-dev libbz2-dev liblzma-dev libgoogle-perftools-dev libxmlrpc-c++.*-dev make  # 工具 && \
#  apt-get install -y libc6-dev-i386 linux-libc-dev gcc-multilib libx11-dev # libx11-dev:i386 # HTK && \
#  apt-get install -y csh # SPTK && \
#  apt-get install -y bzip2 wget  # kaldi/tool && \
#  apt-get install -y libatlas-dev libatlas-base-dev  # kaldi/src && \
#  apt-get install -y moreutils  # ts 指令 && \
#  apt-get install -y python3-pip
# normalize-audio sox # 語料庫愛的
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

# 掠語料
WORKDIR /usr/local/
RUN apt-get install curl
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash
RUN apt-get install git-lfs
RUN git lfs install
RUN echo 20180326+20180207twisas
RUN git lfs clone https://github.com/twgo/pian7sik4_gi2liau7.git
WORKDIR /usr/local/pian7sik4_gi2liau7
RUN git pull
RUN git pull # twisas-trs Sin-bun, Kong-po
RUN git pull # tw0102,twisas-trs guan-pun kah pun-tiau


##  匯入語料
WORKDIR /usr/local/hok8-bu7/
RUN pip3 install --upgrade tai5-uan5_gian5-gi2_hok8-bu7 hue7jip8 tw01 twisas
RUN echo tw0102-json
RUN pip3 install --upgrade https://github.com/Taiwanese-Corpus/hue7jip8/archive/master.zip
RUN echo 0821
RUN pip3 install --upgrade https://github.com/Taiwanese-Corpus/Renyuan-Lyu_2000_TW01/archive/master.zip
RUN pip3 install --upgrade https://github.com/i3thuan5/tai5-uan5_gian5-gi2_hok8-bu7/archive/master.zip
RUN git pull
RUN python3 manage.py migrate

RUN python3 manage.py 匯入TW0102_json 口語 /usr/local/pian7sik4_gi2liau7/

## 匯出語料
ENV KALDI_S5C /usr/local/kaldi/egs/taiwanese/s5c
RUN python3 manage.py 匯出Kaldi格式資料 臺語 拆做聲韻莫調 $KALDI_S5C

## 準備free-syllable的inside test
RUN cat $KALDI_S5C/data/train/text | sed 's/^[^ ]* //g' | cat > $KALDI_S5C/twisas-text
RUN python3 manage.py 轉Kaldi音節text 臺語 $KALDI_S5C/data/train/ $KALDI_S5C/data/train_free
RUN python3 manage.py 轉Kaldi音節fst 臺語 拆做聲韻莫調 $KALDI_S5C/twisas-text $KALDI_S5C


WORKDIR $KALDI_S5C
RUN git pull
RUN bash -c 'time bash -x 走訓練.sh  2>&1'

RUN utils/subset_data_dir.sh --first data/train_free 20 data/train_dev
RUN bash -c 'time bash -x 產生free-syllable的graph.sh'

RUN sed 's/nj\=[0-9]\+/nj\=1/g' -i 走評估.sh
RUN bash -c 'time bash -x 走評估.sh data/lang_free data/train_dev'

RUN bash -c 'time bash 看結果.sh'

