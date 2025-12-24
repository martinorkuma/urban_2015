## Urban 2015 Extinction Risk Analysis (WSL + R Pipeline)

### Overview

This project implements a reproducible Linux (WSL) + R data analysis pipeline to explore extinction risk estimates from the [Urban (2015)](https://github.com/CSB-book/CSB/blob/master/data_wrangling/data/Urban2015_data.csv) dataset. The workflow emphasizes data validation, lightweight preprocessing, and statistical analysis without reliance on databases, making it portable and transparent.

The dataset contains study-level extinction estimates across taxa, regions, prediction years, and modeling assumptions.

### Tools & Technologies

-   WSL (Ubuntu) – execution environment

-   Bash – pipeline orchestration and automation

-   Python (standard library + pandas) – data profiling and preprocessing

-   R – statistical analysis and visualization

-   Git/GitHub – version control and reproducibility

### Repository Structure 

```{bash}
.
├── data/
│   ├── raw/              # Original dataset (TSV)
│   └── processed/        # Cleaned and grouped intermediate files
├── scripts/              # Bash pipeline scripts
├── R/                    # R analysis scripts
├── reports/              # Figures and analysis outputs
├── logs/                 # Pipeline logs
└── README.md

```

### How to Run (from repo root in WSL)

```{bash}
chmod +x scripts/*.sh # make scripts executable

./scripts/run_all.sh # Run full pipeline end-to-end
```

or run step-by-step.

```{bash}
./scripts/01_profile_validate.sh
./scripts/02_build_intermediates.sh
Rscript R/01_analysis.R
```

### Pipeline Steps

1.  Data profiling and validation (Bash + Python).

2.  Intermediate data construction (Bash + Python).

3.  Statistical analysis & visualization (R).

### Key Outputs

-   reports/overall_weighted.csv

-   reports/fig_weighted_by_region_taxa.png

-   reports/fig_threshold_sensitivity.png

-   reports/percent_check_top25.csv (data quality check)

### Reproducibility

All results can be regenerated on any Linux or WSL system with Bash, Python, and R installed by running the pipeline scripts provided in this repository.
