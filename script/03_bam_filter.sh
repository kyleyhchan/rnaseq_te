#!/usr/bin/env bash
set -euo pipefail
source ~/rnaseq_te/script/utils.sh
source ~/rnaseq_te/config/config.sh

require samtools picard
mkdir -p $PROCESSED_BAM_DIR

while IFS=$'\t' read -r sample _ <&3; do

    bam="$BAM_DIR/${sample}.Aligned.out.bam"
    [[ -s "$bam" ]] || die "Missing $bam. Run alignment first"
    out_basename="$PROCESSED_BAM_DIR/${sample}.Aligned.out"

    if [[ -s  "$out_basename.dedup.sorted.bam" ]]; then
        log "Skip $sample (already dedup)"
        continue
    fi


    log "Running $sample"

    picard -Xmx8g MarkDuplicates I="$bam" \
            O="$out_basename.markdup.bam" \
            M="$out_basename.dup_metrics.txt" \
            READ_NAME_REGEX=null \
            ASSUME_SORT_ORDER=queryname \
            TMP_DIR="$BAM_DIR" < /dev/null



    log "------ MarkDuplicates is done"
    log "------ Running samtools"
    samtools view -@ "$THREADS" -b -F 1024 "$out_basename.markdup.bam" > "$out_basename.dedup.bam"
    rm $out_basename.markdup.bam
    samtools sort -@ "$THREADS" -m 1500M -T "$BAM_DIR/tmp" -o "$out_basename.dedup.sorted.bam" "$out_basename.dedup.bam"
    samtools index -@ "$THREADS" "$out_basename.dedup.sorted.bam"
    rm $out_basename.dedup.bam
    log "------ Dedup is done"
    






done 3< <(list_samples)