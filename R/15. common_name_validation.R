# check the frequency of honey bee and bumblebee relative to scientific names

# packages
library(dplyr)
library(data.table)
library(stringr)
library(ggplot2)
library(forcats)
library(patchwork)

# source the functions R script
source("~/PhD/Aims/Aim 1 - collate pollinator knowledge/pollinator_taxonomic_geographic_dist_text-analysis/R/00. functions.R")

# read in the species scraped data
species_scraped <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Outputs/scrape_abs/cleaned/07_30644_abs_EID_Year_Title_paper-approach_cleaned.csv", stringsAsFactors = FALSE)

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
abstracts <- scopus_download %>%
  select(Abstract, DOI, Year, Title, EID) %>%
   rename(abstract = Abstract) %>%
  .[1:30644,]

# strings to check for 
bee_strings <- c("bumble bee", "bumblebee")

count_bees <- function(download, bee_strings){
  
  # make empty list object
  data <- list()
  
  # iterate through each of the downloads abstract object
  for (i in 1:nrow(download)) ({
    
    # iterate through each of the bees
    for (j in 1:length(bee_strings)) ({
      
      # if bee in the abstract, assign a boolean
      logical_name <- grepl(bee_strings[j], download$abstract[i])
      
      # if boolean is true build row of dataframe for that abstract
      if(logical_name == TRUE)({
        
        # build dataframe for that iteration and assign to element of a list
        data[[i*j]] <- data.frame(bee_strings[j], download$EID[i])
      })
    })
    
    print(i)
    
  })
  
  # bind all rows and return
  species_countries <- rbindlist(data)
  return(species_countries)
  
}

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

# panel number
#scrape_panel_2 <- scrape_common %>% dplyr::filter(type_1 == 1) %>% mutate(panel = 2)

#scrape_common$panel[scrape_common$type_1 == 2] <- 2
#scrape_common$panel[scrape_common$type_1 == 1] <- 1
#scrape_common$panel[scrape_common$type_1 == 3] <- 1
#scrape_common <- rbind(scrape_panel_2, scrape_common)

# plot across two panels
Bombus <- scrape_common %>%
  mutate(type_1 = factor(type_1, levels = c(3, 2, 1))) %>%
  #mutate(panel = factor(panel, levels = c(2, 1), labels = c("Latin", "Common"))) %>%
  ggplot() +
    geom_bar(aes(x = 1, fill = type_1), stat = "count", position = "stack", colour = "black") +
    #facet_grid(~panel)  +
    scale_fill_manual("Taxonomic name", 
                      label = c("Common only","Latin only", "Latin and Common"),
                      values = c("red", "orange", "grey")) +
    theme_bw() +
    guides(fill = FALSE) +
    ylim(0, 2250) +
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

# panel number
#scrape_panel_2_apis <- scrape_common_apis %>% dplyr::filter(type_1 == 1) %>% mutate(panel = 2)

#scrape_common_apis$panel[scrape_common_apis$type_1 == 2] <- 2
#scrape_common_apis$panel[scrape_common_apis$type_1 == 1] <- 1
#scrape_common_apis$panel[scrape_common_apis$type_1 == 3] <- 1
#scrape_common_apis <- rbind(scrape_panel_2_apis, scrape_common_apis)

# plot across two panels
Apis <- scrape_common_apis %>%
  mutate(type_1 = factor(type_1, levels = c(3, 2, 1))) %>%
  #mutate(panel = factor(panel, levels = c(2, 1), labels = c("Latin", "Common"))) %>%
  ggplot() +
  geom_bar(aes(x = 1, fill = type_1), stat = "count", position = "stack", colour = "black") +
  #facet_wrap(~panel)   +
  scale_fill_manual("Taxonomic name", 
                    label = c("Common only","Latin only", "Latin and Common"),
                    values = c("red", "orange", "grey")) +
  theme_bw() +
  ylim(0, 2250) +
  guides(fill = FALSE) +
  xlab("Apis") +
  ylab("Abstract count") +
  theme(axis.ticks.x = element_blank(), axis.text.x = element_blank())


# apis plot
# strings to check for 
mason_strings <- c("mason bee", "masonbee")

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

# panel number
#scrape_panel_2_mason <- scrape_common_mason %>% dplyr::filter(type_1 == 1) %>% mutate(panel = 2)

#scrape_common_mason$panel[scrape_common_mason$type_1 == 2] <- 2
#scrape_common_mason$panel[scrape_common_mason$type_1 == 1] <- 1
#scrape_common_mason$panel[scrape_common_mason$type_1 == 3] <- 1
#scrape_common_mason <- rbind(scrape_panel_2_mason, scrape_common_mason)

# plot across two panels
mason <- scrape_common_mason %>%
  mutate(type_1 = factor(type_1, levels = c(3, 2, 1))) %>%
  #mutate(panel = factor(panel, levels = c(2, 1), labels = c("Latin", "Common"))) %>%
  ggplot() +
  geom_bar(aes(x = 1, fill = type_1), stat = "count", position = "stack", colour = "black") +
  #facet_wrap(~panel)   +
  scale_fill_manual("Taxonomic name", 
                    label = c("Common only","Latin only", "Latin and Common"),
                    values = c("red", "orange", "grey")) +
  xlab("Osmia") +
  guides(fill = FALSE) +
  ylim(0, 2250) +
  theme_bw() +
  theme(axis.ticks.x = element_blank(), axis.text.x = element_blank(), axis.text.y = element_blank(), axis.title.y = element_blank(), axis.ticks.y = element_blank())

# apis plot
# strings to check for 
leafcutter_strings <- c("leafcutter bee", "leafcutting bee")

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
  #mutate(panel = factor(panel, levels = c(2, 1), labels = c("Latin", "Common"))) %>%
  ggplot() +
  geom_bar(aes(x = 1, fill = type_1), stat = "count", position = "stack", colour = "black") +
  #facet_wrap(~panel)   +
  scale_fill_manual("Taxonomic name", 
                    label = c("Common only","Latin only", "Latin and Common"),
                    values = c("red", "orange", "grey")) +
  xlab("Megachile") +
  ylim(0, 2250) +
  theme_bw() +
  theme(axis.ticks.x = element_blank(), axis.text.x = element_blank(), axis.text.y = element_blank(), axis.title.y = element_blank(), axis.ticks.y = element_blank())

Apis + Bombus + mason + leafcutter +plot_layout(nrow = 1)

ggsave("comb_latin_binomial_4.png", scale  = 1, dpi = 350)