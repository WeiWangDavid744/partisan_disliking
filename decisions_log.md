# Decisions log

The purpose of this file is to log and track our updates so we keep a record of potential issues and resolutions.

**When to record:** If you think that a certain decision you made (why you averaged two codes in constructing a variable; why you specified certain arguments in your `glm()` function; etc.) may be questioned by a future reviewer or reader, who may ask you for your rationale for doing so, it's probably a good idea to log it now so you don't forget in the future.

**What to record:** Please include the date of decision as a subheading (###), and describe and explain each decision.

**Please edit only under your own section, in order to facilitate Github syncing.**

## David

### 04-17-2026

#### Data and data cleaning process explanation

- Open-ended data comes from https://electionstudies.org/data-center/. 
  - The merged data frame is stored as merged_open-ended_08-24.csv.
  
- Numeric data comes from anes_timeseries_cdf_csv_20260205.csv, found here: https://electionstudies.org/data-center/anes-time-series-cumulative-data-file/.
  - The year-specific data frames were only saved and used to check whether the open-ended and year-specific numeric data files' case IDs matched (they did).
  - Some characteristics of this data:
    - All participants were from the fresh cross-sectional samples. Starting in 2020, prior respondents were reinterviewed -- these constitute the panel sample. However, they are not included in the cumulative data file.
    - Only variables measured more than three times across different ANES surveys are included.
    - Many variables we might find interesting from the cdf codebook are not included because they were not measured for at least one of the years between 2008 and 2024.

- I chose data starting in 2008 because this is the earliest year from which we have open-access open-ended data about party likes and dislikes (PLD). For example, 2004's is redacted.

#### Analysis rationale

- We must add issue fixed effects and cluster standard errors based on the very probable assumption that time affects party feeling thermometer ratings. As polarization has increased over the past 20 years, it's quite likely this is the case. If we do not include it, we fail to model for the dependency between observations from the same year.


## Rehan

### 04-25-2026

#### Thermometer outcome coding

Recoded `dem_therm` and `rep_therm` (continuous, 0–97) into 5-class ordered 
categorical outcomes for multinomial LASSO text mining models:

- 1 = Highly unfavorable (0–19)
- 2 = Unfavorable (20–39)
- 3 = Neutral (40–59)
- 4 = Favorable (60–79)
- 5 = Highly favorable (80–97)

Negative values (-8) recoded to NA as residual non-response codes (check for data cleaning and EDA)

#### Text predictors and DTMs

**Text predictors**: Open-ended responss (dem_like + dem_dislike; rep_like + rep_dislike) coded into a single column (dem_text; rep_text).These will predict the thermometer class outcomes.

**Non-response handling**: ~40% of respondents did not provide open-ended responses, and are therefore retained from text mining, but can be retained for the full dataset for RQ2, and potential extension with Heckman. Binary flags (has_dem_text; has_rep_text) created for RQ2.

**Text representations and DTMS:** Three representations build for each party (stem, N-gram, Skip-gram), with six DTMs total. All DTMs were filtered to retain temrs appearing in at least 1% of documents. Sparsity consistent at 97-98% across all six DTMs, which is what we would expect. 

Next step is LASSO modeling (2 outcome measures x 3 text methods). I'll force in year as a fixed effect and cluster standard errors as requested. 

#### Analysis rationale
ANES feeling thermometers cluster at round numbers, which makes a continuous outcome inappropriate. Moreover, we have done text-mining for classification tasks and it makes sense to apply it in that way here. Give bands provide enough detail to distinguish animosity from favorability while keeping classes well populated. 

Makes sense to use a multi-class measure since we can see how different terms may be associated with animosity / favorability, before manually coding them. 

## Ying