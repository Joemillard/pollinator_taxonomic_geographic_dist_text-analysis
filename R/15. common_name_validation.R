# check the frequency of honey bee and bumblebee relative to scientific names

# packages
library(dplyr)
library(data.table)
library(stringr)
library(ggplot2)
library(forcats)
library(patchwork)

# source the functions R script
source("R/00. functions.R")

# read in the species scraped data
species_scraped <- read.csv("outputs/02. post_COL_species_scrape.csv", stringsAsFactors = FALSE)

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

# filter scopus download for abstract and DOI, and subsetted row when testing
abstracts <- scopus_download %>%
  select(Abstract, DOI, Year, Title, EID) %>%
   rename(abstract = Abstract) %>%
  .[1:30644,]

# strings to check for 
bee_strings <- c("bumble bee", "bumblebee")

# run function to count number of strings and then just take the EID
bees <- count_bees(abstracts, bee_strings)

bees_new <- bees %>% mutate(type = "common") %>% select(-bee_strings.j.) %>% rename("EID" = "download.EID.i.") %>% unique()

# shorten the scientific name string to just bombus
genera_scraped <-  speciesify(species_scraped, 1, 1)

# subset the main scrape to find any abstracts that mention scientific name for bombus and Apis
species_bombus <- genera_scraped %>% dplyr::filter(scientific_name =="Bombus") %>% dplyr::select(EID) %>% unique() %>% mutate(type = "scraped")

# calculate the overlap between the scientific names and common names
scrape_common <- full_join(species_bombus, bees_new, by = "EID")

# rename column
scrape_common <- scrape_common %>%
  rename("scraped" = "type.x") %>%
  rename("common" = "type.y")

# assign TRUE/FALSE according to overlap
scrape_common$scraped <- !is.na(scrape_common$scraped)
scrape_common$common <- !is.na(scrape_common$common)

# change TREU/FALSE to values for overlap
scrape_common$type_1[scrape_common$scraped == TRUE & scrape_common$common == TRUE] <- 1
scrape_common$type_1[scrape_common$scraped == TRUE & scrape_common$common == FALSE] <- 2
scrape_common$type_1[scrape_common$scraped == FALSE & scrape_common$common == TRUE] <- 3

# plot across two panels
Bombus <- scrape_common %>%
  mutate(type_1 = factor(type_1, levels = c(3, 2, 1))) %>%
  ggplot() +
    geom_bar(aes(x = 1, fill = type_1), stat = "count", position = "stack", colour = "black") +
    scale_fill_manual("Taxonomic name", 
                      label = c("Common only","Latin only", "Latin and Common"),
                      values = c("red", "orange", "grey")) +
    theme_bw() +
    guides(fill = FALSE) +
    scale_y_continuous(expand = c(0, 0), limits = c(0, 2150)) +
    xlab("Bombus") +
    theme(axis.ticks.x = element_blank(), axis.text.x = element_blank(), axis.text.y = element_blank(), axis.title.y = element_blank(), axis.ticks.y = element_blank())

# apis plot
# strings to check for 
apis_strings <- c("honey bee", "honeybee")

# run function to count number of strings and then just take the EID
bees_apis <- count_bees(abstracts, apis_strings)

bees_apis <- bees_apis %>% mutate(type = "common") %>% select(-bee_strings.j.) %>% rename("EID" = "download.EID.i.") %>% unique()

# shorten the scientific name string to just bombus
genera_scraped <-  speciesify(species_scraped, 1, 1)

# subset the main scrape to find any abstracts that mention scientific name for bombus and Apis
species_apis <- genera_scraped %>% dplyr::filter(scientific_name =="Apis") %>% dplyr::select(EID) %>% unique() %>% mutate(type = "scraped")

# calculate the overlap between the scientific names and common names
scrape_common_apis <- full_join(species_apis, bees_apis, by = "EID")

# rename column
scrape_common_apis <- scrape_common_apis %>%
  rename("scraped" = "type.x") %>%
  rename("common" = "type.y")

# assign TRUE/FALSE according to overlap
scrape_common_apis$scraped <- !is.na(scrape_common_apis$scraped)
scrape_common_apis$common <- !is.na(scrape_common_apis$common)

# change TREU/FALSE to values for overlap
scrape_common_apis$type_1[scrape_common_apis$scraped == TRUE & scrape_common_apis$common == TRUE] <- 1
scrape_common_apis$type_1[scrape_common_apis$scraped == TRUE & scrape_common_apis$common == FALSE] <- 2
scrape_common_apis$type_1[scrape_common_apis$scraped == FALSE & scrape_common_apis$common == TRUE] <- 3

# plot across two panels
Apis <- scrape_common_apis %>%
  mutate(type_1 = factor(type_1, levels = c(3, 2, 1))) %>%
  ggplot() +
  geom_bar(aes(x = 1, fill = type_1), stat = "count", position = "stack", colour = "black") +
  scale_fill_manual("Taxonomic name", 
                    label = c("Common only","Latin only", "Latin and Common"),
                    values = c("red", "orange", "grey")) +
  theme_bw() +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 2150)) +
  guides(fill = FALSE) +
  xlab("Apis") +
  ylab("Abstract count") +
  theme(axis.ticks.x = element_blank(), axis.text.x = element_blank())


# apis plot
# strings to check for 
mason_strings <- c("mason bee", "mason-bee")

# run function to count number of strings and then just take the EID
bees_mason <- count_bees(abstracts, mason_strings)

bees_mason <- bees_mason %>% mutate(type = "common") %>% select(-bee_strings.j.) %>% rename("EID" = "download.EID.i.") %>% unique()

# shorten the scientific name string to just bombus
genera_scraped <-  speciesify(species_scraped, 1, 1)

# subset the main scrape to find any abstracts that mention scientific name for bombus and Apis
species_mason <- genera_scraped %>% dplyr::filter(scientific_name =="Osmia") %>% dplyr::select(EID) %>% unique() %>% mutate(type = "scraped")

# calculate the overlap between the scientific names and common names
scrape_common_mason <- full_join(species_mason, bees_mason, by = "EID")

# rename column
scrape_common_mason <- scrape_common_mason %>%
  rename("scraped" = "type.x") %>%
  rename("common" = "type.y")

# assign TRUE/FALSE according to overlap
scrape_common_mason$scraped <- !is.na(scrape_common_mason$scraped)
scrape_common_mason$common <- !is.na(scrape_common_mason$common)

# change TREU/FALSE to values for overlap
scrape_common_mason$type_1[scrape_common_mason$scraped == TRUE & scrape_common_mason$common == TRUE] <- 1
scrape_common_mason$type_1[scrape_common_mason$scraped == TRUE & scrape_common_mason$common == FALSE] <- 2
scrape_common_mason$type_1[scrape_common_mason$scraped == FALSE & scrape_common_mason$common == TRUE] <- 3

# plot across two panels
mason <- scrape_common_mason %>%
  mutate(type_1 = factor(type_1, levels = c(3, 2, 1))) %>%
  ggplot() +
  geom_bar(aes(x = 1, fill = type_1), stat = "count", position = "stack", colour = "black") +
  scale_fill_manual("Taxonomic name", 
                    label = c("Common only","Latin only", "Latin and Common"),
                    values = c("red", "orange", "grey")) +
  xlab("Osmia") +
  guides(fill = FALSE) +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 2150)) +
  theme_bw() +
  theme(axis.ticks.x = element_blank(), axis.text.x = element_blank(), axis.text.y = element_blank(), axis.title.y = element_blank(), axis.ticks.y = element_blank())

# apis plot
# strings to check for 
leafcutter_strings <- c("leafcutter bee", "leaf-cutter bee")

# run function to count number of strings and then just take the EID
bees_leafcutter <- count_bees(abstracts, leafcutter_strings)

bees_leafcutter <- bees_leafcutter %>% mutate(type = "common") %>% select(-bee_strings.j.) %>% rename("EID" = "download.EID.i.") %>% unique()

# shorten the scientific name string to just bombus
genera_scraped <-  speciesify(species_scraped, 1, 1)

# subset the main scrape to find any abstracts that mention scientific name for bombus and Apis
species_leafcutter <- genera_scraped %>% dplyr::filter(scientific_name =="Megachile") %>% dplyr::select(EID) %>% unique() %>% mutate(type = "scraped")

# calculate the overlap between the scientific names and common names
scrape_common_leafcutter <- full_join(species_leafcutter, bees_leafcutter, by = "EID")

# rename column
scrape_common_leafcutter <- scrape_common_leafcutter %>%
  rename("scraped" = "type.x") %>%
  rename("common" = "type.y")

# assign TRUE/FALSE according to overlap
scrape_common_leafcutter$scraped <- !is.na(scrape_common_leafcutter$scraped)
scrape_common_leafcutter$common <- !is.na(scrape_common_leafcutter$common)

# change TREU/FALSE to values for overlap
scrape_common_leafcutter$type_1[scrape_common_leafcutter$scraped == TRUE & scrape_common_leafcutter$common == TRUE] <- 1
scrape_common_leafcutter$type_1[scrape_common_leafcutter$scraped == TRUE & scrape_common_leafcutter$common == FALSE] <- 2
scrape_common_leafcutter$type_1[scrape_common_leafcutter$scraped == FALSE & scrape_common_leafcutter$common == TRUE] <- 3

# plot across two panels
leafcutter <- scrape_common_leafcutter %>%
  mutate(type_1 = factor(type_1, levels = c(3, 2, 1))) %>%
  ggplot() +
  geom_bar(aes(x = 1, fill = type_1), stat = "count", position = "stack", colour = "black") +
  scale_fill_manual("Taxonomic name", 
                    label = c("Common only","Latin only", "Latin and Common"),
                    values = c("red", "orange", "grey")) +
  xlab("Megachile") +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 2150)) +
  theme_bw() +
  theme(axis.ticks.x = element_blank(), axis.text.x = element_blank(), axis.text.y = element_blank(), axis.title.y = element_blank(), axis.ticks.y = element_blank())

Apis + Bombus + mason + leafcutter +plot_layout(nrow = 1)

ggsave("comb_latin_binomial_5.png", scale  = 1, dpi = 350)
