# scRNAseq-QC-alignment-and-quantification
Performs QC on single-cell_RNA_seq data, alignment and quantification

I was tasked with writing this pipeline some time ago. The scripts take advantage of the SLURM scheduler and its --array parallelization, and therefore, the pipeline needs to be run in a HPC.
If you're looking for a pipeline to process your RNA FASTQ files to TPM/counts, stop. This is not the way. I highly recommend going with widely-used and community-curated pipelines as they ensure reprodubicibility, debugging and stability. My pipeline of choice is https://nf-co.re/rnaseq/3.14.0/

Here I:
1) Hard-clipp the reads to remove adapters using TrimGalore
2) Assess QC of reads using QC
3) Filter out reads failing 3 or more tests in 2)
4) Align high quality reads to genome using STAR
5) Calculate expression:
   counts: with HTSEQ
   TPM: with RSEM

I start with FASTQ files and end with an expression matrix


