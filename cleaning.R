# This script trims the data to only those relevant for the project.

{
  library(tidyverse)
  library(skimr)
  library(readxl)
  library(janitor)
  library(haven)
}

#-----
# SKIP TO LINE 148
# open-ended response files
# vars included: year-specific case ID, D/R dis/like responses
#-----
# extract relevant variables from each open-ended file
oe_08 <- read_xls('data/raw_anes/openend_08.xls') %>%
  clean_names() %>%
  select(case_id, c1b_dem_party_like, c2b_rep_party_like, 
         c1d_dem_party_dislike, c2d_rep_party_dislike)

oe_12 <- read_xlsx('data/raw_anes/openend_12.xlsx') %>%
  clean_names() %>%
  select(caseid, ptylik_lwhatdp, ptylik_dwhatdp, ptylik_lwhatrp, ptylik_dwhatrp)

oe_16_dl <- read_xlsx('data/raw_anes/openend_16.xlsx', 
                           sheet = 'V161098') %>%
  clean_names()
oe_16_dd <- read_xlsx('data/raw_anes/openend_16.xlsx', 
                              sheet = 'V161101') %>%
  clean_names()
oe_16_rl <- read_xlsx('data/raw_anes/openend_16.xlsx', 
                              sheet = 'V161104') %>%
  clean_names()
oe_16_rd <- read_xlsx('data/raw_anes/openend_16.xlsx', 
                      sheet = 'V161106') %>%
  clean_names()
oe_16 <- reduce(list(oe_16_dl, oe_16_dd, oe_16_rl, oe_16_rd), merge, 
                by = 'hover_here_for_note_v160001')
# one respondent was incorrectly logged despite being a non-respondent
# see https://electionstudies.org/2016-time-series-updates-errata/, March 5, 2019
oe_16 <- oe_16 %>% filter(hover_here_for_note_v160001 != 302252)

oe_20_dl <- read_xlsx('data/raw_anes/openend_20.xlsx', 
                      sheet = 'V201159') %>%
  clean_names()
oe_20_dd <- read_xlsx('data/raw_anes/openend_20.xlsx', 
                      sheet = 'V201161') %>%
  clean_names()
oe_20_rl <- read_xlsx('data/raw_anes/openend_20.xlsx', 
                      sheet = 'V201163') %>%
  clean_names()
oe_20_rd <- read_xlsx('data/raw_anes/openend_20.xlsx', 
                      sheet = 'V201165') %>%
  clean_names()
oe_20 <- reduce(list(oe_20_dl, oe_20_dd, oe_20_rl, oe_20_rd), merge, 
                    by = 'v200001')

oe_24_dl <- read_xlsx('data/raw_anes/openend_24.xlsx', 
                      sheet = 'V241170') %>%
  clean_names()
oe_24_dd <- read_xlsx('data/raw_anes/openend_24.xlsx', 
                      sheet = 'V241172') %>%
  clean_names()
oe_24_rl <- read_xlsx('data/raw_anes/openend_24.xlsx', 
                      sheet = 'V241174') %>%
  clean_names()
oe_24_rd <- read_xlsx('data/raw_anes/openend_24.xlsx', 
                      sheet = 'V241176') %>%
  clean_names()
oe_24 <- reduce(list(oe_24_dl, oe_24_dd, oe_24_rl, oe_24_rd), merge, 
                by = 'v240001', all = T) # join all so no case is omitted

# merge
# omit first row for oe_08 since it's the col names
ls_years <- list('2008' = oe_08[-1,], '2012' = oe_12, '2016' = oe_16, '2020' = oe_20, '2024' = oe_24)
ls_cols <- c('caseid', 'dem_like', 'dem_dislike', 'rep_like', 'rep_dislike')

oe_full <- ls_years %>%
  map(~ set_names(.x, ls_cols) %>% mutate(caseid = as.character(caseid))) %>%
  bind_rows(.id = 'year')

# Some years hand-labeled NAs as, for example, '-1 Inapplicable', and the coding is inconsistent.
# The following code detects these and pairs with the actual text.
# [CLAUDE FLAG]
cols <- c('dem_like', 'dem_dislike', 'rep_like', 'rep_dislike')
unique_strings <- oe_full %>%
  select(all_of(cols)) %>%
  unlist(use.names = FALSE) %>%
  unique() %>%
  str_subset("^-\\d(\\D|$)")
oe_full_cln <- oe_full %>%
  mutate(across(all_of(cols),
                ~ if_else(.x %in% c(unique_strings, '<DK>'), NA_character_, .x)))

#----- 
# fix discrepancies between oe_full and each time series file's case ID
#-----
# year-specific data files
df_08 <- haven::read_dta('data/raw_anes/anes_timeseries_2008_v20150519.dta')
df_12 <- haven::read_dta('data/raw_anes/anes_timeseries_2012_v20160504.dta')
df_16 <- haven::read_dta('data/raw_anes/anes_timeseries_2016_v20190904.dta')
df_20 <- read_csv('data/raw_anes/anes_timeseries_2020_v20220210.csv')
df_24 <- read_csv('data/raw_anes/anes_timeseries_2024_v20250808.csv')

# check discrepancies for each year (anyone in oe_full_cln but not in df)
# 08, 12, 20, 24 caseids are all fine
id_excl_08 <- setdiff(oe_full_cln %>% filter(year == 2008) %>% pull(caseid), df_08$V080001)
id_excl_12 <- setdiff(oe_full_cln %>% filter(year == 2012) %>% pull(caseid), df_12$caseid)
# as noted in documentation, oe caseids for 2016 are different from caseids in df_16
id_excl_20 <- setdiff(oe_full_cln %>% filter(year == 2020) %>% pull(caseid), df_20$V200001)
id_excl_24 <- setdiff(oe_full_cln %>% filter(year == 2024) %>% pull(caseid), df_24$V240001)

# 2016 caseids in the open-ended data were later recoded in the CDF. 
# Here I substitute the old caseids for the new ones (recorded in df_16).
caseid16_map <- df_16 %>%
  select(
    caseid_new = V160001,
    caseid = V160001_orig
  ) %>%
  mutate(
    caseid_new = as.character(caseid_new),
    caseid = as.character(caseid)
  )

oe_full_cln16 <- oe_full_cln %>%
  left_join(caseid16_map, by = 'caseid') %>%
  mutate(caseid = if_else(year == 2016 & !is.na(caseid_new),
                          caseid_new,
                          caseid)) %>%
  select(-caseid_new)

# exclude respondent in oe_24 but not df_24
oe_full_cln_final <- oe_full_cln16 %>%
  filter(!(year == 2024 & caseid %in% id_excl_24))

write_csv(oe_full_cln_final, 'data/merged_open-ended_08-24.csv')

#-----
# subset cumulative time series data file to only post-08 for smaller file size
#-----
cdf_raw <- read_csv('data/raw_anes/anes_timeseries_cdf_csv_20260205.csv') %>%
  filter(VCF0004 >= 2008)
write_csv(cdf_raw, 'data/anes_post08.csv')

#-----
# START HERE AND SKIP ABOVE FOR MERGING STEPS
oe_full <- read_csv('data/merged_open-ended_08-24.csv')
cdf_raw <- read_csv('data/anes_post08.csv')

# cdf cleaning

cdf_cln <- cdf_raw %>%
  # select RQ-relevant variables to reduce file size
  # see highlighted vars in anes_timeseries_cdf_codebook_Varlist.pdf
  select(
    year = VCF0004,
    caseid = VCF0006,
    uniq_id = VCF0006a,
    weight = VCF0009z, # weight for combined sample; see cdf appx p5
    reg_census = VCF0112,
    dem_therm = VCF0218,
    rep_therm = VCF0224,
    pid7 = VCF0301,
    dem_like_binary = VCF0374,
    dem_dislike_binary = VCF0380,
    rep_like_binary = VCF0386,
    rep_dislike_binary = VCF0392,
    party_diff = VCF0501,
    party_more_consv = VCF0502,
    dem_ideo = VCF0503,
    rep_ideo = VCF0504,
    dem_liking_cses = VCF9201,
    rep_liking_cses = VCF9202,
    right_track = VCF9222,
    therm_lib = VCF0211,
    therm_consv = VCF0212,
    ideology = VCF0803,
    understand_issue = VCF9251,
    too_complicated = VCF9252,
    power_matters = VCF9253,
    dem_satis = VCF9255,
    age = VCF0101,
    age_cohort = VCF0103,
    gender = VCF0104,
    race_eth = VCF0105a,
    work_status = VCF0118,
    relg = VCF0128,
    educ7 = VCF0140a,
    amer_parents = VCF0143,
    marital_status = VCF0147,
    sexori = VCF9279,
    health_insur = VCF9281
  ) %>%
  
  # recode NAs
  # [CLAUDE FLAG]
  mutate(
    weight        = if_else(weight %in% c(0), NA, weight),
    reg_census    = if_else(reg_census %in% c(0), NA, reg_census),
    dem_therm     = if_else(dem_therm %in% c(98, 99), NA, dem_therm),
    rep_therm     = if_else(rep_therm %in% c(98, 99), NA, rep_therm),
    pid7          = if_else(pid7 %in% c(0), NA, pid7),
    dem_like_binary    = if_else(dem_like_binary    %in% c(8, 9), NA, dem_like_binary),
    dem_dislike_binary = if_else(dem_dislike_binary %in% c(8, 9), NA, dem_dislike_binary),
    rep_like_binary    = if_else(rep_like_binary    %in% c(8, 9), NA, rep_like_binary),
    rep_dislike_binary = if_else(rep_dislike_binary %in% c(8, 9), NA, rep_dislike_binary),
    party_diff         = if_else(party_diff %in% c(0), NA, party_diff),
    party_more_consv   = if_else(party_more_consv %in% c(0), NA, party_more_consv),
    dem_ideo           = if_else(dem_ideo %in% c(0, 8), NA, dem_ideo),
    rep_ideo           = if_else(rep_ideo %in% c(0, 8), NA, rep_ideo),
    dem_liking_cses    = if_else(dem_liking_cses %in% c(-7, -8, -9), NA, dem_liking_cses),
    rep_liking_cses    = if_else(rep_liking_cses %in% c(-7, -8, -9), NA, rep_liking_cses),
    right_track        = if_else(right_track %in% c(-8, -9), NA, right_track),
    therm_lib          = if_else(therm_lib %in% c(98, 99), NA, therm_lib),
    therm_consv        = if_else(therm_consv %in% c(98, 99), NA, therm_consv),
    ideology           = if_else(ideology %in% c(0), NA, ideology),
    understand_issue   = if_else(understand_issue %in% c(-8, -9), NA, understand_issue),
    too_complicated    = if_else(too_complicated %in% c(-8, -9), NA, too_complicated),
    power_matters      = if_else(power_matters %in% c(-8, -9), NA, power_matters),
    dem_satis          = if_else(dem_satis %in% c(-8, -9), NA, dem_satis),
    age                = if_else(age %in% c(0), NA, age),
    age_cohort         = if_else(age_cohort %in% c(0), NA, age_cohort),
    gender             = if_else(gender %in% c(0), NA, gender),
    race_eth           = if_else(race_eth %in% c(9), NA, race_eth),
    work_status        = if_else(work_status %in% c(9), NA, work_status),
    relg               = if_else(relg %in% c(0), NA, relg),
    educ7              = if_else(educ7 %in% c(8, 9), NA, educ7),
    amer_parents       = if_else(amer_parents %in% c(8, 9), NA, amer_parents),
    marital_status     = if_else(marital_status %in% c(8, 9), NA, marital_status),
    sexori             = if_else(sexori %in% c(-8, -9), NA, sexori),
    health_insur       = if_else(health_insur %in% c(-8, -9), NA, health_insur)
  ) %>%
  mutate(across(where(is.character),
                ~ if_else(.x %in% c("NA", "DK", "RF", "INAP"), NA, .x)))

# merge with open-ended
data <- left_join(cdf_cln, oe_full, by = c('year', 'caseid'))

write_csv(data, 'data/data.csv')
