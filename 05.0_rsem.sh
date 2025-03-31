#!/bin/bash -l

# Code and logs directories
codedir="/castor/project/proj/maria.d/8_EXPRESSION.D/scripts.d/01_sandbox/"
logdir=$(echo "${codedir}log.d/")
outdir="/castor/project/proj/maria.d/8_EXPRESSION.D/output.d/01_out/" #"/castor/project/proj_nobackup/wharf/mararc/mararc-sens2018122/EMERGENCY_STORAGE.D/maria.d/8_EXPRESSION.D/output.d/01_out/"
lognm="05.0_rsem"
#-----------------------------------------------------------------------#

# LOCAL VARIABLES
# Directory where HQ cells are stored
args1="/castor/project/proj/maria.d/8_EXPRESSION.D/output.d/01_out/03.0_QC_TrimGalore/CELLS-PASS"

# Number of lines (cells) to run in the for loop
## adjust SLURM --time
args2=20

:<<"_SKIP_"
# files to build reference: genome annotation + sequences, and where to store output
args11="/castor/project/proj/maria.d/8_EXPRESSION.D/output.d/99_out/00.1_chrom_seq_removed_99.3_makeGTF-hg38.gencode.v37-99.1_makeGTF-ERCC92.gtf"
args12="/castor/project/proj/maria.d/8_EXPRESSION.D/output.d/99_out/00.0_chrom_seq_removed_GRCh38.primary_assembly.genome-nochrY_ERCC92.fa"
#-----------------------------------------------------------------------#

# Run
## Create output directory
if [ -e ${outdir}${lognm} ] 
then 
	echo "${outdir}${lognm}/ exists"
	exit
else
	mkdir ${outdir}${lognm}
	#touch ${outdir}${lognm}/${lognm}_rerun_CELLS-NOTPASS
fi

## Create log directory
if [ -e ${logdir}${lognm} ] 
then 
	echo "${logdir}${lognm}/ exists"
	exit
else
	mkdir ${logdir}${lognm}
	#touch ${logdir}${lognm}/CELLS-NOTPASS
fi

# Temp is already written -- WTH was temp :-/ ??? 

# Create reference having RSEM call STAR -- make sure to have enough resources, otherwise, submit a job to the scheduler
# Note: I used --sjdboverhang 40 when created independent star_index. According to RSEM the default of 100 works as well as the ideal value, therefore, I'll go with the default now
# --transcript-to-gene-map idx_file: gene_id\ttranscript_id // alternatively if --gtf (gene_id transcript_id in getf file)
module load bioinfo-tools 
module load star/2.7.11a
module load samtools/1.19
module load rsem/1.3.3

mkdir ${outdir}${lognm}/ref
outref=${outdir}${lognm}/ref/human_GENCODE_GRCh38

rsem-prepare-reference --star --gtf ${args11} --num-threads 4 ${args12} ${outref} &> ${logdir}${lognm}/ref.out

# Hard fix - no need if args1 file were not corrupted (stale file handle)
cp -p ${args1} ${outdir}${lognm}
patt=$( echo "${args1##*/}"  )
args1=$(  echo "${outdir}${lognm}/${patt}"  )
_SKIP_

# Number of jobs (arrays)
args22=$(cat ${args1} | wc -l)
args22=$(((${args22} / ${args2}) + 1))

# Execute
sbatch --account=sens2018122 --array=1-${args22}%40 --time=100:00:00 --job-name=${lognm} --output=${lognm}_%A_%a.stdout --export=NUMLINES=${args2},codedir=${codedir},logdir=${logdir}${lognm},outdir=${outdir}${lognm},lognm=${lognm},args1=${args1} ${codedir}05.0_rsem.run

unset args1 args2 args22
#-----------------------------------------------------------------------#
# Checks
#sbatch ${codedir}05.0_rsem_checkings.sbatch
#mv 05.0_rsem_checkings_*.stdout ${logdir}${lognm}

#-----------------------------------------------------------------------#

# Track run time
dend=$(date +"%Y/%m/%d %H:%M:%S")
echo "JOB ENDED: ${dend}"
unset dend

