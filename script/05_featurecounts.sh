#!/usr/bin/env bash

source ~/rnaseq_te/script/utils.sh
source ~/rnaseq_te/config/config.sh

mkdir -p "$FC_DIR" 


require featureCounts

while IFS=$'\t' read -r sample _ <&3; do

    bam="$PROCESSED_BAM_RNASEQ_DIR/${sample}.Aligned.out.filtered.bam"
    out="$FC_DIR/${sample}.gene_count.txt"
    if [[ -s "$out" ]];then
        log "skip $sample (counted)"
        continue
    fi
    
    log "featureCounts $sample start"

    
    featureCounts -T "$THREADS" -p --countReadPairs -B -C -s 2 \
    -a "$GENE_GTF" -o "$FC_DIR/${sample}.gene_count.txt" $bam 

done 3< <(list_samples)