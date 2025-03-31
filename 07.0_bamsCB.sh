#!/bin/bash

# This is a script to add CB tag to bams spitted out by STAR
# to build jvarkit:
# git clone "https://github.com/lindenb/jvarkit.git"
# cd jvarkit
# ./gradlew jvarkit
#-----------------------------------------------------------------------#

# Code and logs directories
codedir="/castor/project/proj/maria.d/8_EXPRESSION.D/scripts.d/01_sandbox/"
logdir=$(echo "${codedir}log.d/")
outdir="/castor/project/proj/maria.d/8_EXPRESSION.D/output.d/01_out/"
lognm="07.0_bamsCB"
#-----------------------------------------------------------------------#

# bams base directory
basedir="../../output.d/01_out/05.0_rsem/"
# Get bam file paths
argsA=($(find ${basedir} -mindepth 3 -maxdepth 3 -type f -name "*.bam" -exec dirname "{}" \; |sort -u))

# Number of lines (cells) to run i the for loop
## adjust SLURM --time
args2=90

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
fi

printf "%s\n" "${argsA[@]}" > ${outdir}${lognm}STARbams.txt
args1="${outdir}${lognm}STARbams.txt"

# Number of jobs (arrays)
args22=$(cat ${args1} | wc -l)
args22=$(((${args22} / ${args2}) + 1))

# Execute
tooldir="/home/mararc/bin/jvarkit/dist/"
sbatch --account=sens2018122 --array=1-${args22}%177 --time=06:00:00 --job-name=${lognm} --output=${lognm}_%A_%a.stdout --export=NUMLINES=${args2},codedir=${tooldir},logdir=${logdir}${lognm},outdir=${outdir}${lognm},lognm=${lognm},args1=${args1} ${codedir}07.0_bamsCB.run

#inbam="/Users/maria.arceo/Downloads/appendCB-d/appendCB/40k_NSCLC_DTC_3p_HT_nextgem_Multiplex_count_unassigned_alignments.bam"
#samtools view -h ${inbam} | head -n 200 | samtools view -bS - > /Users/maria.arceo/Downloads/jvarkit-d/little.bam

#module load java/OpenJDK_17+35
#module load bioinfo-tools 
#module load samtools/1.20
#cd bin/ 
#git clone "https://github.com/lindenb/jvarkit.git"
#cd jvarkit
#./gradlew jvarkit # build

#java -jar dist/jvarkit.jar samjdk -e 'record.setAttribute("CB","SS2_XX_XX_CELL");return record;' little.bam  2> /dev/null
