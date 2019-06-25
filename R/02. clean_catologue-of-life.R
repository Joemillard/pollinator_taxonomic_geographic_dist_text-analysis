## script for cleaning the COL taxonomic download - i.e. removing the author names and subsetting for animals

# vector for the packages to install 
packages <- c("dplyr", "stringr", "data.table")

# packages to read in
library(dplyr)
library(stringr)
library(data.table)

# source the functions R script
source("R/00. functions.R")

# download and read in 2017 catalogue of life data
taxa <- read.delim("data/taxonomic_data/taxa.txt", stringsAsFactors=FALSE)

# clean data - seleting the appropriate columns and filtering for animals
new_taxa <- taxa %>%
  dplyr::rename(..taxonID = ï..taxonID) %>%
  dplyr::select(taxonRank, scientificName, kingdom, class, scientificNameAuthorship, order, family,..taxonID, acceptedNameUsageID, parentNameUsageID, taxonomicStatus) %>%
  filter(kingdom == "Animalia")

# remove punctutation and special charactes from species and author columns
new_taxa$scientificNameAuthorship <- gsub("[[:punct:]]", "", new_taxa$scientificNameAuthorship)
new_taxa$scientificName <- gsub("[[:punct:]]", "", new_taxa$scientificName)

# run function and time it - remove the author information from the species column
system.time({
  species_names <- species(taxa_data = new_taxa, count = nrow(new_taxa))
})

# save as rds file
saveRDS(species_names, "data/taxonomic_data/unique_COL_species_03.rds")
