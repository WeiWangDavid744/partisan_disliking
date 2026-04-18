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


## Ying