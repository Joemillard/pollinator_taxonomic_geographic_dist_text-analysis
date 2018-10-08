## script for setting up csv for checking relatedness of abstracts to pollination

# vector for the packages to install 
packages <- c("dplyr", "ggplot2", "patchwork")

# packages
library(dplyr)
library(ggplot2)
library(patchwork)

# read in the original scopus download
scopus_download <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Data/Scopus data downloads/scopus_download.csv", stringsAsFactors = FALSE)

# read in the scraped data
scraped_species <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Outputs/scrape_abs/cleaned/07_30644_abs_EID_Year_Title_paper-approach_cleaned.csv", stringsAsFactors = FALSE)

# vector for unique IDs
unique_EID <- unique(scraped_species$EID)

# filter the scopus abstracts for those that have animal species
scopus_filtered <- scopus_download %>%
  filter(EID %in% unique_EID) %>%
  select(EID, Year, Title, Abstract)

# randomly sample 100 of the abstracts - set seed first for same random bunch
set.seed(20)

# randomly sample 100
scopus_filtered <-  scopus_filtered[sample(nrow(scopus_filtered), 100),]

# write to csv goes here for manual check of relatedness, then carry out manual edit for paper types 

## build figure for proportion

# read in csv
abstract_relatedness <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Outputs/scrape_abs/cleaned/validation/100-abstracts_pollination-relatedness-check_manual-edit.csv", stringsAsFactors = TRUE)

# sort the levels
abstract_relatedness$Study_type <- factor(abstract_relatedness$Study_type, levels = c("other", "status", "general"))

# build graphic
ggplot(abstract_relatedness) +
  geom_histogram(aes(x = group, fill = Study_type), colour = "black", stat = "count", alpha = 0.6) +
  ylab("Percentage") +
  theme_bw() +
  scale_fill_manual(values = c("blue", "white", "black"), name = "Study type", labels = c("Other", "Status/disturbance", "General pollination")) +
  theme(axis.text.x = element_blank(), axis.title.x = element_blank(), axis.ticks.x = element_blank(), panel.grid = element_blank(), plot.margin = margin(0.5, 10, 0.5, 1, "cm"), text = element_text(size = 13))

ggsave("study-type-validation-05.png", scale = 1.4, dpi = 350)