#!/usr/bin/env bash
set -euo pipefail

./scripts/01_profile_validate.sh > logs/01_profile_validate.log
./scripts/02_build_intermediates.sh
Rscript R/01_analysis.R
echo "Pipeline complete. See reports/ and logs/."
