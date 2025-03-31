#!/bin/bash -l

#SBATCH -A sens2018122
#SBATCH -p core
#SBATCH -n 1 
#SBATCH -t 48:00:00
#SBATCH --mail-user=maria.arceo@ki.se
#SBATCH --mail-type=ALL
#SBATCH -J 05.0_rsem_checkings
#SBATCH --output=05.0_rsem_checkings_%J.stdout 


# Code and logs directories
codedir="/castor/project/proj/maria.d/8_EXPRESSION.D/scripts.d/01_sandbox/"
logdir=$(echo "${codedir}log.d/")
#outdir="/castor/project/proj/maria.d/8_EXPRESSION.D/output.d/01_out/"
lognm="05.0_checkings"
#-----------------------------------------------------------------------#

# LOCAL VARIABLES
# Directory where HQ cells are stored
args1="/castor/project/proj/maria.d/8_EXPRESSION.D/output.d/01_out/03.0_QC_TrimGalore/CELLS-PASS"

# base path in $args1 to input files
inpth="/castor/project/proj/maria.d/8_EXPRESSION.D/output.d/01_out/02.2_trim_galore/"
# base path for output
outpth="/castor/project/proj/maria.d/8_EXPRESSION.D/output.d/01_out/05.0_rsem/"
# output directories to be checked -- changed sed delimiter because the variables have backlash
outck=($(sed -e  "s@${inpth}@${outpth}@" "${args1}")) # will remove .fq pointer inside the loop to not spend so much time in multiple sed calls


# File holding pointer to cells that failed
run=${outpth%/*}
run=$( echo "${run##*/}" )
<<'_SKIP_'
if [ -f ${outpth}/${run}_failed-cells ] 
then 
	echo "${outpth}${run}_failed-cells exists"
	exit
else
	touch ${outpth}${run}_failed-cells
fi
_SKIP_
# Run
for pth in "${outck[@]}"
do
	outdir=$( echo "${pth%/*}/" )

	CELL=$( echo ${outdir%/*}  )
	CELL=$( echo "${CELL##*/}" )

	SAMPLE=$(echo ${outdir%/*})
	SAMPLE=$(echo ${SAMPLE%/*})
	SAMPLE=$( echo ${SAMPLE##*/} )
								
	if [ -d "${outdir}${SAMPLE}-${CELL}.temp" ]
	then
		rm -rvf ${outdir}${SAMPLE}-${CELL}.temp
		
	fi
		
	if [ ! -f "${outdir}${SAMPLE}-${CELL}.time" ]
	then
		echo "${outdir}" >> ${logdir}${run}/${lognm}_failed-cells
		echo "${outdir}" | sed -e "s@${outpth}@${inpth}@" | sed -e "s/$/${CELL}_R1_trimmed.fq/"  >> ${outpth}${run}_failed-cells
		rm -rvf ${outdir}
	fi
done

