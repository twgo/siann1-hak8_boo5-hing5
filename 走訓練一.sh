#!/bin/bash

. cmd.sh
. path.sh

# This setup was modified from egs/swbd/s5c, with the following changes:

set -e # exit on error

STAGE=0
if [ -f ./stage.sh ]; then
  # echo 'export STAGE=1' > stage.sh
  . stage.sh
fi
echo "stage = $STAGE"

nj=32

# GMM Acoustic model parameters
numLeaves=3000
numGauss=30000


if [ $STAGE -le 1 ]; then
  utils/utt2spk_to_spk2utt.pl data/train/utt2spk > data/train/spk2utt
  mv data/train data/train_guan5
  chmod +x utils/data/perturb_data_dir_encode_alaw_mulaw.sh
  chmod +x utils/data/perturb_data_dir_encode.sh
  utils/data/perturb_data_dir_encode_alaw_mulaw.sh data/train_guan5 data/train
fi

if [ $STAGE -le 2 ]; then
  rm -rf data/lang_train
  mkdir -p data/tmp
  utils/prepare_lang.sh data/local/dict "<UNK>"  data/tmp/lang_train data/lang_train
fi
