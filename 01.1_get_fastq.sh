#!/bin/bash

# Create temporary directory to hold raw data
args1="/castor/project/proj/maria.d/8_EXPRESSION.D/data.d/01_tmp/"

#if [ ! -e ${args1} ]; then mkdir ${args1}; else echo "directory or file exists"; fi

# Get samples
args2=(SS2_18_418 SS2_18_419 SS2_18_420 SS2_19_037 SS2_19_039 SS2_19_041 SS2_19_043 SS2_19_045 SS2_19_047 SS2_19_049 SS2_19_054 SS2_19_058 SS2_19_106)

# Copy raw data
args3="/castor/project/proj/maria.d/data.d/ESCG_data/"

for i in "${args2[@]}"; do cp -p ${args3}${i}_fastq.tar ${args1}; echo "getting plate ${i}"; done

# Uncompress data
for i in "${args2[@]}"
do
	cd ${args1}
	tar -xf ${i}_fastq.tar
	echo "uncompressing plate ${i}"
	mv mnt/davidson/rickards/pipeline2016/rnaseq/hsa/${i} .  # keep updated
	rm -r mnt
	rm ${i}_fastq.tar
done
 
