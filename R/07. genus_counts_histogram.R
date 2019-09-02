## script for plotting genus counts as histogram

# vector for the packages to install 
packages <- c("dplyr", "ggplot2", "forcats", "stringr", "patchwork")

# packages
library(dplyr)
library(ggplot2)
library(forcats)
library(stringr)
library(patchwork)

# read in genus counts - unfiltered (some with no geographic mentions for that paper)
genus_counts <- read.csv("outputs/05. genus_aggregations.csv", stringsAsFactors=FALSE)

# read in the raw scraped data
order_counts <- read.csv("outputs/02. post_COL_species_scrape.csv", stringsAsFactors=FALSE)

# get unique species_scraped titles
species_EID <- order_counts %>% 
  dplyr::filter(!duplicated(Title)) %>%
  dplyr::select(EID) %>%
  unique()

# subset orders for those not duplicated
order_counts <- order_counts %>%
  dplyr::filter(EID %in% species_EID$EID)

# calculate total number of studies
genus_counts$total <- sum(genus_counts$DOI_count)

# calculate percent of studies
genus_counts$percent <- (genus_counts$DOI_count / genus_counts$total) * 100

# build bar plot for genus proportions
proportion_bar <- genus_counts %>% 
  filter(DOI_count > 40) %>%
  summarise(aggregated.scientific_name.i. = "Other",
            DOI_count = genus_counts$total[1] - sum(DOI_count)) %>%
  bind_rows(filter(genus_counts, DOI_count > 40)) %>%
  mutate(aggregated.scientific_name.i. = fct_reorder(aggregated.scientific_name.i., -percent),
         aggregated.scientific_name.i. = fct_relevel(aggregated.scientific_name.i., "Other", after = Inf))

# remove those from other with greater than or equal to 40 studies
proportion_other <- genus_counts %>% 
  filter(DOI_count <= 40)

# assign these names all as other for scientific name
proportion_other$aggregated.scientific_name.i. <- "Other"

# order them by the sum of DOI for each order
proportion_other$unique_order <- reorder(proportion_other$unique_order, proportion_other$DOI_count, sum)

# identify those in other mentioned less than 80 times
proportion_smallest_other <- proportion_other %>%
  group_by(unique_order) %>%
  summarise(total = sum(DOI_count)) %>%
  filter(total < 80) %>%
  ungroup()

# convert to character and collapse all the small genera
proportion_smallest <- as.character(proportion_smallest_other$unique_order)
proportion_other$unique_order <- fct_collapse(proportion_other$unique_order, Other = proportion_smallest)

# colour palette for the plot
colour_palette <- c("#009E73", "#999999" , "#56B4E9", "#E69F00", "#F0E442", "#0072B2",  "#CC79A7","#D55E00", "black")

##### breakdown of genus_counts into seperate orders

# remove all columns bar the EID and order, and then unique
order_counts <- order_counts %>%
  dplyr::select(EID, taxa_data.order.i.) %>%
  group_by(EID) %>%
  unique() %>%
  ungroup()

# count number of each factor
order_no <- order_counts %>%
  group_by(taxa_data.order.i.) %>%
  tally() %>%
  ungroup()

# how many orders are there? - 63 - 8 = 55
number_orders <- order_no %>% group_by(taxa_data.order.i.) %>% tally()

# select the main orders
main_orders <- c("Hymenoptera", "Lepidoptera", "Diptera", "Apodiformes", "Passeriformes", "Chiroptera", "Coleoptera", "Hemiptera")

# collapse everything else into a single other group
order_counts$taxa_data.order.i. <- order_counts$taxa_data.order.i.  %>% fct_collapse(Other = order_counts$taxa_data.order.i.[!order_counts$taxa_data.order.i. %in% main_orders])

# order the factors by size
order_counts$taxa_data.order.i. <- factor(order_counts$taxa_data.order.i., levels = c("Hymenoptera", "Lepidoptera", "Diptera", "Apodiformes", "Chiroptera", "Passeriformes", "Coleoptera", "Hemiptera", "Other"))

##### draw bar plot for genera breakdown with subplot
genera_sub <- ggplotGrob(ggplot() +
                           geom_bar(aes(x = aggregated.scientific_name.i., y = DOI_count, fill = unique_order), stat = "identity", data = proportion_bar) + 
                           geom_bar(aes(x = aggregated.scientific_name.i., y = DOI_count, fill = unique_order), stat = "identity", data = proportion_other, na.rm = TRUE) +
                           ylab("Study number") +
                           xlab("") +
                           ylab("") +
                           theme_bw() +
                           guides(fill = FALSE) +
                           scale_y_continuous(limits = c(0, 3250), expand = c(0, 0)) +
                           scale_x_discrete(labels = c(expression(italic("Apis")), expression(italic("Bombus")), expression(italic("Osmia")), expression(italic("Megachile")), expression(italic("Xylocopa")), expression(italic("Andrena")), expression(italic("Melipona")), expression(italic("Manduca")), expression(italic("Trigona")), expression(italic("Centris")), expression(italic("Ceratosolen")), expression(italic("Glossophaga")), expression(italic("Lasioglossum")), "Other genera")) +
                           scale_fill_manual(name = "Taxonomic orders", values = colour_palette,  na.value = "grey") +
                           theme(panel.grid = element_blank(), panel.background = element_rect(), text = element_text(size = 10), axis.text.x = element_text(angle = 45, hjust = 1)))

# subplot for all order breakdown
ggplot(order_counts) +
  geom_bar(aes(x = taxa_data.order.i., fill = taxa_data.order.i.), stat = "count") +
  theme_bw() +
  scale_fill_manual(name = "Taxonomic orders", values = c("#0072B2", "#CC79A7", "#E69F00", "#009E73", "#999999", "black",  "#56B4E9", "#F0E442", "#D55E00") , breaks = c("Hymenoptera", "Lepidoptera", "Diptera", "Apodiformes", "Chiroptera", "Passeriformes", "Coleoptera", "Hemiptera", "Other")) +
  scale_y_continuous(limits = c(0, 4000), expand = c(0, 0)) +
  ylab("Study number") +
  xlab("") +
  theme(panel.grid = element_blank(), axis.text.x = element_blank(), axis.ticks.x = element_blank(), text = element_text(size = 13)) +
  annotation_custom(
    grob = genera_sub,
    xmin = 3, xmax = 9, ymin = 1400, ymax = 3600)

# save the plot - genus
ggsave("abstract_geoparse_genus-proportion-14.png", dpi = 380, scale = 1.2)

## supplmentary info genera breakdown plots

###### main plot for Hymenoptera
genus_counts_hym <- genus_counts %>%
  filter(unique_order == "Hymenoptera") %>%
  filter(DOI_count >= 10) %>%
  filter(!aggregated.scientific_name.i. %in% c("Apis", "Bombus"))

# reorder each by size
genus_counts_hym$aggregated.scientific_name.i. <-
  fct_reorder(genus_counts_hym$aggregated.scientific_name.i., genus_counts_hym$DOI_count, .desc = TRUE)

## plot for the Hymeoptera
hym <- ggplot(genus_counts_hym) +
  geom_bar(aes(x = aggregated.scientific_name.i., y = DOI_count), fill = "#0072B2", stat = "identity") +
  theme_bw() +
  ylab("Study number") +
  xlab("") +
  facet_wrap(~unique_order) +
  scale_fill_discrete(name = "Taxonomic family") +
  scale_y_continuous(limits = c(0, 150), expand = c(0, 0)) +
  theme(panel.grid.major.x = element_blank(), 
        panel.background = element_rect(), 
        text = element_text(size = 12), 
        axis.text.x = element_text(angle = 45, hjust = 1))

########## supplementary figures - breakdown of the top 3 genera, plus other for each order
# select the main orders
main_ord_sep <- c("Lepidoptera", "Diptera", "Apodiformes", "Passeriformes", "Chiroptera", "Coleoptera", "Hemiptera")

genus_count_sep <- genus_counts

# collapse everything else into a single other group
genus_count_sep$unique_order <- genus_count_sep$unique_order  %>% fct_collapse(Other = genus_count_sep$unique_order[!genus_count_sep$unique_order %in% main_ord_sep])

# order the factors by size
genus_count_sep$unique_order <- factor(genus_count_sep$unique_order, levels = c("Lepidoptera", "Diptera", "Apodiformes", "Chiroptera", "Passeriformes", "Coleoptera", "Hemiptera", "Other"))

# filter out all "other" orders
genus_count_sep <- genus_count_sep %>%
  filter(unique_order != "Other") %>%
  filter(!unique_order %in% c("Hemiptera", "Hymenoptera")) %>%
  group_by(unique_order) %>%
  mutate(total = sum(DOI_count))

genus_sep_filt <- genus_count_sep %>%
  group_by(unique_order) %>%
  filter(DOI_count >= 6) %>%
  summarise(aggregated.scientific_name.i. = "Other",
            DOI_count = genus_count_sep$total[1] - sum(DOI_count)) %>%
  bind_rows(filter(genus_count_sep, DOI_count > 6)) %>%
  mutate(aggregated.scientific_name.i. = fct_reorder(aggregated.scientific_name.i., -total),
         aggregated.scientific_name.i. = fct_relevel(aggregated.scientific_name.i., "Other", after = Inf))

# reorder each by size
genus_sep_filt$aggregated.scientific_name.i. <-
  fct_reorder(genus_sep_filt$aggregated.scientific_name.i., genus_sep_filt$DOI_count, .desc = TRUE)

## filter our other if required
genus_sep_filt <- genus_sep_filt %>%
  filter(aggregated.scientific_name.i. != "Other")

other_filt <- ggplot(genus_sep_filt) +
  geom_bar(aes(x = aggregated.scientific_name.i., y = DOI_count, fill = unique_order), stat = "identity") +
  facet_wrap(~unique_order, ncol = 3, scales = "free_x") +
  xlab("") +
  ylab("") +
  theme_bw() +
  guides(fill = FALSE) +
  scale_y_continuous(limits = c(0, 50), expand = c(0, 0), breaks = c(0, 20, 40)) +
  scale_fill_manual(name = "Taxonomic orders", values = c("#CC79A7", "#E69F00", "#009E73", "#999999", "black",  "#56B4E9", "#F0E442", "#D55E00"),  na.value = "grey") +
  theme(panel.grid.major.x = element_blank(), 
        panel.grid.minor.y = element_blank(), 
        panel.background = element_rect(), 
        text = element_text(size = 12), 
        axis.text.x = element_text(angle = 45, hjust = 1))

hym + other_filt + plot_layout(ncol = 1)

ggsave("Taxonomic_order_breakdown-supplementary_3.png", dpi = 350, scale = 1.4)