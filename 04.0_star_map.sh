#!/bin/bash

# Code and logs directories
codedir="/castor/project/proj/maria.d/8_EXPRESSION.D/scripts.d/01_sandbox/"
logdir=$(echo "${codedir}log.d/")
outdir="/castor/project/proj/maria.d/8_EXPRESSION.D/output.d/01_out/"
lognm="04.0_star_map"
#-----------------------------------------------------------------------#

# LOCAL VARIABLES
# Directory where HQ cells are stored
args1="/castor/project/proj/maria.d/8_EXPRESSION.D/output.d/01_out/03.0_QC_TrimGalore/CELLS-PASS"

# Number of lines (cells) to run i the for loop
## adjust SLURM --time
args2=20

# Directory where the genome index is
args3="/castor/project/proj/maria.d/8_EXPRESSION.D/output.d/99_out/011.0_star_genome_index/"
#-----------------------------------------------------------------------#

# Run
## Create output directory
if [ -e ${outdir}${lognm} ] 
then 
	echo "${outdir}${lognm}/ exists"
	exit
else
	mkdir ${outdir}${lognm}
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

# Temp is already written

# Number of jobs (arrays)
args22=$(cat ${args1} | wc -l)
args22=$(((${args22} / ${args2}) + 1))

# Execute

sbatch --account=sens2018122 --array=1-${args22} --time=24:00:00 --job-name=${lognm} --output=${lognm}_%A_%a.stdout --export=NUMLINES=${args2},codedir=${codedir},logdir=${logdir}${lognm},outdir=${outdir}${lognm},lognm=${lognm},args3=${args3},args1=${args1} ${codedir}04.0_star_map.run

unset args1 args2 args22 args3
#-----------------------------------------------------------------------#

# Track run time
dend=$(date +"%Y/%m/%d %H:%M:%S")
echo "JOB ENDED: ${dend}"
unset dend

