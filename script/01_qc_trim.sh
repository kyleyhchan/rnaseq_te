#!/usr/bin/env/bash
set -euo pipefail
source ~/rnaseq_te/script/utils.sh
source ~/rnaseq_te/config/config.sh

require fastqc trim_galore multiqc

mkdir -p "$TRIM_DIR" "$QC_DIR/fastqc_raw" "$QC_DIR/fastqc_trimmed"

while IFS=$'\t' read -r sample _ <&3; do
    in1=$(fq_r1 "$RAW_DIR" "$sample");  out1=$(fq_r1 "$TRIM_DIR" "$sample")
  [[ -s "$in1" ]] || die "Missing input $in1"

    if [[ -s "$TRIM_DIR/${sample}_1_trimmed.fastq.gz" ]]; then
        log "skip $sample (trimmed already)"
        continue
    fi

    log "QC + Trim $sample"
    if [[ "$LAYOUT" == "PE" ]]; then
        in2=$(fq_r2 "$RAW_DIR" "$sample");  out2=$(fq_r2 "$TRIM_DIR" "$sample")
        fastqc -t "$THREADS" --outdir "$QC_DIR/fastqc_raw" "$in1" "$in2" < /dev/null
        trim_galore --paired --length 40 -q 30 --cores "$THREADS" \
                    -o "$TRIM_DIR" "$in1" "$in2" < /dev/null
        mv "$TRIM_DIR/${sample}_1_val_1.fq.gz" "$TRIM_DIR/${sample}_1_trimmed.fastq.gz"
        mv "$TRIM_DIR/${sample}_2_val_2.fq.gz" "$TRIM_DIR/${sample}_2_trimmed.fastq.gz"
    else
        fastqc -t "$THREADS" --outdir "$QC_DIR/fastqc_raw" "$in1" "$in2" < /dev/null
        trim_galore --length 40 -q 30 --cores "$THREADS" \
                    -o "$TRIM_DIR" "$in1" </dev/null
        mv "$TRIM_DIR/${sample}_trimmed.fa.gz" "$TRIM_DIR/${sample}_trimmed.fastq.gz" 
    fi


done 3< <(list_samples)

log "Running MultiQC"
multiqc -f -o "$QC_DIR" "$QC_DIR"

log "QC and trim done"