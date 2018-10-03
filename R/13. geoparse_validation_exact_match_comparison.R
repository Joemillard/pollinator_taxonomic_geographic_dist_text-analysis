### counting the number of times each string appears, as an estimate of accuracy of the geoparser

## packages
library(dplyr)
library(data.table)
library(ggplot2)
library(forcats)
library(rworldmap)
library(rworldxtra)
library(raster)
library(patchwork)

# source the functions R script
source("~/PhD/Aims/Aim 1 - collate pollinator knowledge/pollinator_taxonomic_geographic_dist_text-analysis/R/functions.R")

# read in countries adn extract string
countries <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Data/ISO-3166-Countries-with-Regional-Codes-master/all/all.csv", header = TRUE, stringsAsFactors = FALSE)

# read in the abstracts
abstracts <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Outputs/scrape_abs/cleaned/for_geoparse/03_animal-species_abs_1-2-cleaned-for-geoparse.csv", stringsAsFactors = FALSE)

# read in species scrape
species_scraped <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Outputs/scrape_abs/cleaned/07_30644_abs_EID_Year_Title_paper-approach_cleaned.csv", stringsAsFactors = FALSE)

# read in the geoparsed data
geoparsed <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Outputs/scrape_abs/cleaned/for_geoparse/Post_geoparse/03-geoparsed-abstracts_level-1-2-cleaned.csv", encoding="UTF-8", stringsAsFactors = FALSE)

# read in the mistakes for geoparser and put into one column
geoparse_check <- read.csv("~/PhD/Aims/Aim 1 - collate pollinator knowledge/Outputs/scrape_abs/cleaned/for_geoparse/Post_geoparse/checking_geoparsed/geoparse_check.csv", stringsAsFactors=FALSE)

# remove duplicates
geoparsed <- geoparsed %>% dplyr::select(-X.U.FEFF.)
geoparsed <- geoparsed %>% group_by(EID) %>% unique() %>% ungroup()

# select main columns 
species_scraped <- species_scraped %>%
  dplyr::select(-original, -taxa_data.scientificNameAuthorship.i., -taxa_data...taxonID.i., -taxa_data.acceptedNameUsageID.i., -taxa_data.parentNameUsageID.i., -taxa_data.taxonomicStatus.i., -level)

# subset geoparsed for those EID in species_scrape
geoparsed <- geoparsed %>%
  dplyr::filter(EID %in% species_EID$EID)

# get unique species_scraped titles
species_EID <- species_scraped %>% 
  dplyr::filter(!duplicated(Title)) %>%
  dplyr::select(EID) %>%
  unique()

# subset geoparsed for those EID in species_scrape
abstracts <- abstracts %>%
  dplyr::filter(EID %in% species_EID$EID)

# subset countries for Europe and clean up
global_countries <- countries %>%
  mutate(name = replace(name, which(name == "United Kingdom of Great Britain and Northern Ireland"), "United Kingdom")) %>%
  mutate(name = replace(name, which(name == "Macedonia (the former Yugoslav Republic of)"), "Macedonia")) %>%
  mutate(name = replace(name, which(name == "Moldova (Republic of)"), "Moldova")) %>%
  mutate(name = replace(name, which(name == "Russian Federation"), "Russia")) %>%
  mutate(name = replace(name, which(name == "Bolivia (Plurinational State of)"), "Bolivia")) %>%
  mutate(name = replace(name, which(name == "Bonaire, Sint Eustatius and Saba"), "Bonaire")) %>%
  mutate(name = replace(name, which(name == "Cocos (Keeling) Islands"), "Cocos")) %>%
  mutate(name = replace(name, which(name == "Congo (Democratic Republic of the)"), "Congo")) %>%
  mutate(name = replace(name, which(name == "CÃ´te d'Ivoire"), "Ivory Coast")) %>%
  mutate(name = replace(name, which(name == "Falkland Islands (Malvinas)"), "Falkland Islands")) %>%
  mutate(name = replace(name, which(name == "Korea (Democratic People's Republic of)"), "North Korea")) %>%
  mutate(name = replace(name, which(name == "Korea (Republic of)"), "South Korea")) %>%
  mutate(name = replace(name, which(name == "Iran (Islamic Republic of)"), "South Korea")) %>%
  mutate(name = replace(name, which(name == "Lao People's Democratic Republic"), "Laos")) %>%
  mutate(name = replace(name, which(name == "Macedonia (the former Yugoslav Republic of)"), "Macedonia")) %>%
  mutate(name = replace(name, which(name == "Micronesia (Federated States of)"), "Micronesia")) %>%
  mutate(name = replace(name, which(name == "Moldova (Republic of)"), "Moldova")) %>%
  mutate(name = replace(name, which(name == "Venezuela (Bolivarian Republic of)"), "Venezuela")) %>%
  mutate(name = replace(name, which(name == "Tanzania, United Republic of"), "Tanzania")) %>%
  mutate(name = replace(name, which(name == "Taiwan, Province of China"), "Taiwan")) %>%
  mutate(name = replace(name, which(name == "Syrian Arab Republic"), "Syria")) %>%
  mutate(name = replace(name, which(name == "United States of America"), "United States")) %>%
  mutate(name = replace(name, which(name == "Palestine, State of"), "Palestine"))

# extract the names and convert to a string
countries_vec <- global_countries$name

# run the count_locations function
count_locations <- count_countries(abstracts, countries_vec)

# calculate tally and sum total
tallied_counts <- count_locations %>%
  group_by(countries.j.) %>%
  tally() %>%
  mutate(total = sum(n))

# build bar plot for country proportions
tallied_bar <- tallied_counts %>% 
  filter(n >= 20) %>%
  summarise(countries.j. = "Rest of the world",
            n = 1707 - sum(n)) %>%
  bind_rows(filter(tallied_counts, n > 20)) %>%
  mutate(countries.j. = fct_reorder(countries.j., -n)) %>%
  mutate(countries.j. = fct_relevel(countries.j., "Rest of the world", after = Inf))

############### run geoparse scripts

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

# build bar plot for country proportions
proportion_bar <- area_within %>% 
  filter(proportion > 0.009) %>%
  summarise(rn = "Rest of the world",
            proportion = 1 - sum(proportion)) %>%
  bind_rows(filter(area_within, proportion > 0.009)) %>%
  mutate(rn = fct_reorder(rn, -proportion)) %>%
  mutate(rn = fct_relevel(rn, "Rest of the world", after = Inf))

# sort by proportion and then calculate cumulative - to give 50%
proportion_bar <- proportion_bar[order(proportion_bar$proportion, decreasing = TRUE),]
proportion_bar$cumulative <- c(proportion_bar$proportion[1], cumsum(proportion_bar$proportion[2:length(proportion_bar$proportion)]))

# add factor for percentage
proportion_bar$half <- c(proportion_bar$proportion[1] + proportion_bar$cumulative[length(proportion_bar$cumulative)], proportion_bar$cumulative[2:length(proportion_bar$proportion)]) < 0.5

# calculate number of unique countries
unique_countries <- length(unique(area_within$rn))

# add factor for germany for cliff_clavin
proportion_bar$germany <- "NO"
proportion_bar[proportion_bar$rn =="Germany", 8] <- gsub("NO", "YES", proportion_bar[proportion_bar$rn =="Germany",  8])

# add factor for germany for character_string
tallied_bar$germany <- "NO"
tallied_bar[tallied_bar$countries.j. =="Germany", 4] <- gsub("NO", "YES", tallied_bar[tallied_bar$countries.j. =="Germany",  4])

# draw proportion bar plot
cliff_clavin <- ggplot(proportion_bar) +
  geom_bar(aes(x = rn , y = proportion, fill = germany), stat = "identity") + 
  ylab("Study proportion") +
  xlab("Country") +
  scale_y_continuous(breaks = c(0, 0.1, 0.2), expand = c(0, 0), limits = c(0, 0.3)) +
  scale_x_discrete(labels = c("United States", "Brazil", "Australia", "Canada", "China", "Mexico", "South Africa", "India", "Japan", "United Kingdom", "New Zealand", "Spain", "Argentina", "Costa Rica", "Greece", "Italy", "France", "Chile", "Israel", "Pakistan", "Thailand", "Germany", "Rest of the world")) +
  theme_bw() +
  guides(fill  = FALSE) +
  ggtitle("CLIFF-CLAVIN") +
  geom_text(x = 22, y = 0.025, label = "22nd") +
  geom_vline(aes(xintercept = 5.5, colour = "red"), linetype = "dashed") +
  scale_fill_manual(values = c("black", "red"))+
  scale_colour_discrete(name = "", label = "Midpoint") +
  theme(panel.grid = element_blank(), panel.background = element_rect(), axis.text.x = element_text(angle = 45, hjust = 1, size = 13), axis.title.x = element_blank(), axis.text.y = element_text(size = 13), axis.title.y = element_text(size = 13), legend.text = element_text(size = 13), legend.title = element_text(size = 13)) 

# draw proportion bar plot
character_string <- ggplot(tallied_bar) +
  geom_bar(aes(x = countries.j. , y = n, fill = germany), stat = "identity") + 
  ylab("Study count") +
  xlab("Country") +
  theme_bw() +
  guides(fill  = FALSE) +
  ggtitle("Character string match") +
  scale_fill_manual(values = c("black", "red"))+
  geom_text(x = 17, y = 50, label = "17th") +
  theme(panel.grid = element_blank(), panel.background = element_rect(), axis.text.x = element_text(angle = 45, hjust = 1, size = 13), axis.title.x = element_blank(), axis.text.y = element_text(size = 13), axis.title.y = element_text(size = 13), legend.text = element_text(size = 13), legend.title = element_text(size = 13)) 

cliff_clavin + character_string + plot_layout(ncol = 1)

ggsave("character_string_geoparse_validation_02.png", scale = 1.5, dpi = 350)