## script for cleaning the COL taxonomic download - i.e. removing the author names 
## set up checkpoint for reproducibility
library(checkpoint)
checkpoint("2018-04-01")

## packages
library(dplyr)
library(stringr)
library(data.table)

# source the functions R script
source("~/PhD/Aims/Aim 1 - collate pollinator knowledge/pollinator_taxonomic_geographic_dist_text-analysis/R/functions.R")

# read in data
taxa <- read.delim("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Data/Taxonomic data/2017-annual/taxa.txt", stringsAsFactors=FALSE)

# clean data - seleting the appropriate columns and filtering for animals
new_taxa <- taxa %>%
  dplyr::select(taxonRank, scientificName, kingdom, class, scientificNameAuthorship, order, family, ï..taxonID, acceptedNameUsageID, parentNameUsageID, taxonomicStatus) %>%
  filter(kingdom == "Animalia")

# remove punctutation and special charactes from species and author columns
new_taxa$scientificNameAuthorship <- gsub("[[:punct:]]", "", new_taxa$scientificNameAuthorship)
new_taxa$scientificName <- gsub("[[:punct:]]", "", new_taxa$scientificName)

# run function and time it - remove the author information from the species column
system.time({
  species_names <- species(taxa_data = new_taxa, count = nrow(new_taxa))
})

# save as rds file
saveRDS(species_names, "unique_COL_species_02.rds")
