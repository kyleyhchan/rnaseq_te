#!/usr/bin/env bash
set -euo pipefail
source ~/rnaseq_te/script/utils.sh
source ~/rnaseq_te/config/config.sh

require samtools picard
mkdir -p $PROCESSED_BAM_RNASEQ_DIR

while IFS=$'\t' read -r sample _ <&3; do

    bam="$BMA_RNASEQ_DIR/${sample}.Aligned.out.bam"
    [[ -s "$bam" ]] || die "Missing $bam. Run alignment first"
    out_basename="$PROCESSED_BAM_RNASEQ_DIR/${sample}.Aligned.out"

    if [[ -s  "$out_basename.dedup.sorted.bam" ]]; then
        log "Skip $sample (already dedup)"
        continue
    fi


    log "Running $sample"
    # Filter: unique, properly paired, primary alignments only, then sort
    samtools view -@ "$THREADS" -u -q 255 -f 2 -F 0x904 "$bam" \
    | samtools sort -@ "$THREADS" -m 2G -T "$out_basename.tmp" \
    -o "$out_basename.filtered.bam"
    log "$sample - filter is done"
    # INDEX
    samtools index -@ "$THREADS" "$out_basename.filtered.bam"

    # QC
    samtools flagstat -@ "$THREADS" "$out_basename.filtered.bam" > "$out_basename.filtered.bam.flagstat"
    log "$sample - index and QC is done"

    






done 3< <(list_samples)

