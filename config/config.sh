#!/usr/bin/env bash
# =============================================================
# Project configuration — edit this file, not the scripts.
# 所有設定改呢度，唔好改 scripts。
# =============================================================

# ---- Samples ----
SAMPLES="/home/chankyle/rnaseq_te/config/samples.tsv"

# ---- Data source: "sra" (download from NCBI) or "gcs" (copy from your bucket)
DATA_SOURCE="gcs"
GCS_RAW="/home/chankyle/rnaseq_te/raw_fastq/"      # used when DATA_SOURCE=gcs
                                     # expects files named <sample>_1.fastq.gz / <sample>_2.fastq.gz
                                     # (or <sample>.fastq.gz for single-end)

# ---- Library layout ----
LAYOUT="PE"        # "PE" = paired-end, "SE" = single-end
STRANDED="no"      # TEcount: "no", "forward", or "reverse"
                   # check with RSeQC infer_experiment.py if unsure

# ---- Reference files (download these yourself; see README) ----
GENOME_FA="$HOME/ref/GRCH38/fasta/GRCh38.primary_assembly.genome.fa"
GENE_GTF="$HOME/ref/GRCH38/gencode/gencode.v44.primary_assembly.annotation.gtf"
TE_GTF="$HOME/ref/GRCH38/te_gtf/GRCh38_GENCODE_rmsk_TE.gtf"     # TE GTF from the TEtranscripts authors
STAR_INDEX="$HOME/ref/GRCH38/star_index"
TE_LOC_INDEX="$HOME/ref/GRCH38/te_local_index/GRCm38_GENCODE_rmsk_TE.gtf.locInd"
READ_LENGTH=101                              # used for --sjdbOverhang (= read length - 1)

# ---- Output folders ----
RAW_DIR="/home/chankyle/rnaseq_te/raw_fastq"
TRIM_DIR="/home/chankyle/rnaseq_te/data/trimmed"
QC_DIR="/home/chankyle/rnaseq_te/results/qc"
BAM_DIR="/home/chankyle/rnaseq_te/results/bam"
PROCESSED_BAM_DIR="/home/chankyle/rnaseq_te/results/bam_processed"
TE_LOC_DIR="/home/chankyle/rnaseq_te/results/te_local_counts"
TE_DIR="/home/chankyle/rnaseq_te/results/te_counts"
FC_DIR="/home/chankyle/rnaseq_te/results/featurecounts"

# ---- Compute ----
THREADS=8
