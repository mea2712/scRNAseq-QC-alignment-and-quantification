# scRNAseq-QC-alignment-and-quantification
Perform QC on single-cell_RNA_seq reads data, alignment and quantification

I was tasked with writing this pipeline some time ago. The scripts take advantage of the SLURM scheduler and its --array parallelization, and therefore, the pipeline needs to be run in a HPC.
If you're looking for a pipeline to process your RNA FASTQ files to TPM/counts, stop. This is not the way. I highly recommend going with widely-used and community-curated pipelines as it ensures reprodubicibility, debugging and stability. My pipeline of choice is https://nf-co.re/rnaseq/3.14.0/

