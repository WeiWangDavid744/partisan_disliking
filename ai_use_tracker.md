# AI Use Log

This document logs Group 15's use of AI throughout the project.

In case of Claude Code usage, please remember to use `/export` to save the log.

**What to record:** Please include the following: service used, task name, task description, example of task (optional). Additionally, when you write code that is largely helped by AI, please put an easily searchable flag as a comment above the relevant code chunk (see Line 85 of `cleaning.R`).

**Please edit only under your own section, in order to facilitate Github syncing.**

## David

- Claude Chat
  - **debugging**: I fed my R code and error messages to Claude when I could not figure out the reason myself.
    - ex. data <- left_join(cdf_cln, oe_full, by = c(year, caseid)) Error: object 'caseid' not found
    - Claude told me that I need to add quotation marks around the column names in `by=`.
  - **cleaning code**: 
    - Lines 86-94 of `cleaning.R` were Claude-assisted. The function was to detect any cell value starting with '-x', i.e., a negative numeric value, since those are likely code for NA. I was not fluent with this type of detection code, thus I sought AI help.
    - Lines 170-207 of `cleaning.R` were Claude-generated. I fed Claude the `codebook.csv` file generated below and asked it to write the recoding script for me. As there are 37 variables in total, manually writing these lines would have been unproductive.
  - **figure making**:
    - For the EDA plots, I used Claude Chat for: 
      - coming up with functions to simplify codes; 
      - suggesting colro schemes;
      - debugging

- Claude Code
  - **codebook integration**: `codebook.csv` was constructed by Claude Code. The purpose of the document was to ensure the team was on the same page about what variable stands for what. To copy the code descriptions from the corresponding codebooks and, particularly, to find the codes that should be recoded as NA for all 37 of our quantitative variables would have been extremely tedious.
    - _Note:_ Variable naming as done in `cleaning.R` was completely manual.

## Rehan

- Claude chat
  - Used Claude chat interface as a co-working tool to design and implement the text mining analysis pipeline (RQ1). I made all substantive analytical decisions and provided source code, using Claude to refine and adapt for new data.
  - **Debugging**: Fed error messages to Claude, particular for package alignment issues and one data alignment issue (a row mismatch in the DTM for the partisan stratification model)
  - **Code structure**: Claude suggested the loop-based approach for running multiple models efficiently. 

## Ying