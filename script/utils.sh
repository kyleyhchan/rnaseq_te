#!/usr/bin/env bash
# Shared helpers, sourced by every step script.

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

die() { echo "ERROR: $*" >&2; exit 1; }

# Stop early if a required tool is missing
require() {
  for tool in "$@"; do
    command -v "$tool" >/dev/null 2>&1 || die "'$tool' not found. Did you 'conda activate te-rnaseq'?"
  done
}

# Print "sample<TAB>srr" for each row of samples.tsv (skips header, blanks, # comments)
list_samples() {
  [[ -f "$SAMPLES" ]] || die "Sample sheet not found: $SAMPLES"
  tail -n +2 "$SAMPLES" | grep -v -e '^\s*$' -e '^#' | cut -f1,2
}

# Paths to a sample's FASTQ files in a given folder
fq_r1() { [[ "$LAYOUT" == "PE" ]] && echo "$1/$2_1.fastq.gz" || echo "$1/$2.fastq.gz"; }
fq_r2() { echo "$1/$2_2.fastq.gz"; }
fq_trim_r1() { [[ "$LAYOUT" == "PE" ]] && echo "$1/$2_1_trimmed.fastq.gz" || echo "$1/$2_trimmed.fastq.gz"; }
fq_trim_r2() { echo "$1/$2_2_trimmed.fastq.gz"; }
