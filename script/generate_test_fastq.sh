#!/bin/bash
# Subsample paired-end FASTQ with seqtk / 用 seqtk 抽樣 paired-end FASTQ
# Usage / 用法: bash subsample_pe.sh <in_dir> <out_dir> <n_reads|fraction> [seed] [R1_suffix] [R2_suffix]
#   e.g. bash subsample_pe.sh ~/fastq ~/test_fastq 1000000
#        bash subsample_pe.sh ~/fastq ~/test_fastq 0.05 42 _R1.fastq.gz _R2.fastq.gz
set -euo pipefail

IN=${1:?input dir}
OUT=${2:?output dir}
N=${3:?number of read pairs (e.g. 1000000) or fraction (e.g. 0.05)}
SEED=${4:-42}
R1SUF=${5:-_1.fastq.gz}
R2SUF=${6:-_2.fastq.gz}

mkdir -p "$OUT"

for R1 in "$IN"/*"$R1SUF"; do
  [ -e "$R1" ] || { echo "No files matching *$R1SUF in $IN"; exit 1; }
  S=$(basename "$R1" "$R1SUF")
  R2="$IN/${S}${R2SUF}"
  [ -f "$R2" ] || { echo "WARNING: $R2 missing, skip $S"; continue; }

  echo "[$(date +%T)] $S: sampling $N (seed $SEED)"
  # same seed for R1 and R2 keeps pairs in sync / R1 同 R2 用同一個 seed，pair 先對得上
  # -2 = two-pass mode, uses much less RAM / 兩遍模式，慳好多 RAM
  echo "$R1"

  seqtk sample -s "$SEED" "$R1" "$N" | gzip > "$OUT/${S}${R1SUF}" 
  echo "$R2"
  seqtk sample -s "$SEED" "$R2" "$N" | gzip > "$OUT/${S}${R2SUF}" 
  
  echo "Done sampling"

  # check: equal counts and matching read names / 檢查：數量一樣、read name 對得上
  n1=$(( $(zcat "$OUT/${S}${R1SUF}" | wc -l) / 4 ))
  n2=$(( $(zcat "$OUT/${S}${R2SUF}" | wc -l) / 4 ))
  id1=$(zcat "$OUT/${S}${R1SUF}" | head -1 | cut -d' ' -f1 | sed 's#/1$##') || true
  id2=$(zcat "$OUT/${S}${R2SUF}" | head -1 | cut -d' ' -f1 | sed 's#/2$##') || true
  echo abc
  if [ "$n1" -eq "$n2" ] && [ "$id1" == "$id2" ]; then
    echo "  OK: $n1 pairs"
  else
    echo "  ERROR: R1=$n1 R2=$n2, first IDs $id1 vs $id2"
  fi
done
echo "Done. Output in $OUT"