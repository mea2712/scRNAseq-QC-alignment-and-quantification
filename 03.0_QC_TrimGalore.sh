#!/bin/bash

# Code and logs directories
codedir="/castor/project/proj/maria.d/8_EXPRESSION.D/scripts.d/01_sandbox/"
logdir=$(echo "${codedir}log.d/")
outdir="/castor/project/proj/maria.d/8_EXPRESSION.D/output.d/01_out/"
lognm="03.0_QC_TrimGalore"
#----------------------------------------------------------------#

# Directories where trimmed fastq data are
args1="${outdir}02.2_trim_galore/"
### args11=($( echo $(ls ${args1}*/*/*_R1_trimmed_fastqc.html))) # WAY TOO SLOW AND VECTOR MAY BECOME TOO MEMORY SAAVY 

# Number of lines (cells) to run in the for loop
## adjust SLURM --time
args111=100
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
	touch ${outdir}${lognm}/CELLS-PASS
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

# Temp file with paths
##printf "%s\n" "${args11[@]}" > ${outdir}${lognm}/CELLS-PASS
args11=($(ls -d ${args1}SS2_*) )
for i in "${args11[@]}"
do
	CELL=($(ls ${i}))
	for j in "${CELL[@]}"
	do
		echo "${i}/${j}/${j}_R1_trimmed_fastqc.html" >> ${outdir}${lognm}/paths.tmp
	done
	echo "printing paths for ${i}"
done



# Number of jobs (arrays)
args1111=$(cat ${outdir}${lognm}/paths.tmp | wc -l)
args1111=$(((${args1111} / ${args111}) + 1))

# Execute
args1="${outdir}${lognm}/paths.tmp"
args2="${logdir}${lognm}/CELLS-NOTPASS"
args3="${outdir}${lognm}/CELLS-PASS"

sbatch --account=sens2018122 --array=1-${args1111} --time=03:00:00 --job-name=${lognm} --output=${lognm}_%A_%a.stdout --export=NUMLINES=${args111},codedir=${codedir},logdir=${logdir}${lognm},outdir=${outdir}${lognm},lognm=${lognm},args1=${args1},args2=${args2},args3=${args3} ${codedir}03.0_QC_TrimGalore.run

