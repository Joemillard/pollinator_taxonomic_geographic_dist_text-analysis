## scrape abstract species names from pollinat* abstracts

# vector for packages to install 
packages <- c("dplyr", "taxize", "data.table")

# packages to read in
library(dplyr)
library(taxize)
library(data.table)

# source the functions R script
source("R/00. functions.R")

## read in the full Scopus download and set up data - 30,664 articles; pollinat*, English, Articles ####
pollinat_2018 <- read.csv("data/01-2018_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_2017 <- read.csv("data/02-2017_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_2016 <- read.csv("data/03-2016_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_2015 <- read.csv("data/04-2015_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_2014 <- read.csv("data/05-2014_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_2013 <- read.csv("data/06-2013_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_2012 <- read.csv("data/07-2012_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_2011 <- read.csv("data/08-2011_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_2010 <- read.csv("data/09-2010_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_2009 <- read.csv("data/10-2009_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_2008 <- read.csv("data/11-2008_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_2007_2006 <- read.csv("data/12-2007-2006_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_2005_2004 <- read.csv("data/13-2005-2004_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_2003_2002 <- read.csv("data/14-2003-2002_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_2001_2000 <- read.csv("data/15-2001-2000_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_1999_1997 <- read.csv("data/16-1999-1997_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_1996_1993 <- read.csv("data/17-1996-1993_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_1992_1988 <- read.csv("data/18-1992-1988_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_1987_1978 <- read.csv("data/19-1987-1978_pollinat_English_articles.csv", stringsAsFactors=FALSE)
pollinat_1977_1903 <- read.csv("data/20-1977-1903_pollinat_English_articles.csv", stringsAsFactors=FALSE)

# bind data from all years
scopus_download <- rbind(pollinat_2018, pollinat_2017, pollinat_2016, pollinat_2015, 
                         pollinat_2014, pollinat_2013, pollinat_2012, pollinat_2011,
                         pollinat_2010, pollinat_2009, pollinat_2008, pollinat_2007_2006,
                         pollinat_2005_2004, pollinat_2003_2002, pollinat_2001_2000,
                         pollinat_1999_1997, pollinat_1996_1993, pollinat_1992_1988,
                         pollinat_1987_1978, pollinat_1977_1903)

# write scopus file to csv for scripts downstream
write.csv(scopus_download, "data/scopus_download.csv")

# filter scopus download for abstract and DOI, and subsetted row when testing
Abstract <- scopus_download %>%
  select(Abstract, DOI, Year, Title, EID) %>%
  .[1:30644,]

# run scrape_abs function on Abstract object and time it
system.time({
  all_species <- scrape_abs(abs = Abstract, num = nrow(Abstract))
})

# write to csv
write.csv(all_species, "outputs/01. initial_abstract_scrape.csv")
