#!/bin/bash

# Code and logs directories
codedir="/castor/project/proj/maria.d/8_EXPRESSION.D/scripts.d/01_sandbox/"
logdir=$(echo "${codedir}log.d/")
outdir="/castor/project/proj/maria.d/8_EXPRESSION.D/output.d/01_out/"
lognm="02.2_trim_galore"
#----------------------------------------------------------------#
# Raw fasta files
args1="/castor/project/proj/maria.d/8_EXPRESSION.D/data.d/01_tmp"
##args11=($(ls ${args1}/*/rawdata/*/*fastq.gz))

# Number of lines (cells) to run in the for loop
## adjust SLURM --time
args111=96
#---------------------------------------------------------------#

# Run
## Create output directory
if [ -e ${outdir}${lognm} ] 
then 
	echo "${outdir}${lognm}/ exists"
	exit
else
	mkdir ${outdir}${lognm}
	touch ${outdir}${lognm}/paths.tmp
fi

## Create log directory
if [ -e ${logdir}${lognm} ] 
then 
	echo "${logdir}${lognm}/ exists"
	exit
else
	mkdir ${logdir}${lognm}
	touch ${logdir}${lognm}/CELLS-NOTPASS
fi

# Temp file with paths - write them in parts to speed up
args11=($(ls ${args1}) )
for i in "${args11[@]}"
do 
	CELL=($(ls ${args1}/${i}/rawdata))
	#args_i=($(ls ${args1}/${i}/rawdata/*/*fastq.gz))   ### WAY TOO SLOW
	#printf "%s\n" "${args_i[@]}" >> ${outdir}${lognm}/paths.tmp
	for j in "${CELL[@]}"
	do
		echo "${args1}/${i}/rawdata/${j}/${j}_R1.fastq.gz" >> ${outdir}${lognm}/paths.tmp
	done
	echo "printing paths for ${i}"
done

# Number of jobs (arrays)
args1111=$(cat ${outdir}${lognm}/paths.tmp | wc -l)
args1111=$(((${args1111} / ${args111}) + 1))

# Execute
args1="${outdir}${lognm}/paths.tmp"
sbatch --account=sens2018122 --array=1-${args1111} --time=24:00:00 --job-name=${lognm} --output=${lognm}_%A_%a.stdout --export=NUMLINES=${args111},codedir=${codedir},logdir=${logdir}${lognm},outdir=${outdir}${lognm},lognm=${lognm},args1=${args1} ${codedir}02.2_trim_galore.run

