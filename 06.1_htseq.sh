#!/bin/bash

# Code and logs directories
codedir="/castor/project/proj/maria.d/8_EXPRESSION.D/scripts.d/01_sandbox/"
logdir=$(echo "${codedir}log.d/")
outdir="/castor/project/proj/maria.d/8_EXPRESSION.D/output.d/01_out/"
lognm="06.1_htseq" 
#-----------------------------------------------------------------------#

# LOCAL VARIABLES
# Input files with bam STAR mapping results
args1=("/castor/project/proj/maria.d/8_EXPRESSION.D/output.d/01_out/04.0_star_map/" \
"/castor/project/proj/maria.d/8_EXPRESSION.D/output.d/01_out/04.1_star_map/" )

# Number of lines (cells) to run in the for loop
## adjust SLURM --time (it takes roughly 6 minutes per cell)
args111=20

# Directory where the annotation is
args2="/castor/project/proj/maria.d/8_EXPRESSION.D/output.d/99_out/00.1_chrom_seq_removed_99.3_makeGTF-hg38.gencode.v37-99.1_makeGTF-ERCC92.gtf"
#-----------------------------------------------------------------------#

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

# Temp file with paths
for z in "${args1[@]}"
do
args11=($(ls -d ${z}SS2_*) )
	for i in "${args11[@]}"
	do
		CELL=($(ls ${i} | grep -v "NOTPASS"))
		for j in "${CELL[@]}"
		do
			echo "${i}/${j}/${j}_R1_Aligned.sortedByCoord.out.bam" >> ${outdir}${lognm}/paths.tmp
		done
		echo "printing paths for ${i}"
	done
done

# Number of jobs (arrays)
args1111=$(cat ${outdir}${lognm}/paths.tmp | wc -l)
args1111=$(((${args1111} / ${args111}) + 1))

# Execute
args1="${outdir}${lognm}/paths.tmp"

sbatch --account=sens2018122 --array=1-${args1111} --time=06:00:00 --job-name=${lognm} --output=${lognm}_%A_%a.stdout --export=NUMLINES=${args111},codedir=${codedir},logdir=${logdir}${lognm},outdir=${outdir}${lognm},lognm=${lognm},args1=${args1},args2=${args2} ${codedir}06.0_htseq.run

unset args1 args111 args1111 args2
#-----------------------------------------------------------------------#
