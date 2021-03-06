## script for preparing abstracts for geoparsing with CLIFF-CLAVIN prep

# vector for the packages to install 
packages <- c("dplyr", "stringi", "data.table")

# packages to read in
library(dplyr)
library(data.table)
library(stringi)

# source the functions R script
source("R/00. functions.R")

# read in the scraped species names 
species_scraped <- read.csv("outputs/02. post_COL_species_scrape.csv", stringsAsFactors = FALSE)

# convert scraped species to character
species_scraped$Year <- species_scraped$Year %>%
  as.character()

# read in the abstracts as a single bound object
scopus_download <- read.csv("data/scopus_download.csv", stringsAsFactors = FALSE, na.strings = c("", "NA"))

# subset for required columns in Abstract
Abstracts <- scopus_download %>%
  select(Abstract, EID)

# filter abstracts
Abstracts <- Abstracts %>%
  filter(!grepl("No abstract available", Abstract)) %>%
  filter(!is.na(Abstract))

# merge by title
Abstract_scrape_join <- inner_join(species_scraped, Abstracts, by = "EID")

# remove duplicated titles
unique_join <- Abstract_scrape_join %>%
  filter(!duplicated(Title)) %>%
  mutate_all(as.character)

# run function for removing characters after copyright sign
cleaned_abstracts <- remove_after_copyright(abstract = unique_join)

# rename columns to simplify downstream
cleaned_abstracts <- cleaned_abstracts %>%
  rename(abstract = abstract.Abstract.i.) %>%
  rename(EID = abstract.EID.i.)

# remove all abstract special characters    
cleaned_abstracts$abstract <- stri_enc_toutf8(cleaned_abstracts$abstract)

# convert encoding
cleaned_abstracts$abstract <- iconv(cleaned_abstracts$abstract, to = "ASCII//TRANSLIT")

# write to csv for export to python
write.csv(cleaned_abstracts, "outputs/03. animal_species_cleaned_for_geoparse.csv")