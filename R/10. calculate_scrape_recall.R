## script for checking the species scraper against manually checked abstracts to return recall

# vector for the packages to install 
packages <- c("dplyr", "stringr")

# packages
library(dplyr)
library(stringr)

## website used for taxonomic accepted name
# http://www.discoverlife.org - catalogue of life

# read in the manual scrape
manual_scrape <- read.csv("data/validation_data/300_random-abstracts_manual-scrape.csv")

# select only required columns and rename
manual_scrape <- manual_scrape %>%
  select(Scientific, EID) %>%
  rename(scientific_name = Scientific)

# duplicate the scientific_name column
manual_scrape$scientific_name_2 <- manual_scrape$scientific_name

# read in the automated cleaned scrape
automated_approach <- read.csv("outputs/02. post_COL_species_scrape.csv", stringsAsFactors=FALSE)

# only keep first and second word
automated_approach$scientific_name <- automated_approach$scientific_name %>% word(1, 2)

# remove duplicated for each row
automated_approach <- automated_approach %>% 
  select(scientific_name, EID, original) %>% 
  group_by(EID) %>% 
  unique() %>%
  ungroup()

# join manual and automated
manual_automated_join <- left_join(manual_scrape, automated_approach , by = c("EID", "scientific_name"))

# remove duplicates
manual_automated_join <- manual_automated_join %>%
  group_by(EID) %>%
  unique() %>%
  ungroup()

# remove duplicated versions of first 3 columns
manual_automated_join <- manual_automated_join[!duplicated(manual_automated_join[1:3]),]

# filter out NAs from other columns
manual_automated_join <- manual_automated_join %>%
  filter(!is.na(scientific_name))

# filter out non-accepted names in the manual scrape
manual_automated_join <- manual_automated_join %>%
  filter(!scientific_name_2 %in% c("Perdita desdemona", "Perdita exusta", "Perdita hippolyta", "Perdita hooki", "Perdita nuttalliae", "Perdita prodigiosa", "Perdita sycorax", "Perdita titania", "Perdita yanegai", "Prodoxus praedictus", "Kradibia tentacularis"))

# count NAs to give number found in the manual scrape
number_spec_found <- c(colSums(!is.na(manual_automated_join)))

# calculate accepted animal species recall = 79.52 (2dp)
number_spec_found[4] / number_spec_found[3] * 100

