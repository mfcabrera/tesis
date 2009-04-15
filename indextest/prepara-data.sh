#!/bin/sh

# #train
# head -n 200  atheism_vs_compgraphics.vec   > ath_vs_cg_train_vec.data
# tail -n 200   atheism_vs_compgraphics.vec  >> ath_vs_cg_train_vec.data

# head -n 200  atheism_vs_compgraphics.lab  > ath_vs_cg_train_lab.data
# tail -n 200   atheism_vs_compgraphics.lab  >> ath_vs_cg_train_lab.data


# #test

# tail -n 1800  atheism_vs_compgraphics.vec | head -n 1600  > ath_vs_cg_test_vec.data
# tail -n 1800  atheism_vs_compgraphics.lab | head -n 1600  > ath_vs_cg_test_lab.data


 #train
 head -n 200   machw_vs_ibmhw.vec   > machw_vs_ibmhw_train_vec.data
 tail -n 200   machw_vs_ibmhw.vec  >> machw_vs_ibmhw_train_vec.data

 head -n 200   machw_vs_ibmhw.lab  > machw_vs_ibmhw_train_lab.data
 tail -n 200   machw_vs_ibmhw.lab  >> machw_vs_ibmhw_train_lab.data


 #test

 tail -n 1800  machw_vs_ibmhw.vec | head -n 1600  > machw_vs_ibmhw_test_vec.data
 tail -n 1800  machw_vs_ibmhw.lab | head -n 1600  > machw_vs_ibmhw_test_lab.data


