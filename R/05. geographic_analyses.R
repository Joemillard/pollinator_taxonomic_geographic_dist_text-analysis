## scripts for building maps and country level distribution histogram

# vector for packages to install
packages <- c("dplyr", "rworldmap", "rworldxtra", "ggplot2", "patchwork", "raster", "mapproj", "forcats", "plyr", "data.table")

# packages to read in - plyr called in for revalue to avoid package conflicts
library(dplyr)
library(rworldmap)
library(rworldxtra)
library(ggplot2)
library(data.table)
library(raster)
library(forcats)
library(stringr)
library(patchwork)
library(mapproj)

# source the functions R scripts
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

## set up the data for the first density map and country histogram
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

# run for major focus 
geoparsed_major <- form_geoparse(data = geoparsed, foc = "major", continents = unique(geoparse_check$Continent.ocean), oddities = geoparse_check$Oddities, code_out = "IQ")

# run for minor focus
geoparsed_minor <- form_geoparse(data = geoparsed, foc = "minor", continents = unique(geoparse_check$Continent.ocean), oddities = geoparse_check$Oddities, code_out = "IQ")

# build map
base_map <- get_basemap()

# fortify the main map
map_fort <- fortify(base_map)

# count points within each polygon
proportion <- count_point(map = get_basemap(), coordinates = coords(geoparsed_major))

# count proportion of global studies within each polygon
proportion$proportion <- prop_within(count = (count_point(map = get_basemap(), coordinates = coords(geoparsed_major))))

# merge polygon area, within point count, and proportion count
area_within <- inner_join(proportion, calc_area(map = get_basemap()), by = c("rn" = "ADMIN"))

# calculate number of studies per kilometre
area_within$ratio <- area_within$within_all/area_within$area

# join records to main map
within_map <- inner_join(area_within, map_fort, by = c("rn" = "id"))

# build the map - this one is log of studies per km, with minor mentions
density_map <- ggplot() + 
  geom_polygon(aes(x = long, y = lat, group = group, fill = log10(ratio)), 
               data = within_map) +
  geom_count(aes(x = lon, y = lat), 
             data = geoparsed_minor, colour = "blue", alpha = 0.4) +
  scale_fill_gradient2(low = "yellow", 
                       high = "red",
                       mid = "orange",
                       na.value = "yellow",
                       midpoint = -3.75,
                       name = expression(paste("Study density ", "(p/km" ^2, ")")),
                       space = "Lab",
                       breaks = c(-3, -4, -5, -6),
                       labels = expression(paste(" ", 1%*%10^-3), paste(" ", 1%*%10^-4), paste(" " ,1%*%10^-5), paste("", 1%*%10^-6))) +
  scale_size_area(name = "Mentions") +
  guides(fill = guide_colorbar(ticks = FALSE, order = 1)) +
  coord_map(projection = "mollweide") +
  theme(axis.text = element_blank(), 
        axis.ticks = element_blank(), 
        axis.title = element_blank(),
        axis.line = element_blank(),
        text = element_text(size = 12),
        panel.background = element_rect(fill = "white"))

# save the plot
ggsave("abstract_geoparse-major-minor_ratio_14.png", dpi = 380, scale = 1.5)

# build the map - this one is count of studies per country, with minor mentions
count_map <- ggplot() + 
  geom_polygon(aes(x = long, y = lat, group = group, fill = log10(within_all)), 
               data = within_map) +
  geom_count(aes(x = lon, y = lat), 
             data = geoparsed_minor, colour = "blue", alpha = 0.4) +
  scale_fill_gradient2(low = "yellow", 
                       high = "red",
                       mid = "orange",
                       na.value = "yellow",
                       midpoint = 1.25,
                       name = "Study count",
                       space = "Lab",
                       labels = c(1, 10, 100, 500),
                       breaks = c(0, 1, 2, 2.69897)
                       ) +
  scale_size_area(name = "Mentions") +
  guides(fill = guide_colorbar(ticks = FALSE, order = 1)) +
  coord_map(projection = "mollweide") +
  theme(axis.text = element_blank(), 
        axis.ticks = element_blank(), 
        axis.title = element_blank(),
        axis.line = element_blank(),
        text = element_text(size = 12),
        panel.background = element_rect(fill = "white"))

# save the plot
ggsave("abstract_geoparse-major-minor_count.png", dpi = 380, scale = 1.5)

## build bar plot frequencies for country proportions
proportion_bar <- area_within %>% 
  filter(proportion > 0.014) %>%
  summarise(rn = "Rest of the world",
            proportion = 1 - sum(proportion)) %>%
  bind_rows(filter(area_within, proportion > 0.015)) %>%
  mutate(rn = fct_reorder(rn, -proportion)) %>%
  mutate(rn = fct_relevel(rn, "Rest of the world", after = Inf))

# sort by proportion and then calculate cumulative - to give 50%
proportion_bar <- proportion_bar[order(proportion_bar$proportion, decreasing = TRUE),]
proportion_bar$cumulative <- c(proportion_bar$proportion[1], cumsum(proportion_bar$proportion[2:length(proportion_bar$proportion)]))

# add factor for percentage
proportion_bar$half <- c(proportion_bar$proportion[1] + proportion_bar$cumulative[length(proportion_bar$cumulative)], proportion_bar$cumulative[2:length(proportion_bar$proportion)]) < 0.5

# calculate number of unique countries
unique_countries <- length(unique(area_within$rn))

# draw proportion bar plot
ggplot(proportion_bar) +
  geom_bar(aes(x = rn , y = proportion), stat = "identity") + 
  ylab("Study proportion") +
  xlab("Country") +
  scale_y_continuous(breaks = c(0, 0.1, 0.2), expand = c(0, 0), limits = c(0, 0.3)) +
  scale_x_discrete(labels = c("United States", "Brazil", "Australia", "Canada", "China", "Mexico", "South Africa", "India", "Japan", "United Kingdom", "New Zealand", "Spain", "Argentina", "Costa Rica", "Greece", "Rest of the world")) +
  theme_bw() +
  geom_vline(aes(xintercept = 5.5, colour = "red"), linetype = "dashed") +
  scale_colour_discrete(name = "", label = "Midpoint") +
  theme(panel.grid = element_blank(), 
        panel.background = element_rect(), 
        axis.text.x = element_text(angle = 45, hjust = 1, size = 15), 
        axis.title.x = element_blank(), axis.text.y = element_text(size = 15), 
        axis.title.y = element_text(size = 15), 
        legend.text = element_text(size = 15), 
        legend.title = element_text(size = 15)) 

# save the plot
ggsave("abstract_geoparse_study-proportion-8.png", dpi = 380, scale = 1.5)

## map facetted by taxonomic group - set up the data

# run for major focus
spec_geoparsed_major <- form_geoparse(data = species_geoparsed, foc = "major", continents = unique(geoparse_check$Continent.ocean), oddities = geoparse_check$Oddities, code_out = "IQ")

# run for minor focus
spec_geoparsed_minor <- form_geoparse(data = speciesify(species_geoparsed, 1, 1), foc = "minor", continents = unique(geoparse_check$Continent.ocean), oddities = geoparse_check$Oddities, code_out = "IQ")

# remove duplicates
spec_geoparsed_minor <- spec_geoparsed_minor %>% group_by(EID) %>% unique() %>% ungroup()

# cluster together anything but top generaa
main_genera <- c("Apis", "Bombus", "Osmia", "Megachile", "Xylocopa", "Andrena", "Melipona", "Manduca", "Trigona", "Centris", "Ceratosolen", "Glossophaga")

# cluster together the factors
spec_geoparsed_minor$scientific_name <- spec_geoparsed_minor$scientific_name %>% fct_collapse(Other = spec_geoparsed_minor$scientific_name[!spec_geoparsed_minor$scientific_name %in% main_genera])

# cluster together the orders
main_orders <- c("Hymenoptera", "Lepidoptera", "Diptera", "Apodiformes", "Passeriformes", "Chiroptera", "Coleoptera", "Hemiptera")

# collapse the orders
spec_geoparsed_minor$taxa_data.order.i. <- spec_geoparsed_minor$taxa_data.order.i.  %>% fct_collapse(Other = spec_geoparsed_minor$taxa_data.order.i.[!spec_geoparsed_minor$taxa_data.order.i. %in% main_orders])

# sort the orders
spec_geoparsed_minor$taxa_data.order.i. <- factor(spec_geoparsed_minor$taxa_data.order.i., levels = c("Hymenoptera", "Lepidoptera", "Diptera", "Apodiformes", "Chiroptera", "Passeriformes", "Coleoptera", "Hemiptera", "Other"))

spec_geoparsed_minor$scientific_name <- factor(spec_geoparsed_minor$scientific_name, levels = c("Apis", "Bombus", "Osmia", "Megachile", "Xylocopa", "Andrena", "Melipona", "Manduca", "Trigona", "Centris", "Ceratosolen", "Glossophaga", "Other"))

# filter out the others
spec_geoparsed_minor <- spec_geoparsed_minor %>%
  filter(taxa_data.order.i. != "Other") %>%
  filter(!taxa_data.order.i. %in% c("Hemiptera", "Coleoptera", "Passeriformes"))

# build map
base_map <- get_basemap()

# fortify the main map
map_fort <- fortify(base_map)

# count points within each polygon
proportion <- count_point(map = get_basemap(), coordinates = coords(spec_geoparsed_major))

# count proportion of global studies within each polygon
proportion$proportion <- prop_within(count = (count_point(map = get_basemap(), coordinates = coords(spec_geoparsed_major))))

# merge polygon area, within point count, and proportion count
area_within <- inner_join(proportion, calc_area(map = get_basemap()), by = c("rn" = "ADMIN"))

# calculate number of studies per kilometre
area_within$ratio <- area_within$within_all/area_within$area

# join records to main map
within_map <- inner_join(area_within, map_fort, by = c("rn" = "id"))

# calculate count_frequency
count_freq <- count_frequency(data = spec_geoparsed_minor, x_value = -170, y_value = 40, digits = 2, filter_percent = 0.67, count_on = quo(taxa_data.class.i.))

# convert year to factor
spec_geoparsed_minor$Year <- factor(spec_geoparsed_minor$Year)

# rename the factor for simplicity
spec_geoparsed_minor$scientific_name <- plyr::revalue(spec_geoparsed_minor$scientific_name, c("Other" = "Other genera"))

# filter out the other genera and build new plot
spec_geoparsed_other <- spec_geoparsed_minor %>%
  filter(scientific_name == "Other genera")

# filter out other from the facetted plot
spec_geoparsed_minor <- spec_geoparsed_minor %>%
  filter(scientific_name != "Other genera")

## main facet for other genera - build the main map
other_map <- ggplot() + 
  geom_polygon(aes(x = long, y = lat, group = group), 
               fill = "lightgrey", data = within_map) +
  geom_count(aes(x = lon, y = lat, colour = taxa_data.order.i.), 
             data = spec_geoparsed_other, alpha = 0.5) +
  coord_map(projection = "mollweide") +
  facet_wrap(~scientific_name) +
  scale_size_area(name = "Mentions", breaks = c(5, 10, 15, 20)) +
  scale_colour_manual(name = "Taxonomic orders", values = c("#0072B2", "#CC79A7", "#E69F00","#009E73" ,"#999999", "#D55E00" ,  "black",  "#56B4E9", "#F0E442") , breaks = c("Hymenoptera", "Lepidoptera", "Diptera", "Apodiformes", "Chiroptera", "Passeriformes", "Coleoptera", "Hemiptera", "Other")) +
  theme(axis.text = element_blank(), 
        axis.ticks = element_blank(), 
        axis.title = element_blank(), 
        text = element_text(size = 12),
        panel.background = element_rect(fill = "white"), 
        legend.position = "right",
        legend.key = element_rect(colour = NA, fill = NA), 
        strip.text.x = element_text(margin = margin(0.25,0,0.25,0, "cm"), size = 12))

## Facet by key taxonomic group - build the secondary facets
# static plot
taxonomy_map <- ggplot() + 
  geom_polygon(aes(x = long, y = lat, group = group), 
               fill = "lightgrey", data = within_map) +
  geom_count(aes(x = lon, y = lat, colour = taxa_data.order.i.), 
             data = spec_geoparsed_minor, alpha = 0.5) +
  facet_wrap(~scientific_name, ncol = 4) +
  coord_map(projection = "mollweide") +
  scale_size_area(name = "Mentions", breaks = c(5, 10, 15, 20)) +
  guides(colour = FALSE) +
  scale_colour_manual(name = "Taxonomic orders", values = c("#0072B2", "#CC79A7", "#999999","#009E73" ,"#999999", "#D55E00" ,  "black",  "#56B4E9", "#F0E442") , breaks = c("Hymenoptera", "Lepidoptera", "Diptera", "Apodiformes", "Chiroptera",  "Passeriformes", "Coleoptera", "Hemiptera", "Other")) +
  theme(axis.text = element_blank(), 
        axis.ticks = element_blank(), 
        axis.title = element_blank(), 
        text = element_text(size = 12),
        panel.background = element_rect(fill = "white"), legend.position = "right",
        legend.key = element_rect(colour = NA, fill = NA), 
        strip.text.x = element_text(margin = margin(0.25,0,0.25,0, "cm"), size = 12))

# combine the plots
taxonomy_map + other_map + plot_layout(ncol = 1)

# save the plot
ggsave("abstract_geoparse-taxonomic-group_23.png", dpi = 380, scale = 1.6)
