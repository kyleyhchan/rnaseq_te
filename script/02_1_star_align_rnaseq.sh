#!/usr/bin/env bash
source ~/rnaseq_te/script/utils.sh
source ~/rnaseq_te/config/config.sh

require STAR samtools picard
mkdir -p "$BMA_RNASEQ_DIR"

if [[ ! -f "$STAR_INDEX/SA" ]]; then
# If SA donot exist -> Build index
 [[ -f "$GENOME_FA" ]] || die "Genome FASTA not found: $GENOME_FA"
 # Find fasta
  [[ -f "$GENE_GTF"  ]] || die "Gene GTF not found: $GENE_GTF"
# Find GTD file
  log "Building STAR index in $STAR_INDEX (this takes ~1 hour)"
  mkdir -p "$STAR_INDEX"
  STAR --runMode genomeGenerate \
       --runThreadN "$THREADS" \
       --genomeDir "$STAR_INDEX" \
       --genomeFastaFiles "$GENOME_FA" \
       --sjdbGTFfile "$GENE_GTF" \
       --sjdbOverhang $((READ_LENGTH - 1)) # This is depends on the read length from sequencer
fi

while IFS=$'\t' read -r sample _ <&3; do

    bam="$BMA_RNASEQ_DIR/${sample}.Aligned.out.bam"
    if [[ -s "$bam" ]]; then
        log "skip $sample (aligned)"
        continue
    fi

    r1=$(fq_trim_r1 "$TRIM_DIR" "$sample")

    [[ -s "$r1" ]] || die "Missing input $r1"
    reads=("$r1")

    [[ "$LAYOUT" == "PE" ]] && reads+=("$(fq_trim_r2 "$TRIM_DIR" "$sample")")

    log "aligning $sample"
    STAR --runThreadN "$THREADS" \
        --genomeDir "$STAR_INDEX" \
        --readFilesIn "${reads[@]}" \
        --readFilesCommand zcat \
        --outFilterMultimapNmax 20 \
        --outFilterMismatchNoverReadLmax 0.04 \
        --alignSJoverhangMin 8 --alignSJDBoverhangMin 1 \
        --alignIntronMin 20 --alignIntronMax 1000000 --alignMatesGapMax 1000000 \
        --outSAMattrRGline ID:${sample} SM:${sample} LB:${sample} PL:ILLUMINA \
        --outSAMtype BAM Unsorted \
        --quantMode GeneCounts \
        --outFileNamePrefix "$BMA_RNASEQ_DIR/$sample." < /dev/null
# TE specific
# --outFilterMultimapNmax = maximum map to 100 location
# --winAnchorMultimapNmax = allow match up to 200 loci
    
# Alignment Stringency
# --outFilterMismatchNmax = allow up to 5 mismatch
# --alignRndsType EndToEnd = No soft-clip allowed

#Splicing turned of 
# --alignIntroMax 1 = max intron size is 1
# --alignMatesGapMax 350 = two mates of a pair = at most 350 bp apart.
done 3< <(list_samples)
log "Alignment is done"