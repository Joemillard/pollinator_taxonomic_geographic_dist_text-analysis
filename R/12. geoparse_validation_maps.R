## script for validation of geoparse locations against manual scrape of 100 abstracts

# vector for packages to install 
packages <- c("dplyr", "ggplot2", "rworldmap", "rworldxtra")

## packages
library(ggplot2)
library(dplyr)
library(rworldmap)
library(rworldxtra)

# source the functions R script
source("~/PhD/Aims/Aim 1 - collate pollinator knowledge/pollinator_taxonomic_geographic_dist_text-analysis/R/00. functions.R")

# read in the mistakes for geoparser and put into one column
geoparse_check <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Outputs/scrape_abs/cleaned/for_geoparse/Post_geoparse/checking_geoparsed/geoparse_check.csv", stringsAsFactors=FALSE)

# read in the manually geoparsed file
manual_geoparse <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Outputs/scrape_abs/cleaned/validation/100-abstracts_pollination-relatedness-check_geographic-location-edit.csv", stringsAsFactors=FALSE)

# read in the automatically geoparsed file
auto_geoparse <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Outputs/scrape_abs/cleaned/for_geoparse/Post_geoparse/03-geoparsed-abstracts_level-1-2-cleaned.csv", stringsAsFactors=FALSE)

# run for to remove the oddities and continental mentions
auto_geoparse <- form_geoparse(data = auto_geoparse, foc = c("major", "minor"), continents = unique(geoparse_check$Continent.ocean), oddities = geoparse_check$Oddities, code_out = "IQ")

# get the EIDs of manual geoparse
unique_EIDs <- unique(manual_geoparse$EID)

# subset the geoparsed abstracts for those that were manually geoparsed
auto_geoparse_filt <- auto_geoparse %>%
  filter(EID %in% unique_EIDs) %>%
  select(lat, lon, name, EID) %>%
  rename(long = lon) %>%
  group_by(EID) %>% 
  unique() %>% 
  ungroup() %>%
  mutate(type = "Automatic") %>%
  filter(lat != "NA")

# format the manual_geoparse
manual_geoparse_filt <- manual_geoparse %>%
  select(lat, long, Geocoded, EID) %>%
  rename(name = Geocoded) %>%
  group_by(EID) %>% 
  unique() %>% 
  ungroup() %>%
  mutate(type = "Manual") %>%
  filter(lat != "NA")

# bind the manual and automatic together
bound_geodata <- rbind(auto_geoparse_filt, manual_geoparse_filt)

# build map
base_map <- get_basemap()

# fortify the main map
map_fort <- fortify(base_map)

## build the plot - two facets for automatic and manual
geoparse_valid <- ggplot() + 
  geom_polygon(aes(x = long, y = lat, group = group), 
               data = map_fort, fill = "lightgrey") +
  geom_point(aes(x = long, y = lat), 
             data = bound_geodata) +
  facet_wrap(~type) +
  scale_size_area(name = "Mentions") +
  scale_colour_discrete(name = "Extraction method") +
  coord_map(projection = "mollweide") +
  theme(axis.text = element_blank(), 
        axis.ticks = element_blank(), 
        axis.title = element_blank(),
        axis.line = element_blank(),
        panel.background = element_rect(fill = "white"))

ggsave("geoparse_validation_auto-manual-02.png", scale = 1.3, dpi = 350)
