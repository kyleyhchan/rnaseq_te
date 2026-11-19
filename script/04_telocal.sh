#!/usr/bin/env bash

source ~/rnaseq_te/script/utils.sh
source ~/rnaseq_te/config/config.sh

mkdir -p "$TE_LOC_DIR" 


require TElocal

while IFS=$'\t' read -r sample _ <&3; do

    bam="$PROCESSED_BAM_DIR/${sample}.Aligned.out.dedup.sorted.bam"
    out="$TE_LOC_DIR/${sample}.telocal.log"
    if [[ -s "$out" ]];then
        log "skip $sample (counted)"
        continue
    fi
    
    log "TElocal $sample start"

    

   ( cd "$TE_LOC_DIR" && TElocal -b "$bam" \
            --GTF "$GENE_GTF" \
            --TE "$TE_LOC_INDEX" \
            --stranded reverse \
            --sortByPos \
            --mode multi \
            --project "$sample") < /dev/null > "$TE_LOC_DIR/${sample}.telocal.log"



done 3< <(list_samples)