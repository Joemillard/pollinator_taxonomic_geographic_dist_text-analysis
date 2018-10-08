## scrape abstract species names from pollinat* abstracts

# vector for packages to install 
packages <- c("dplyr", "taxize", "data.table")

# packages to read in
library(dplyr)
library(taxize)
library(data.table)

# source the functions R script
source("~/PhD/Aims/Aim 1 - collate pollinator knowledge/pollinator_taxonomic_geographic_dist_text-analysis/R/functions.R")

## read in the scopus download (TEST) ####
scopus_download <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Data/Scopus data downloads/Test/2000 records - pollinat, English, articles.csv", stringsAsFactors = F)

## read in the full Scopus download and set up data - 30,664 articles; pollinat*, English, Articles ####
pollinat_2018 <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Data/Scopus data downloads/01-2018_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_2017 <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Data/Scopus data downloads/02-2017_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_2016 <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Data/Scopus data downloads/03-2016_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_2015 <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Data/Scopus data downloads/04-2015_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_2014 <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Data/Scopus data downloads/05-2014_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_2013 <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Data/Scopus data downloads/06-2013_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_2012 <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Data/Scopus data downloads/07-2012_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_2011 <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Data/Scopus data downloads/08-2011_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_2010 <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Data/Scopus data downloads/09-2010_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_2009 <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Data/Scopus data downloads/10-2009_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_2008 <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Data/Scopus data downloads/11-2008_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_2007_2006 <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Data/Scopus data downloads/12-2007-2006_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_2005_2004 <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Data/Scopus data downloads/13-2005-2004_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_2003_2002 <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Data/Scopus data downloads/14-2003-2002_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_2001_2000 <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Data/Scopus data downloads/15-2001-2000_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_1999_1997 <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Data/Scopus data downloads/16-1999-1997_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_1996_1993 <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Data/Scopus data downloads/17-1996-1993_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_1992_1988 <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Data/Scopus data downloads/18-1992-1988_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_1987_1978 <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Data/Scopus data downloads/19-1987-1978_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_1977_1903 <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Data/Scopus data downloads/20-1977-1903_pollinat_English_articles.csv", stringsAsFactors=FALSE)

# bind data from all years
scopus_download <- rbind(pollinat_2018, pollinat_2017, pollinat_2016, pollinat_2015, 
                         pollinat_2014, pollinat_2013, pollinat_2012, pollinat_2011,
                         pollinat_2010, pollinat_2009, pollinat_2008, pollinat_2007_2006,
                         pollinat_2005_2004, pollinat_2003_2002, pollinat_2001_2000,
                         pollinat_1999_1997, pollinat_1996_1993, pollinat_1992_1988,
                         pollinat_1987_1978, pollinat_1977_1903)

# filter scopus download for abstract and DOI, and subsetted row when testing
Abstract <- scopus_download %>%
  select(Abstract, DOI, Year, Title, EID) %>%
  .[1:30644,]

# run scrape_abs function on Abstract object and time it
system.time({
  all_species <- scrape_abs(abs = Abstract, num = nrow(Abstract))
})

# write to csv
write.csv(all_species, "03_30644-abs_DOI_Year_Title_EID.csv")
