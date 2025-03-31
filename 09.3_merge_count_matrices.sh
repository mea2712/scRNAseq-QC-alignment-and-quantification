#!/bin/bash

#SBATCH -A sens2018122
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 00:00:00
#SBATCH --mail-user=maria.arceo@ki.se
#SBATCH --mail-type=ALL
#SBATCH -J xxxxx_                   #### REMEMBER TO KEEP UPDATED ####
#SBATCH --output=xxxxx_%J.stdout    #### REMEMBER TO KEEP UPDATED ####
#---------------------------------------------------------------------#
<<'_//COMMENT//_'
This script will execute .../code.d/09.1_merge_count_matrices.R 
to get a final merged counts matrix
_//COMMENT//_
#---------------------------------------------------------------------#

dstart=$(date +"%Y/%m/%d %H:%M:%S")
SECONDS=0
#---------------------------------------------------------------------#

# Load software modules
module load R/4.0.4
module load R_packages/4.0.4
#---------------------------------------------------------------------#

# slurm arguments
if [ ! -z "$SLURM_JOB_ID" ] && [ ! "$SLURM_JOB_NAME" = "_interactive" ]
then
	echo "JOB_ID=${SLURM_JOB_ID}"
	echo "JOB_NAME=${SLURM_JOB_NAME}"
fi
#-----------------------------------------------------------------------#

# Code and logs directories
codedir="/castor/project/proj/maria.d/8_EXPRESSION.D/scripts.d/01_sandbox/"
logdir=$(echo "${codedir}log.d/")
outdir="/castor/project/proj/maria.d/8_EXPRESSION.D/output.d/01_out/"
lognm="09.3_merge_count_matrices"
#-----------------------------------------------------------------------#

# LOCAL VARIABLES
# Input files
# .. get paths for all partial counts matrices produced by 09.*_merge_count_matrices.[sh,run,R]
args0="09.2_merge_count_matrices"
args1="/castor/project/proj/maria.d/8_EXPRESSION.D/output.d/01_out/${args0}/"

# Where to have a sym link of the final matrix
args2="/castor/project/proj/maria.d/8_EXPRESSION.D/data.d/01_data/"

# Analysis done - remove temp data -
# -- data was compressed in previous run, tfr, no need --
# -- uncomment if needed, including lines 116-117 below --
# -- check 09.1_merge_counts_matrices.sh --
#args33="01_tmp"
#args3="/castor/project/proj/maria.d/8_EXPRESSION.D/data.d/${args33}/"
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
fi

# Copy to temp files
args11=($(ls ${args1}*/*.csv) )
idx=$(( ${#args11[@]} - 1 ))

for i in $(seq 0 ${idx})
do
	cp -p ${args11[${i}]} ${outdir}${lognm}/tmp_${i}.csv
	echo "copying ${i}"
done

# Execute
args111="as.character('${outdir}${lognm}/')"
lognm1="as.character('${lognm}')"

if [ ! -z "$SLURM_JOB_ID" ] && [ ! "$SLURM_JOB_NAME" = "_interactive" ]
then
	Rscript --vanilla ${codedir}09.1_merge_count_matrices.R ${args111} ${lognm1} > ${logdir}${SLURM_JOB_NAME}_${SLURM_JOB_ID}.ROUT
else
	Rscript --vanilla ${codedir}09.1_merge_count_matrices.R ${args111} ${lognm1} > ${logdir}${lognm}.ROUT
fi

# Checkings and housekeeping
while [ ! -f ${outdir}${lognm}/${lognm}.csv ]
do
	echo "checking again in 30s"
	sleep 30s
done

rm ${outdir}${lognm}/tmp_*.csv

oldd=$PWD
cd ${args1}..
tar -cvzf INTERMEDIATE-${args0}.tar.gz ${args0}/ && rm -r ${args0}/
cd $oldd

#cd ${args3}..
#tar -cvzf DONE-READYTOREMOVE-${args33}.tar.gz ${args33}/ && rm -r ${args33}/

ln -s ${outdir}${lognm}/${lognm}.csv ${args2}

unset args1 args0 args11 args111 lognm1 args2 args3 args33
#-----------------------------------------------------------------------#

DURATION=$SECONDS
dend=$(date +"%Y/%m/%d %H:%M:%S")

echo "START TIME: ${dstart}"
echo "END TIME: ${dend}"
echo "RUNTIME: $(($DURATION / 3600))h $((($DURATION / 60) %60))m $(($DURATION % 60))s"
#------------------------------------------------------------------------#

# Collect standard output
if [ ! -z "$SLURM_JOB_ID" ] && [ ! "$SLURM_JOB_NAME" = "_interactive" ]
then
	mv ${SLURM_JOB_NAME}_${SLURM_JOB_ID}.stdout ${logdir}
	echo "LOG FILES ARE IN:"
	echo "${logdir}${SLURM_JOB_NAME}_${SLURM_JOB_ID}.stdout"
fi
#------------------------------------------------------------------------#

