# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Group 15 final project for STAT 5710 (data mining) at Penn. The project analyzes partisan disliking using ANES (American National Election Studies) data from 2008–2024, focusing on open-ended party like/dislike responses.

## Running the Code

This is an R project. Open `partisan_disliking.Rproj` in RStudio, or source scripts directly:

```r
# Source the cleaning script (run from project root)
source("cleaning.R")
```

Key packages required: `tidyverse`, `skimr`, `readxl`, `janitor`, `haven`

## Data Architecture

**Raw data** (`data/raw_anes/`):
- `openend_08.xls` through `openend_24.xlsx` — open-ended party like/dislike responses per election year (each year has a different structure/variable naming convention)
- `anes_timeseries_200X_*.dta` / `*.csv` — year-specific ANES time series files with structured variables
- `anes_timeseries_cdf_csv_20260205.csv` — ANES Cumulative Data File (CDF), the primary structured dataset spanning all years
- `all_codebooks/` — PDFs and reference docs for variable definitions per year

**Processed data** (`data/`):
- `merged_open-ended_08-24.csv` — harmonized open-ended responses across all years with standardized columns: `year`, `caseid`, `dem_like`, `dem_dislike`, `rep_like`, `rep_dislike`
- `anes_post08.csv` — CDF subset filtered to 2008+, with renamed/selected variables (see `cleaning.R:128–166`)

## Cleaning Script Logic (`cleaning.R`)

The script has two logical sections:

1. **Open-ended file merging** (lines 1–96): Reads each year's open-ended xlsx/xls, standardizes column names to `(caseid, dem_like, dem_dislike, rep_like, rep_dislike)`, handles year-specific NA encodings (e.g., `-1 Inapplicable`, `<DK>`), and writes `merged_open-ended_08-24.csv`.

2. **CDF processing and merge** (lines 98–171): Subsets the CDF to post-2008, selects and renames ~35 variables (thermometer ratings, PID7, ideology, demographics, etc.), then left-joins with the open-ended data on `(year, caseid)`.

**Important note**: The comment `# START HERE AND SKIP ABOVE FOR MERGING STEPS` at line 119 marks the point where you can begin if the processed CSVs already exist — the open-ended merging step is slow and only needs to run once.

**Known data quirks**:
- 2016: One respondent (ID 302252) was incorrectly logged and must be excluded (see ANES 2016 errata, March 5, 2019)
- 2024: One respondent appears in open-ended file but not in the main time series file; stored in `id_excl` for downstream exclusion
- NA encoding is inconsistent across years; `cleaning.R` detects strings matching `^-\d(\D|$)` pattern and recodes them as `NA`

## Variable Naming Conventions

CDF variables follow the `VCF####` format. Key mappings used in this project are defined in `cleaning.R:128–166`. The CDF codebook (`all_codebooks/anes_timeseries_cdf_codebook_Varlist.pdf`) documents all available variables; highlighted vars in that PDF are the ones selected for this project.
