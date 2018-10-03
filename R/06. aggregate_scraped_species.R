# script for aggregating data assigned to country level for all scrape - creating one dataset with DOIs and species as a character string; 
# and one with species and DOI as character string
# - IMPORTANT - if come to use this for checking papers, will want to remove continental and oddity mentions?

# set up checkpoint
library(checkpoint)
checkpoint("2018-05-03")

# packages
library(dplyr)
library(reshape2)
library(data.table)
library(stringr)

# source the functions R script
source("~/PhD/Aims/Aim 1 - collate pollinator knowledge/pollinator_taxonomic_geographic_dist_text-analysis/R/00. functions.R")

# read in the scraped species names 
species_scraped <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Outputs/scrape_abs/cleaned/07_30644_abs_EID_Year_Title_paper-approach_cleaned.csv", stringsAsFactors = FALSE)

# read in the geoparsed data
geoparsed <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Outputs/scrape_abs/cleaned/for_geoparse/Post_geoparse/03-geoparsed-abstracts_level-1-2-cleaned.csv", encoding="UTF-8", stringsAsFactors = FALSE)

# get unique species_scraped titles
species_EID <- species_scraped %>% 
  dplyr::filter(!duplicated(Title)) %>%
  dplyr::select(EID) %>%
  unique()

# subset geoparsed for those EID in species_scrape
geoparsed <- geoparsed %>%
  dplyr::filter(EID %in% species_EID$EID)

# read in the mistakes for geoparser and put into one column
geoparse_check <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Outputs/scrape_abs/cleaned/for_geoparse/Post_geoparse/checking_geoparsed/geoparse_check.csv", stringsAsFactors=FALSE)

# join the scraped data and the geoparsed data by EID
scrape_join <- inner_join(geoparsed, species_scraped, by = "EID")

# run speciesify function for genera
scrape_clean <- speciesify(scraped = scrape_join, first_word = 1, last_word = 1)

# convert all the result to characters
scrape_clean <- scrape_clean %>%
  mutate_all(as.character)

## aggregate by DOI
aggregated_DOI <- aggregate(cbind(scientific_name, level, Year, name, taxa_data.class.i.) ~ EID, data = scrape_clean, paste, collapse = ", ")

# run function to remove duplicates in aggregated DOI data
agg_data_DOI <- unique_row_DOI(aggregated = aggregated_DOI)

# convert the result to all characters
agg_data_DOI <- agg_data_DOI %>%
  mutate_all(as.character)

# write to csv
write.csv(agg_data_DOI, "cliff_species_DOI_aggregation-04.csv")

## aggregate by pollinator
aggregated_spec <- aggregate(cbind(level, Year, EID, name, taxa_data.class.i., taxa_data.order.i., taxa_data.family.i.) ~ scientific_name, data = scrape_clean, paste, collapse = ", ")

# run function to remove duplicates in aggregated species
agg_data_spec <- unique_row_spec(aggregated_spec)

# convert the result to all characters
agg_data_spec <- agg_data_spec %>%
  mutate_all(as.character)

# count number of DOIs in pollinator dataframe
agg_data_spec$DOI_count <- str_count(agg_data_spec$unique_loc, ", ") + 1

# put DOI column next to DOI and sort by size
agg_data_spec <- agg_data_spec[c("aggregated.scientific_name.i.", "unique_class", "unique_order", "unique_family", "unique_loc", "DOI_count", "unique_year", "unique_name", "unique_level")]
agg_data_spec <- agg_data_spec[order(-agg_data_spec$DOI_count),]

# write species aggregations to csv
write.csv(agg_data_spec, "cliff_species_genus_aggregation_fully-filtered-05.csv")
