#!/bin/bash

# Code and logs directories
codedir="/castor/project/proj/maria.d/8_EXPRESSION.D/scripts.d/01_sandbox/"
logdir=$(echo "${codedir}log.d/")
outdir="/castor/project/proj/maria.d/8_EXPRESSION.D/output.d/01_out/"
lognm="04.1_star_map"
#-----------------------------------------------------------------------#

# LOCAL VARIABLES
# Input
## File where cells -that din't pass first run- to align are stored
args1="/castor/project/proj/maria.d/8_EXPRESSION.D/scripts.d/01_sandbox/log.d/04.0_star_map/CELLS-NOTPASS"
## Trim Galore directory to look for cells above
args1e="02.0_trim_galore"
## Files where cells that timed out are
args1a=("/castor/project/proj/maria.d/8_EXPRESSION.D/scripts.d/01_sandbox/log.d/04.0_star_map_13283_416.stdout" \
"/castor/project/proj/maria.d/8_EXPRESSION.D/scripts.d/01_sandbox/log.d/04.0_star_map_13283_415.stdout" \
"/castor/project/proj/maria.d/8_EXPRESSION.D/scripts.d/01_sandbox/log.d/04.0_star_map_13283_414.stdout" \
"/castor/project/proj/maria.d/8_EXPRESSION.D/scripts.d/01_sandbox/log.d/04.0_star_map_13283_159.stdout" \
"/castor/project/proj/maria.d/8_EXPRESSION.D/scripts.d/01_sandbox/log.d/04.0_star_map_13283_158.stdout" )
## File where to get cells that timed out - same as args1 in first run
args1b="/castor/project/proj/maria.d/8_EXPRESSION.D/output.d/01_out/03.0_QC_TrimGalore/CELLS-PASS"
## Directory for the previous run
args1d="/castor/project/proj/maria.d/8_EXPRESSION.D/output.d/01_out/04.0_star_map/"

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

# write temp
readarray -t args1f < ${args1}
for f in "${args1f[@]}"
do
	SAMPLE=$( echo ${f%/*}  )  # keep updated
	SAMPLE=$( echo ${SAMPLE##*/}  )

	CELL=$(echo ${f##*/})

	RUN=$( echo ${f%/*}  )
	RUN=$( echo ${RUN%/*}  )
	RUN=$( echo ${RUN##*/} )
	echo "${outdir}${args1e}/${SAMPLE}/${CELL}/${CELL}_R1_trimmed.fq" >> ${outdir}${lognm}/paths.tmp
done

for a in "${args1a[@]}"
do
	X=$(grep "LINE START=" ${a} | grep -Eo '[0-9]{1,9}' )
	Y=$(grep "LINE STOP=" ${a} | grep -Eo '[0-9]{1,9}' )
	tail -n "+${X}" ${args1b} | head -n $((Y-X+1)) >> ${outdir}${lognm}/paths.tmp
done
args1="${outdir}${lognm}/paths.tmp"

# Remove failed files from previous run
readarray -t args1c < ${outdir}${lognm}/paths.tmp

oldd=$PWD
for c in "${args1c[@]}"
do
	CELL=$( echo ${c%/*}  )  # keep updated
	CELL=$( echo ${CELL##*/}  )

	SAMPLE=$(echo ${c%/*})  # keep updated
	SAMPLE=$(echo ${SAMPLE%/*})
	SAMPLE=$( echo ${SAMPLE##*/}  )

	cd ${args1d}${SAMPLE}
	if [ -e ./${CELL} ]
	then
		tar -cvzf NOTPASS-${CELL}.tar.gz ${CELL}/ && rm -r ${CELL}/
	fi
	cd $oldd
done

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

