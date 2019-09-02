## script for average change over time at the level of genus

# vector for the packages to install 
packages <- c("dplyr", "stringr", "reshape2", "ggplot2", "forcats", "viridis")

# packages 
library(dplyr)
library(stringr)
library(reshape2)
library(ggplot2)
library(forcats)
library(viridis)

# source the functions R script
source("R/00. functions.R")

# read in cleaned file
species_scrape <- read.csv("outputs/02. post_COL_species_scrape.csv", stringsAsFactors = FALSE)

# get unique species_scraped titles
species_EID <- species_scrape %>% 
  dplyr::filter(!duplicated(Title)) %>%
  dplyr::select(EID) %>%
  unique()

# subset geoparsed for those EID in species_scrape
species_scrape <- species_scrape %>%
  dplyr::filter(EID %in% species_EID$EID)

#### script for overall change - shows apis and bombus increasing exponentially

# run speciesify function for genus
scrape_clean <- speciesify(scraped = species_scrape, first_word = 1, last_word = 1)

# unique species rows
scrape_clean <- scrape_clean %>% 
  dplyr::rename(taxa_data...taxonID.i. = taxa_data.ï..taxonID.i.) %>%
  select(-X, -taxa_data.scientificNameAuthorship.i., -taxa_data...taxonID.i., -taxa_data.parentNameUsageID.i., -taxa_data.acceptedNameUsageID.i.) %>% 
  group_by(EID) %>% 
  unique() %>% 
  ungroup()

# convert all the result to characters
scrape_clean <- scrape_clean %>%
  mutate_all(as.character)

# cast each species name by year
year_aggregate <- dcast(scrape_clean, scientific_name ~ Year)

# calculate column means
average <- year_aggregate %>%
  select(-scientific_name) %>%
  colMeans()

# calculate column totals
sum <- year_aggregate %>%
  select(-scientific_name) %>%
  colSums()

# cast year_aggregate 
melted_all <- melt(year_aggregate)

# cast the average and convert row names to a column
melt_average <- melt(average)
melt_average$year <- row.names(melt_average)

# cast the total and convert row names to a column
melt_sum <- melt(sum)
melt_sum$year <- row.names(melt_sum)

# merge on the year column
joined_species <- inner_join(melted_all, melt_average, by = c("variable" = "year"))

# merge the sum column
joined_species <- inner_join(joined_species, melt_sum, by = c("variable" = "year"))

# adjusted each species count for the total at that year
joined_species$total_adjusted <- (joined_species$value.x / joined_species$value) * 100

# convert year to numeric
joined_species$variable <- as.numeric(joined_species$variable)

# exclude all 2018 records
joined_species <- joined_species %>%
  filter(variable != 2018)

#### run plot for apis, bombus and other change over time

# replace 0 with NA
joined_species[joined_species == 0] <- NA 

# create vector of all genera for Apis and Bombus combined
genera <- joined_species$scientific_name

# create vector minus apis and bombus for uncombined
genera <- genera[!genera %in% c("Apis", "Bombus")]

# collapse everything else into a single other group
joined_species$scientific_name <- joined_species$scientific_name  %>% fct_collapse(Other = genera)

# create 2 new dataframes for each of the other dotted lines
joined_species_2 <- joined_species

# filter for other
joined_species_apis <- joined_species_2 %>%
  filter(scientific_name == c("Other"))

# filter for bombus
joined_species_bombus <- joined_species_2 %>%
  filter(scientific_name == c("Other"))

# putting the ditted line in the Apis and Bombus facets
joined_species_apis$scientific_name <- gsub("Other", "Apis", joined_species_apis$scientific_name) 
joined_species_bombus$scientific_name <- gsub("Other", "Bombus", joined_species_bombus$scientific_name)

# relevelling for italics
levels(joined_species$scientific_name) <- c("Other" = "Other", 
                                            "Apis" = expression(paste(italic("Apis"), "")),
                                            "Bombus" = expression(paste(italic("Bombus"), ""))
                                            )

# convert apis and bombus data frame to factor and relevel for italics
joined_species_apis$scientific_name <- factor(joined_species_apis$scientific_name)
joined_species_bombus$scientific_name <- factor(joined_species_bombus$scientific_name)
levels(joined_species_apis$scientific_name) <- c("Apis" = expression(paste(italic("Apis"), "")))
levels(joined_species_bombus$scientific_name) <- c("Bombus" = expression(paste(italic("Bombus"), "")))

# reorder the facets
joined_species$scientific_name <- factor(joined_species$scientific_name, 
                                         levels = c(expression(paste(italic("Apis"), "")), 
                                         expression(paste(italic("Bombus"), "")),
                                         "Other"))

# single facet plot for apis, bombus and other genera
ggplot() + 
  geom_hex(aes(x = variable, y = value.x), alpha = 0.75, colour = "white", bins = 50, data = joined_species) +
  geom_smooth(aes(x = variable, y = value.x, colour = scientific_name), size = 1.1, method = "glm", method.args = list(family = "poisson"), na.rm = FALSE, data = joined_species, se = FALSE) +
  geom_smooth(aes(x = variable, y = value.x), colour = "red",  size = 1.1, method = "glm", linetype = "dashed", method.args = list(family = "poisson"), na.rm = FALSE, data = joined_species_apis, se = FALSE) +
  geom_smooth(aes(x = variable, y = value.x), colour = "red", size = 1.1, method = "glm", linetype = "dashed", method.args = list(family = "poisson"), na.rm = FALSE, data = joined_species_bombus, se = FALSE) +
  ylab("Annual study count") +
  facet_wrap(~scientific_name, ncol = 3, labeller = label_parsed) +
  xlab("") +
  scale_fill_viridis(name = "Count density ", breaks = c(0, 50, 100, 150), limits = c(0, 150)) +
  guides(fill = guide_colourbar(ticks = FALSE), title.position = "top") +
  scale_x_continuous(breaks = c(1960, 1970, 1980, 1990, 2000, 2010)) +
  scale_y_continuous(breaks = c(0, 20, 40, 60, 80, 100, 120, 140), limits = c(-2, 150), expand = c(0, 0.5)) +
  theme_bw() +
  scale_colour_manual(values = c("black", "black", "red"), labels = c("Apis", "Bombus", "Other"), breaks = c("Apis", "Bombus", "Other")) +
  theme(panel.grid = element_blank(), 
        legend.key.size = unit(1.5, 'lines'), 
        strip.text.x = element_text(size = 12), 
        legend.position = "bottom", 
        legend.title = element_text(size = 12, hjust = 1, vjust = 0.75),
        text = element_text(size = 15)) +
  guides(colour = FALSE) +
  guides(fill = guide_colourbar(ticks = FALSE, override.aes = list(alpha = 0.25)))

ggsave("top_10_genus_yearly-change-16.png", dpi = 400, scale = 1.2)

# overall change for pollination studies
ggplot(joined_species) + 
  geom_bar(aes(x = variable, y = value.x), stat = "identity") +
  ylab("Annual study count") + 
  scale_y_continuous(limits = c(0, 760), expand = c(0, 0)) +
  xlab("Year") +
  scale_x_continuous(breaks = c(1960, 1970, 1980, 1990, 2000, 2010)) +
  theme_bw() +
  theme(panel.grid = element_blank(),
        text = element_text(size = 14))

ggsave("overall-pollination-studies-change_03.png", dpi = 350, scale = 1.1)

# explicit model for genera change over time
change_model <- glm(value.x ~ variable + scientific_name, family = "poisson", data = joined_species)

