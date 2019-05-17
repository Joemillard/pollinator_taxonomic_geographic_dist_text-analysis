# check the frequency of honey bee and bumblebee relative to scientific names

# packages
library(dplyr)
library(data.table)
library(stringr)
library(ggplot2)
library(forcats)

# source the functions R script
source("~/PhD/Aims/Aim 1 - collate pollinator knowledge/pollinator_taxonomic_geographic_dist_text-analysis/R/00. functions.R")

# read in the species scraped data
species_scraped <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Outputs/scrape_abs/cleaned/07_30644_abs_EID_Year_Title_paper-approach_cleaned.csv", stringsAsFactors = FALSE)

# read in the abstracts
abstracts <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Outputs/scrape_abs/cleaned/for_geoparse/03_animal-species_abs_1-2-cleaned-for-geoparse.csv", stringsAsFactors = FALSE)

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

bees <- bees %>% mutate(type = "common") %>% select(-bee_strings.j.) %>% rename("EID" = "download.EID.i.")

# shorten the scientific name string to just bombus
genera_scraped <-  speciesify(species_scraped, 1, 1)

# subset the main scrape to find any abstracts that mention scientific name for bombus and Apis
species_bombus <- genera_scraped %>% dplyr::filter(scientific_name =="Bombus") %>% dplyr::select(EID) %>% unique() %>% mutate(type = "scraped")

# calculate the overlap between the scientific names and common names
scrape_common <- full_join(species_bombus, bees, by = "EID")

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
scrape_panel_2 <- scrape_common %>% dplyr::filter(type_1 == 1) %>% mutate(panel = 2)

scrape_common$panel[scrape_common$type_1 == 2] <- 2
scrape_common$panel[scrape_common$type_1 == 1] <- 1
scrape_common$panel[scrape_common$type_1 == 3] <- 1
scrape_common <- rbind(scrape_panel_2, scrape_common)

# filter for panel 1 and 2 and order scrape_common and add x/y columns
scrape_common_1 <- scrape_common %>% dplyr::filter(panel == 1)
scrape_common_1 <- scrape_common_1[order(scrape_common_1$type_1),] 
scrape_common_2 <- scrape_common %>% dplyr::filter(panel == 2)
scrape_common_2 <- scrape_common_2[order(scrape_common_2$type_1),] 

# order scrape_common and add x/y columns
scrape_common_1$x <- rep(1:16, 42)[1:661]
scrape_common_1$y <- rep(1:53, each = 16)[1:661]
scrape_common_2$x <- rep(1:16, 42)[1:745]
scrape_common_2$y <- rep(1:53, each = 16)[1:745]

# bind together two scrape dataframes
bound_scrape <- rbind(scrape_common_1, scrape_common_2)

bound_scrape %>%
  mutate(type_1 = factor(type_1, levels = c(2, 3, 1))) %>%
  mutate(panel = factor(panel, levels = c(2, 1), labels = c("Latin binomial", "Common name"))) %>%
    ggplot() +
      geom_tile(aes(x = x, y = y, fill = type_1), colour = "black", size = 0.6) +
      facet_wrap(~panel) +
      scale_fill_manual("Taxonomic name", 
                          label = c("Latin binomial only", "Common name only", "Binomial and Common"),
                          values = c("red", "orange", "white")) +
      theme(panel.background = element_blank(), 
            panel.grid = element_blank(), 
            axis.title = element_blank(), 
            axis.text = element_blank(),
            axis.ticks = element_blank())

ggsave("bombus_name_abstracts_2.png", scale = 1.1, dpi = 350)

