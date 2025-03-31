#!/bin/bash

<<'_//COMMENT//_'
This script will execute .../code.d/09.0_merge_count_matrices.[run,R] 
.run will read path to HQ cells htseq count data and merge the files into 1 matrix
_//COMMENT//_
#---------------------------------------------------------------------#

# Code and logs directories
codedir="/castor/project/proj/maria.d/8_EXPRESSION.D/scripts.d/01_sandbox/"
logdir=$(echo "${codedir}log.d/")
outdir="/castor/project/proj/maria.d/8_EXPRESSION.D/output.d/01_out/"
lognm="09.2_merge_count_matrices"
#-----------------------------------------------------------------------#

# LOCAL VARIABLES
# Input files
args1="/castor/project/proj/maria.d/8_EXPRESSION.D/output.d/01_out/06.1_htseq/"

# Number of lines (cells) to run in the for loop
## adjust SLURM --time (it takes roughly 10 minutes for the 480 cells)
args111=5000
#-----------------------------------------------------------------------#

# Print arguments passed
var_=$( echo "$(compgen -v | grep -i args -)" )
read -d " " -a  var_array <<< "$var_"
echo "VARIABLES EXPORTED:"
for i in ${var_array[@]}
do
eval temp='$'$i
echo "$i: $temp"
done
unset var_ var_array i temp
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
fi

# Temp file with paths
args11=($(ls ${args1} | grep -v "paths.tmp") )
for i in "${args11[@]}"
do
	CELL=($(ls ${args1}${i} | grep -v "NOTPASS"))
	for j in "${CELL[@]}"
	do
		echo "${args1}${i}/${j}/${j}_R1_htseq.counts" >> ${outdir}${lognm}/paths.tmp
	done
	echo "printing paths for ${args1}${i}"
done

# Number of jobs (arrays)
args1111=$(cat ${outdir}${lognm}/paths.tmp | wc -l)
args1111=$(((${args1111} / ${args111}) + 1))

# Execute
args1="${outdir}${lognm}/paths.tmp"

sbatch --account=sens2018122 --array=1-${args1111} --time=03:00:00 --job-name=${lognm} --output=${lognm}_%A_%a.stdout --export=NUMLINES=${args111},codedir=${codedir},logdir=${logdir}${lognm},outdir=${outdir}${lognm},lognm=${lognm},args1=${args1} ${codedir}09.0_merge_count_matrices.run
unset args1 args111 args1111 
#-----------------------------------------------------------------------#
