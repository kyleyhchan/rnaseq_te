#!/usr/bin/env bash

set -euo pipefail
cd "$(dirname "$0")/.."

START=${1:-1}
mkdir -p logs

steps=(02_1_star_align_rnaseq 03_1_bam_filter_rnaseq 05_featurecounts)

for i in "${!steps[@]}"; do
    n=$((i + 1))
    (( n< START )) && continue
    step=${steps[$i]}
    echo "========== Step $n: $step =========="
    bash "$HOME/rnaseq_te/script/${step}.sh" 2>&1 | tee "logs/${step}.log"
done