#!/bin/sh

#train
head -n 250  atheism_vs_compgraphics.vec | tail -n 100  > ath_vs_cg_train_vec.data
tail -n 250   atheism_vs_compgraphics.vec  >> ath_vs_cg_train_vec.data

head -n 250  atheism_vs_compgraphics.lab | tail -n 100  > ath_vs_cg_train_lab.data
tail -n 250   atheism_vs_compgraphics.lab  >> ath_vs_cg_train_lab.data


#test

tail -n 1750  atheism_vs_compgraphics.vec | head -n 1500  > ath_vs_cg_test_vec.data
tail -n 1750  atheism_vs_compgraphics.lab | head -n 1500  > ath_vs_cg_test_lab.data

