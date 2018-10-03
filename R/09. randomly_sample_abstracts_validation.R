# random sampling of abstracts for checking of animal species recall and precision

# packages
library(dplyr)

# read in the scopus download
scopus_download <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Data/Scopus data downloads/scopus_download.csv", stringsAsFactors=FALSE)

# random sample of abstracts - set seed first
set.seed(20)

# select 300 random abstracts
random_scopus <-  scopus_download[sample(nrow(scopus_download), 300),]

# remove unneeded columns
random_scopus <- random_scopus %>%
  select(Title, Year, Abstract, EID)

# write to csv
write.csv(random_scopus, "300_random-abstracts_check-species-scrape.csv")