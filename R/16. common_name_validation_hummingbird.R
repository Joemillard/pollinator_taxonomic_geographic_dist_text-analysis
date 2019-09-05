# check the frequency of hummingbird mentions relative to species of hummingbird

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

# strings to check for hawk-moth
moth_strings <- c("Hawk-moth", "hawk moth", "hawk-moth", "Sphingidae")

# run function to count number of strings and then just take the EID
moth <- count_bees(abstracts, moth_strings)

moth_new <- moth %>% mutate(type = "common") %>% select(-bee_strings.j.) %>% rename("EID" = "download.EID.i.") %>% unique()

# subset the main scrape to find any abstracts that mention scientific name for hawk-moths
species_moth <- species_scraped %>% dplyr::filter(taxa_data.family.i. == "Sphingidae") %>% dplyr::select(EID) %>% unique() %>% mutate(type = "scraped")

# calculate the overlap between the scientific names and common names
scrape_common_moth <- full_join(species_moth, moth_new, by = "EID")

# rename column
scrape_common_moth <- scrape_common_moth %>%
  rename("scraped" = "type.x") %>%
  rename("common" = "type.y")

# assign TRUE/FALSE according to overlap
scrape_common_moth$scraped <- !is.na(scrape_common_moth$scraped)
scrape_common_moth$common <- !is.na(scrape_common_moth$common)

# change TREU/FALSE to values for overlap
scrape_common_moth$type_1[scrape_common_moth$scraped == TRUE & scrape_common_moth$common == TRUE] <- 1
scrape_common_moth$type_1[scrape_common_moth$scraped == TRUE & scrape_common_moth$common == FALSE] <- 2
scrape_common_moth$type_1[scrape_common_moth$scraped == FALSE & scrape_common_moth$common == TRUE] <- 3

# plot across two panels
Moth <- scrape_common_moth %>%
  mutate(type_1 = factor(type_1, levels = c(3, 2, 1))) %>%
  ggplot() +
  geom_bar(aes(x = 1, fill = type_1), stat = "count", position = "stack", colour = "black") +
  scale_fill_manual("Taxonomic name", 
                    label = c("Common only","Latin only", "Latin and Common"),
                    values = c("red", "orange", "grey")) +
  guides(fill = FALSE) +
  theme_bw() +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 800)) +
  xlab("Hawk-moths") +
  ylab("Abstract count") +
  theme(axis.ticks.x = element_blank(), axis.text.x = element_blank(), axis.text.y = element_blank(), axis.title.y = element_blank(), axis.ticks.y = element_blank())

# remove string for humming hawk-moth from the abstracts
abstracts$abstract <- gsub("hummingbird hawk-moth", "", abstracts$abstract)
abstracts$abstract <- gsub("hummingbird hawk moth", "", abstracts$abstract)
abstracts$abstract <- gsub("hummingbird hawkmoth", "", abstracts$abstract)

# strings to check for 
hummingbird_strings <- c("humming-bird", "hummingbird", "Hummingbird", "Trochilidae")

# run function to count number of strings and then just take the EID
hummingbird <- count_bees(abstracts, hummingbird_strings)

hummingbird_new <- hummingbird %>% mutate(type = "common") %>% select(-bee_strings.j.) %>% rename("EID" = "download.EID.i.") %>% unique()

# subset the main scrape to find any abstracts that mention scientific name for hummingbirds
species_hummingbird <- species_scraped %>% dplyr::filter(taxa_data.family.i. == "Trochilidae") %>% dplyr::select(EID) %>% unique() %>% mutate(type = "scraped")

# calculate the overlap between the scientific names and common names
scrape_common_bird <- full_join(species_hummingbird, hummingbird_new, by = "EID")

# rename column
scrape_common_bird <- scrape_common_bird %>%
  rename("scraped" = "type.x") %>%
  rename("common" = "type.y")

# assign TRUE/FALSE according to overlap
scrape_common_bird$scraped <- !is.na(scrape_common_bird$scraped)
scrape_common_bird$common <- !is.na(scrape_common_bird$common)

# change TREU/FALSE to values for overlap
scrape_common_bird$type_1[scrape_common_bird$scraped == TRUE & scrape_common_bird$common == TRUE] <- 1
scrape_common_bird$type_1[scrape_common_bird$scraped == TRUE & scrape_common_bird$common == FALSE] <- 2
scrape_common_bird$type_1[scrape_common_bird$scraped == FALSE & scrape_common_bird$common == TRUE] <- 3

# plot across two panels
Hummingbird <- scrape_common_bird %>%
  mutate(type_1 = factor(type_1, levels = c(3, 2, 1))) %>%
  ggplot() +
  geom_bar(aes(x = 1, fill = type_1), stat = "count", position = "stack", colour = "black") +
  scale_fill_manual("Taxonomic name", 
                    label = c("Common only","Latin only", "Latin and Common"),
                    values = c("red", "orange", "grey")) +
  guides(fill = FALSE) +
  theme_bw() +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 800)) +
  xlab("Hummingbirds") +
  ylab("Abstract count") +
  theme(axis.ticks.x = element_blank(), axis.text.x = element_blank())


# strings to check for fig wasps 
fig_strings <- c("fig wasp", "Fig wasp", "fig-wasp", "Agaonidae")

# run function to count number of strings and then just take the EID
fig <- count_bees(abstracts, fig_strings)

fig_new <- fig %>% mutate(type = "common") %>% select(-bee_strings.j.) %>% rename("EID" = "download.EID.i.") %>% unique()

# subset the main scrape to find any abstracts that mention scientific name for fig wasps
species_fig <- species_scraped %>% dplyr::filter(taxa_data.family.i. == "Agaonidae") %>% dplyr::select(EID) %>% unique() %>% mutate(type = "scraped")

# calculate the overlap between the scientific names and common names
scrape_common_fig <- full_join(species_fig, fig_new, by = "EID")

# rename column
scrape_common_fig <- scrape_common_fig %>%
  rename("scraped" = "type.x") %>%
  rename("common" = "type.y")

# assign TRUE/FALSE according to overlap
scrape_common_fig$scraped <- !is.na(scrape_common_fig$scraped)
scrape_common_fig$common <- !is.na(scrape_common_fig$common)

# change TREU/FALSE to values for overlap
scrape_common_fig$type_1[scrape_common_fig$scraped == TRUE & scrape_common_fig$common == TRUE] <- 1
scrape_common_fig$type_1[scrape_common_fig$scraped == TRUE & scrape_common_fig$common == FALSE] <- 2
scrape_common_fig$type_1[scrape_common_fig$scraped == FALSE & scrape_common_fig$common == TRUE] <- 3

# plot across two panels
Fig <- scrape_common_fig %>%
  mutate(type_1 = factor(type_1, levels = c(3, 2, 1))) %>%
  ggplot() +
  geom_bar(aes(x = 1, fill = type_1), stat = "count", position = "stack", colour = "black") +
  scale_fill_manual("Taxonomic name", 
                    label = c("Family name only","Latin binomial only", "Latin binomial and family name "),
                    values = c("red", "orange", "grey")) +
  guides(fill = FALSE) +
  theme_bw() +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 800)) +
  xlab("Fig wasps") +
  theme(axis.ticks.x = element_blank(), axis.text.x = element_blank(), axis.text.y = element_blank(), axis.title.y = element_blank(), axis.ticks.y = element_blank())

# strings to check for hoverflies
fly_strings <- c("Hoverfly", "hoverflies", "hoverfly", "Syrphidae")

# run function to count number of strings and then just take the EID
fly <- count_bees(abstracts, fly_strings)

fly_new <- fly %>% mutate(type = "common") %>% select(-bee_strings.j.) %>% rename("EID" = "download.EID.i.") %>% unique()

# subset the main scrape to find any abstracts that mention scientific name for hoverflies
species_fly <- species_scraped %>% dplyr::filter(taxa_data.family.i. == "Syrphidae") %>% dplyr::select(EID) %>% unique() %>% mutate(type = "scraped")

# calculate the overlap between the scientific names and common names
scrape_common_fly <- full_join(species_fly, fly_new, by = "EID")

# rename column
scrape_common_fly <- scrape_common_fly %>%
  rename("scraped" = "type.x") %>%
  rename("common" = "type.y")

# assign TRUE/FALSE according to overlap
scrape_common_fly$scraped <- !is.na(scrape_common_fly$scraped)
scrape_common_fly$common <- !is.na(scrape_common_fly$common)

# change TREU/FALSE to values for overlap
scrape_common_fly$type_1[scrape_common_fly$scraped == TRUE & scrape_common_fly$common == TRUE] <- 1
scrape_common_fly$type_1[scrape_common_fly$scraped == TRUE & scrape_common_fly$common == FALSE] <- 2
scrape_common_fly$type_1[scrape_common_fly$scraped == FALSE & scrape_common_fly$common == TRUE] <- 3

# plot across two panels
Fly <- scrape_common_fly %>%
  mutate(type_1 = factor(type_1, levels = c(3, 2, 1))) %>%
  ggplot() +
  geom_bar(aes(x = 1, fill = type_1), stat = "count", position = "stack", colour = "black") +
  scale_fill_manual("Taxonomic name", 
                    label = c("Family name only","Latin binomial only", "Latin binomial and family name "),
                    values = c("red", "orange", "grey")) +
  guides(fill = FALSE) +
  theme_bw() +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 800)) +
  xlab("Hoverflies") +
  theme(axis.ticks.x = element_blank(), axis.text.x = element_blank(), axis.text.y = element_blank(), axis.title.y = element_blank(), axis.ticks.y = element_blank())

# strings to check for lead-nosed bats
bat_strings <- c("Phyllostomidae", "leaf-nosed bat", "leaf nosed bat", "Leaf-nosed bat")

# run function to count number of strings and then just take the EID
bat <- count_bees(abstracts, bat_strings)

bat_new <- bat %>% mutate(type = "common") %>% select(-bee_strings.j.) %>% rename("EID" = "download.EID.i.") %>% unique()

# subset the main scrape to find any abstracts that mention scientific name for leaf-nosed bats
species_bat <- species_scraped %>% dplyr::filter(taxa_data.family.i. == "Phyllostomidae") %>% dplyr::select(EID) %>% unique() %>% mutate(type = "scraped")

# calculate the overlap between the scientific names and common names
scrape_common_bat <- full_join(species_bat, bat_new, by = "EID")

# rename column
scrape_common_bat <- scrape_common_bat %>%
  rename("scraped" = "type.x") %>%
  rename("common" = "type.y")

# assign TRUE/FALSE according to overlap
scrape_common_bat$scraped <- !is.na(scrape_common_bat$scraped)
scrape_common_bat$common <- !is.na(scrape_common_bat$common)

# change TREU/FALSE to values for overlap
scrape_common_bat$type_1[scrape_common_bat$scraped == TRUE & scrape_common_bat$common == TRUE] <- 1
scrape_common_bat$type_1[scrape_common_bat$scraped == TRUE & scrape_common_bat$common == FALSE] <- 2
scrape_common_bat$type_1[scrape_common_bat$scraped == FALSE & scrape_common_bat$common == TRUE] <- 3

# plot across two panels
Bat <- scrape_common_bat %>%
  mutate(type_1 = factor(type_1, levels = c(3, 2, 1))) %>%
  ggplot() +
  geom_bar(aes(x = 1, fill = type_1), stat = "count", position = "stack", colour = "black") +
  scale_fill_manual("Taxonomic name", 
                    label = c("Family name only","Latin binomial only", "Latin binomial and family name "),
                    values = c("red", "orange", "grey")) +
  theme_bw() +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 800)) +
  xlab("Leaf-nosed bats") +
  theme(axis.ticks.x = element_blank(), axis.text.x = element_blank(), axis.text.y = element_blank(), axis.title.y = element_blank(), axis.ticks.y = element_blank())

# create the multiplot and save
Hummingbird + Fig + Fly + Moth + Bat + plot_layout(ncol = 5)

ggsave("family_name_validation_2.png", scale = 1, dpi = 350)
