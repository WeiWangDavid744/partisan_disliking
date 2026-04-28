# Main research questions and notes for analysis

0. EDA
- PID distributions of the sample, 08-24
- Line chart of Democratic and Republican feeling thermometer ratings, 08-24 (`dem_therm` and `rep_therm`)
  + Three lines * two panels: Full sample, Dem respondents, Rep respondents
  + Run the same analysis for with `dem_liking_cses` and `rep_liking_cses` as robustness
- Clustered bar charts of binary like/dislike measures over time.

1. What stems, n-grams, and skip-grams predict feeling thermometer ratings `dem_therm` and `rep_therm`?
- Use text-mining methods, including the n-grams and skip-grams methods we skipped in class/hw. (three models in total)
- When you run the analysis, please match the dem open-ended columns with `dem_therm`, and rep oe columns with `rep-therm`.
- NOTE: When running the LASSO model, please force a survey year fixed effect using `year`, since situations may be different year-to-year. 
- NOTE2: Please also cluster the standard errors using `sandwich::vcovCV()`.
- **STEP 2 (robustness):** rerun above analyses with `dem_liking_cses` and `rep_liking_cses` to see if how the DV is measured changes our result.

2. What predicts having any likes/dislikes for either party? (i.e., Who are we including/excluding in our open-ended sample?)
- Use LASSO to predict `dem_like_binary`, `dem_dislike_binary`, `rep_like_binary`, `rep_dislike_binary`.
- CAUTION: some variables may be perfectly collinear.
- NOTE: When running the LASSO model, please force a survey year fixed effect using `year`, since situations may be different year-to-year.
- NOTE2: Please also cluster the standard errors using `sandwich::vcovCV()`.

3. Apply weights for analyses (David)


------------- FUTURE IDEAS --------------
1.2 Manually code the yielded stems, n-grams, and skip-grams, using the codebook in Fowler et al., p. 18.
  - calculate intercoder reliability
  
4. Apply the Heckman selection model for the LASSO models from text mining. (David)
- Compare the selection model against the model derived from Analysis 2.

5. How do our LASSO models match up against ANES staff coding of the open-ended questions?
  - Data: 2008 (and other years' data if they have a coding report, codebook, and coded data available)
  - Using the outputted text from the LASSO model in Analysis 1, manually code the stems/words/n-grams/skip-grams using the coding report's codebook, then use some way to classify each respondent based on the document-term matrix.
  - Next step: read `2008_party_likes_and_dislikes_coding_report.docx` to understand what's going on and where the coded data is.

