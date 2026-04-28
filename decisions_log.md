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

### 04-27-2026

#### 2016 open-ended data unavailable

All respondents from 2017 have non-responses on the free text response for dem_like, rep_like, dem_dislike, and rep_dislike, suggesting that the ANES did not release open-ended data for tihs year. These respondensts are excluded from text mining models, and fixed year effects do not cover this year. 

#### Text predictors and DTMs

**Text predictors**: Open-ended responss (dem_like + dem_dislike; rep_like + rep_dislike) coded into a single column (dem_text; rep_text).These will predict the thermometer class outcomes.

**Non-response handling**: ~40% of respondents did not provide open-ended responses, and are therefore retained from text mining, but can be retained for the full dataset for RQ2, and potential extension with Heckman. Binary flags (has_dem_text; has_rep_text) created for RQ2.

**Text representations and DTMS:** Three representations build for each party (stem, N-gram, Skip-gram), with six DTMs total. All DTMs were filtered to retain temrs appearing in at least 1% of documents. Sparsity consistent at 97-98% across all six DTMs, which is what we would expect. 

Next step is LASSO modeling (2 outcome measures x 3 text methods). I'll force in year as a fixed effect and cluster standard errors as requested. 

#### Completed text mining analysis (up to step 2 in RQ)

- Ran six LASSO models for stems / n-grams / skip-grams for two outcomes (dem_therm_cat, rep_therm_cat). Year fixed effects forced in across all models. 2016 excluded as open-ended data unavailable in the ANES data.

- Produced relaxed LASSO / logistic regression on LASSO-selected terms. Was unable to implement clustered SEs via sandwich: : vcovCL() because of an error (recorded in r workbook). Reported regular SEs instead. Year fixed effects included in all models. Note that this step took a long time (over 1 hour) to run, so we should be judicious in future analyses.

Carried out two robustness checks: 

(1) Partisan stratification anlaysis, limited samples to Republicans rating Democrats and Democrats rating Republicans respectively. This caused a class imbalance (i.e., most sample is in lower temperature ratings), so I switched "type.measure" to "deviance" from "class", as "class" selected zero text terms. Results were substantively consistent with the full sample.

(2) Alternative outcome -- CSES liking scale (0-10, recoded to 5 classes). Results consistent with feeling thermometer models. Republican favorability predictors introduce more policy-specific terms (e.g, "military", "pro-life") for this outcome measure.

Produced **manual coding list** of top 25 animosity terms for each party exported to "data/animosity_coding_list.csv" to manual coding under Fowler et al., codebook. Restricted coding to class 1 predictors only (i.e., 0-20 feeling thermometer).

**Scoping** - Each of the three text representations (stems, n-grams, skip-grams) produce substantively consistent results. For the presentation and write-up, we could lead with one of these three and present the others as supplementary material. Future analyses could consider binary or 3-class outcomes for partisan stratified models to address the class imbalance. 

#### Analysis rationale
ANES feeling thermometers cluster at round numbers, which makes a continuous outcome inappropriate. Moreover, we have done text-mining for classification tasks and it makes sense to apply it in that way here. Give bands provide enough detail to distinguish animosity from favorability while keeping classes well populated. 

Makes sense to use a multi-class measure since we can see how different terms may be associated with animosity / favorability, before manually coding them.

We should restrict manula coding to animosity (class 1, or 0-20 feeling thermometer) predictors, because the lead research question focuses on partisan animosity specifically. Coding all 171 terms across five classes would be very time-consuming for the team given finals commitments. Focusing on the top 25 predictors will be most theoretically relevant.

### 04-28-2026

#### Skip-gram DTM sparsity thresholds

After inclusion of the 2016 year data, we have to adjust the sparsity thresholds for the Relaxed LASSO model:

- **Regular LASSO** - keep at 1% threshold (terms appearing in ≥1% of documents). More terms improve variable selection, and LASSO is designed for high-dimensional problems, shrinking irrelevant terms to zero.

- **Relaxed GLM** - adjust to 1.5% threshold (terms appearing in ≥1.5% of documents). This is needed because the model hits a parameter limit (~1030 weights) if we try using the full 1% skip-gram DTM, after 2016 data was included. At 1.5% the term counts are 135 for the Democrat thermometer model and 123 for the Republican model, which is within the model limits. 

#### Analysis rationale
This is methodologically sound because LASSO results are the primary output - word lists, coefficients and visualizations all derive from the LASSO steps. The GLM step provides unpenalized coefficient estimates and SEs for the LASSO-selected subset only. 

## Ying


## Ying