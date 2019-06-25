## script for putting together prisma meta analysis paper/species subset path

# vector for packages to install 
packages <- c("DiagrammeR", "DiagrammeRsvg", "rsvg", "dplyr", "stringr")

# packages 
library(DiagrammeR)
library(DiagrammeRsvg)
library(rsvg)
library(dplyr)
library(stringr)

# source the functions R script
source("R/00. functions.R")

# read in the geoparsed data
geoparsed <- read.csv("outputs/04. post_geoparse_abstracts.csv", encoding="UTF-8", stringsAsFactors = FALSE)

# remove duplicates
geoparsed <- geoparsed %>% dplyr::select(-X.U.FEFF.)
geoparsed <- geoparsed %>% group_by(EID) %>% unique() %>% ungroup()

# read in the mistakes for geoparser and put into one column
geoparse_check <- read.csv("data/validation_data/geoparse_check.csv", stringsAsFactors=FALSE)

# read in the species scraped data
species_scraped <- read.csv("outputs/02. post_COL_species_scrape.csv", stringsAsFactors = FALSE)

## set up the data calculate species, genera, and order frequencies
# select main columns 
species_scraped <- species_scraped %>%
  dplyr::rename(taxa_data...taxonID.i. = taxa_data.ï..taxonID.i.) %>%
  dplyr::select(-original, -taxa_data.scientificNameAuthorship.i., -taxa_data...taxonID.i., -taxa_data.acceptedNameUsageID.i., -taxa_data.parentNameUsageID.i., -taxa_data.taxonomicStatus.i., -level)

# get unique species_scraped titles
species_EID <- species_scraped %>% 
  dplyr::filter(!duplicated(Title)) %>%
  dplyr::select(EID) %>%
  unique()

# subset geoparsed for those EID in species_scrape
geoparsed <- geoparsed %>%
  dplyr::filter(EID %in% species_EID$EID)

# only keep first and second word
species_scraped$scientific_name <- species_scraped$scientific_name %>% word(1, 2)

# join geoparsed with species
species_geoparsed <- inner_join(species_scraped, geoparsed, by = "EID")

# remove duplicates
species_geoparsed <- species_geoparsed %>% dplyr::select(-X)
species_geoparsed <- species_geoparsed %>% group_by(EID) %>% unique() %>% ungroup()

## calculating how many genera and order after merging with geoparsed data - for PRISMA diagram
# convert scraped data with geoparsed data to species form
gen <- speciesify(species_geoparsed, 1, 1)
spec <- speciesify(species_geoparsed, 1, 2)

# filter out NAs for population
gen <- gen %>% filter(!is.na(population))
spec <- spec %>% filter(!is.na(population))

# count number of species, genera, and orders
summary(unique(spec$scientific_name))
summary(unique(gen$scientific_name))
summary(unique(spec$taxa_data.order.i.))

## drawing the PRISMA diagram
grViz("
      
      digraph boxes_and_circles{
      
      ## node statement format
      node [shape = box
      fontname = Helvetica]
      
      ## statement structure
      # papers
      '37895 (pollinat* papers)'; 36127; 30546; 22469; 3974; 2087
      
      # species
      '2254 (animal species)'; 1673
      
      # genera
      '1013 (animal genera)'; 765
      
      # orders
      '63 (animal orders)'; 47
      
      ## edge statements
      # papers
      '37895 (pollinat* papers)' -> 36127 [label = '   Filter non English'
      fontname = Helvetica];
      36127 -> 30546 [label = '   Filter non Article'
      fontname = Helvetica];
      30546 -> 22469 [label = '   Filter non potential species record'
      fontname = Helvetica];
      22469 -> 3974 [label = '   Filter non animal species record'
      fontname = Helvetica]; 
      3974 -> 2087;
      
      # species
      '2254 (animal species)'-> 1673
      
      # genera
      '1013 (animal genera)'-> 765
      
      # orders
      '63 (animal orders)'-> 47 [label = '   Filter non potential geographic record'
      fontname = Helvetica] 
      
      subgraph {
      rank = same; '3974'; '1013 (animal genera)'; '63 (animal orders)' ; '2254 (animal species)'
      }
      
      }
      ") %>%
  
  export_svg %>% charToRaw %>% rsvg_pdf("prisma-diagram_abstract-scrape-03.pdf", width = 700, height= 700)
