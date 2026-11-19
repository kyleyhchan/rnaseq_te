#!/usr/bin/env bash

set -euo pipefail
cd "$(dirname "$0")/.."

START=${1:-1}
mkdir -p logs

steps=(01_qc_trim 02_star_align 03_bam_filter 04_telocal)

for i in "${!steps[@]}"; do
    n=$((i + 1))
    (( n< START )) && continue
    step=${steps[$i]}
    echo "========== Step $n: $step =========="
    bash "$HOME/rnaseq_te/script/${step}.sh" 2>&1 | tee "logs/${step}.log"
done