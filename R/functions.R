#### will need to rerun and fix for different "taxa_data$..taxonID" column names



### scrape_abs function
# scrape_abs() will scrape each abstract, 
# assign NA where no species are returned, 
# merge with DOI, 
# incrementally combine outputs, 
# and then print all as all_abstracts.
# Takes one argument, in form of Abstract object created above
scrape_abs <- function(abs, num){
  
  # create empty list for combining species lists
  datalist <- list()  
  
  # iterate scrapenames Taxize function across each abstract - 
  # will need to be changed to iterate across length of Abstract object
  for (i in 1:num) {
    
    # run tryCatch to catch any error abstracts, and print the DOI at that count
    tryCatch({
      
      # run scrapenames on each value in Abstract column
      species <- scrapenames(text = abs$Abstract[i])
      
      # if species are found, add the names and DOI to a temp dataframe, rename columns, and then add to list
      if (length(species$data > 0)){
        temp <- data.frame(species$data$scientificname, abs$DOI[i], abs$Year[i], abs$Title[i], abs$EID[i])
        colnames(temp) <- c("scientific_name", "DOI", "Year", "Title", "EID")
        datalist[[i]] <- temp
      }
      
      # if species are not found, create dataframe with NA and the DOI for that row, rename columns, and add to list
      else {
        temp_2 <- data.frame(NA, abs$DOI[i], abs$Year[i], abs$Title[i], abs$EID[i])
        colnames(temp_2) <- c("scientific_name", "DOI", "Year", "Title", "EID")
        datalist[[i]] <- temp_2
      }
      
      # print the DOI for the error at that abstract count
    }, error = function(x) print(c(i, abs$DOI[i], abs$Title[i])))
  }
  
  # combine the results of each datalist iteration and then print
  all_abstracts <- rbindlist(datalist)
  return(all_abstracts)
}

### function for removing author column from the scientific name column
species <- function(taxa_data, count){
  
  # create a list
  data <- list()  
  
  # iterate over the number of counts defined as an argument
  for (i in 1:count){
    
    # catch errors
    tryCatch({
      
      # whenever see the pattern of author in scientific name, remove it, make a dataframe from rows at that iteration, save to list
      temp <- gsub(taxa_data$scientificNameAuthorship[i], "", taxa_data$scientificName[i])
      temp_spec <- data.frame(temp, taxa_data$kingdom[i], taxa_data$class[i], taxa_data$order[i], taxa_data$scientificNameAuthorship[i], taxa_data$family[i], taxa_data$..taxonID[i], taxa_data$acceptedNameUsageID[i], taxa_data$parentNameUsageID[i], taxa_data$taxonomicStatus[i])
      data[[i]] <- temp_spec
      
      # print iteration number when error encountered
    }, error = function(x) print(c(i, taxa_data$scientificName[i])))
  }
  
  # bind the data lists and return the final bound object 
  species_names <- rbindlist(data)
  return(species_names)
}

# remerge only with those that appear in each paper
# find all the direct merges at each DOI
check_abb <- function(locations){
  
  # set up empty list objects
  loc <- unique(locations)
  abb <- list()
  direct <- list()
  joined <- list()
  new_joined <- list()
  
  # loop through list of DOIs in abb_merge, remove scientific names, and assign to abb as i element
  for (i in 1:length(loc)){
    abb_spec <- abb_merge %>% 
      filter(EID == loc[i]) %>%
      filter(!duplicated(scientific_name)) %>%
      select(scientific_name, first_word, taxa_data.kingdom.i., taxa_data.class.i., taxa_data.order.i., Year, original, taxa_data.scientificNameAuthorship.i., Title, File_loc, taxa_data.family.i., taxa_data...taxonID.i., taxa_data.acceptedNameUsageID.i., taxa_data.parentNameUsageID.i., taxa_data.taxonomicStatus.i.)
    abb[[i]] <- abb_spec
    
    # loop through list of DOIs in temp_direct, remove scientific names, and assign to abb as i element
    direct_spec <- temp_direct %>% 
      filter(EID == loc[i]) %>%
      filter(!duplicated(scientific_name)) %>%
      select(first_word)
    direct[[i]] <- direct_spec
    
    # if there are mentions in both the direct_spec and abb_spec join by first word
    if (length(direct_spec$first_word) > 0 & length(abb_spec$scientific_name) > 0) {
      
      # join abb and direct by first word
      joined <- inner_join(abb[[i]], direct[[i]], by = "first_word")
      
      # there are matches return build into dataframe
      if (length(joined$scientific_name > 0)) {
        temp_1 <- data.frame(joined, loc[i])
        #colnames(temp_1) <- c("scientific_name", "File_loc")
        new_joined[[i]] <- temp_1
      }
      
      # otherwise add NA at that row
      else {
        joined[1,] <- NA
        temp_2 <- data.frame(joined, loc[i])
        #colnames(temp_2) <- c("scientific_name", "File_loc")
        new_joined[[i]] <- temp_2
      }
    }
    
    # if there are no direct_spec or abb_spec in that DOI return row of NAs
    else {
      joined <- data.frame(scientific_name = NA, first_word = NA, taxa_data.kingdom.i. = NA, taxa_data.class.i. = NA, taxa_data.order.i. = NA, Year = NA, original = NA, taxa_data.scientificNameAuthorship.i. = NA, Title = NA, File_loc = NA, taxa_data.family.i. = NA, taxa_data...taxonID.i. = NA, taxa_data.acceptedNameUsageID.i. = NA, taxa_data.parentNameUsageID.i. = NA, taxa_data.taxonomicStatus.i. = NA)
      temp_3 <- data.frame(joined, loc[i])
      #colnames(temp_3) <- c("scientific_name", "File_loc")
      new_joined[[i]] <- temp_3
    }
  }
  
  # bind all lists and return
  fin <- rbindlist(new_joined)
  return(fin)
}

# remove string after copyright sign
remove_after_copyright <- function(abstract){
  
  data <- list()
  
  # iterate through each of the downloads abstract object
  for (i in 1:nrow(abstract)) ({
    
    # if copyright symbol in the abstract, assign a boolean
    logical_copy <- grepl("©", abstract$Abstract[i])
    
    # remove characters after the copyright symbol if it's there
    if (logical_copy == TRUE) ({
      
      # remove any characters after the copyright symbol
      abstract$Abstract[i] <- gsub("©.*","", abstract$Abstract[i])
    })
    
    data[[i]] <- data.frame(abstract$Abstract[i], abstract$EID[i])
  })
  
  cleaned <- rbindlist(data)
  return(cleaned)
}

# format geoparsed data
form_geoparse <- function(data, foc, continents, oddities, code_out){
  form <- data %>%
    dplyr::select(-confidence) %>%
    dplyr::filter(!is.na(lat)) %>%
    dplyr::filter(!name %in% continents) %>%
    dplyr::filter(!name %in% oddities) %>%
    dplyr::filter(focus %in% foc) %>%
    dplyr::filter(!grepl(code_out, countryCode))
  
  return(form)
  
}

# extract long/lat columns from geoparsed dataframe and convert to coordinates
coords <- function(geoparsed){
  
  # extract lon/lat columns of geoparsed dataframe 
  study_coords <- data.frame("lon"= geoparsed$lon, 
                             "lat"= geoparsed$lat)
  
  # convert columns to coordinates
  study_coords <- SpatialPointsDataFrame(coords = study_coords[,1:2], 
                                         data = study_coords,
                                         proj4string = CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0"))
  
  # return the final study_coords object
  return(study_coords)
}

# set up the base map and convert coordinates
get_basemap <- function(){
  
  # download full basemap
  base_map <- getMap(resolution = "high")
  
  # convert to correction projection
  proj4string(base_map) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0")
  
  # return basemap
  return(base_map)
}

# count points within polygons
count_point <- function (map, coordinates){
  
  # find all coordinates that fall within each polygon
  within_base <- over(map, coordinates, by = "ISO2", returnList = TRUE)
  
  # count number of rows for each country name and bind together
  within_list <- lapply(within_base, NROW)
  within_all <- do.call(rbind, within_list)
  
  # turn bound country counts into dataframe, and add rows as a column
  within_frame <- data.frame(within_all)
  within_frame <- setDT(within_frame, keep.rownames = TRUE)[]
  
  return(within_frame)
}

# calculate proportion of papers within polygon
prop_within <- function(count){
  
  # run count function and assign to object
  within_polygon <- count
  
  # sum the number of studies and add to each row
  within_polygon$total <- sum(within_polygon$within_all)
  
  # calculate proportion and assign to new column of object
  within_polygon$proportion <- within_polygon$within_all/within_polygon$total
  
}

# calculate area function
calc_area <- function(map){
  
  # build map
  base_map <- map
  
  # calculate area of country polygons and add to area element
  base_map$area <- area(map) / 1000000
  
  # select columns for merging
  area <- base_map@data %>%
    dplyr::select(ADMIN, area)
  
  # return area object
  return(area)
}

count_frequency <- function(data, x_value, y_value, digits, filter_percent, count_on){
  
  # build a data frame for overall counts to input
  count_freq <- data.frame(count(data, !!count_on), x = x_value, y = y_value)
  
  # count column as a percentage
  count_freq$total <- sum(count_freq$n)
  count_freq$percentage <- round((count_freq$n / count_freq$total) * 100, digits = digits)
  
  # group factors below and including reptiles into "other"
  count_freq <- count_freq %>% 
    filter(percentage > filter_percent) %>%
    summarise(!!quo_name(count_on) := "Other",
              percentage = round(100 - sum(percentage), digits = digits), n = count_freq$total[1] - sum(n), x = x_value, y = y_value, total = count_freq$total[1]) %>%
    bind_rows(filter(count_freq, percentage > filter_percent)) %>%
    mutate(!!quo_name(count_on) := fct_reorder(!!count_on, percentage))
  
  # convert number to percentage character string
  count_freq$percentage <- paste(count_freq$percentage, "%", sep = "")
  
  return(count_freq)
}

speciesify <- function(scraped, first_word, last_word) {
  
  species <- scraped
  
  # onle keep 1st and 2nd words in species column
  species$scientific_name <- species$scientific_name %>% word(first_word, last_word)
  
  # return scraped
  return(species)
}

# remove duplicated records from each column for aggregated DOI: year, species, country, and file location
unique_row_DOI <- function(aggregated) {
  
  # create empty list
  data <- list()
  
  # loop through and for each column remove duplicates
  for(i in 1:nrow(aggregated)){
    split_spec <- unlist(strsplit(aggregated$scientific_name[i], split=", "))
    unique_spec <- paste(unique(split_spec), collapse = ", ") 
    split_year <- unlist(strsplit(aggregated$Year[i], split=", "))
    unique_year <- paste(unique(split_year), collapse = ", ") 
    split_level <- unlist(strsplit(aggregated$level[i], split=", "))
    unique_level <- paste(unique(split_level), collapse = ", ") 
    split_name <- unlist(strsplit(aggregated$name[i], split=", "))
    unique_name <- paste(unique(split_name), collapse = ", ") 
    split_class <- unlist(strsplit(aggregated$taxa_data.class.i.[i], split=", "))
    unique_class <- paste(unique(split_class), collapse = ", ") 
    data[[i]] <- data.frame(aggregated$EID[i], unique_spec, unique_name, unique_year, unique_level, unique_class)
    
  }
  
  # bind the resulting data frames and return
  aggregated_unique <- rbindlist(data)
  return(aggregated_unique)
  
}

# remove duplicated records from each column for aggregated species: year, species, country, and file location
unique_row_spec <- function(aggregated) {
  
  # create empty list
  data <- list()
  
  # loop through and for each column remove duplicates
  for(i in 1:nrow(aggregated_spec)){
    split_year <- unlist(strsplit(aggregated$Year[i], split=", "))
    unique_year <- paste(unique(split_year), collapse = ", ") 
    split_level <- unlist(strsplit(aggregated$level[i], split=", "))
    unique_level <- paste(unique(split_level), collapse = ", ") 
    split_loc <- unlist(strsplit(aggregated$EID[i], split=", "))
    unique_loc <- paste(unique(split_loc), collapse = ", ")
    split_name <- unlist(strsplit(aggregated$name[i], split=", "))
    unique_name <- paste(unique(split_name), collapse = ", ")
    split_class <- unlist(strsplit(aggregated$taxa_data.class.i.[i], split=", "))
    unique_class <- paste(unique(split_class), collapse = ", ")
    split_order <- unlist(strsplit(aggregated$taxa_data.order.i.[i], split=", "))
    unique_order <- paste(unique(split_order), collapse = ", ")
    split_family <- unlist(strsplit(aggregated$taxa_data.family.i.[i], split=", "))
    unique_family <- paste(unique(split_family), collapse = ", ")
    data[[i]] <- data.frame(aggregated$scientific_name[i], unique_year, unique_level, unique_loc, unique_name, unique_order, unique_class, unique_family)
    
  }
  
  # bind the resulting data frames and return
  aggregated_unique <- rbindlist(data)
  return(aggregated_unique)
  
}