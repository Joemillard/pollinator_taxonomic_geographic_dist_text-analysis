# pollinator_taxonomic_geographic_dist_text-analysis
Scripts for pollinator taxonomic and geographic distribution analysis

**00. functions.R** 

**01. scrape_abstracts.R**	

session info
```
R version 3.5.1 (2018-07-02)
Platform: x86_64-w64-mingw32/x64 (64-bit)
Running under: Windows >= 8 x64 (build 9200)

Matrix products: default

locale:
[1] LC_COLLATE=English_United Kingdom.1252  LC_CTYPE=English_United Kingdom.1252    LC_MONETARY=English_United Kingdom.1252
[4] LC_NUMERIC=C                            LC_TIME=English_United Kingdom.1252    

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
[1] data.table_1.11.8 taxize_0.9.4      dplyr_0.7.6      

loaded via a namespace (and not attached):
 [1] Rcpp_0.12.19     pillar_1.3.0     compiler_3.5.1   plyr_1.8.4       bindr_0.1.1      iterators_1.0.10 tools_3.5.1     
 [8] jsonlite_1.5     tibble_1.4.2     nlme_3.1-137     lattice_0.20-35  pkgconfig_2.0.2  rlang_0.2.2      foreach_1.4.4   
[15] rstudioapi_0.8   crul_0.6.0       curl_3.2         parallel_3.5.1   bindrcpp_0.2.2   stringr_1.3.1    httr_1.3.1      
[22] xml2_1.2.0       grid_3.5.1       tidyselect_0.2.4 reshape_0.8.7    glue_1.3.0       httpcode_0.2.0   R6_2.2.2        
[29] reshape2_1.4.3   purrr_0.2.5      magrittr_1.5     codetools_0.2-15 assertthat_0.2.0 bold_0.5.0       ape_5.2         
[36] stringi_1.1.7    crayon_1.3.4     zoo_1.8-4  

```

**02. clean_catologue-of-life.R**	
**03. clean_scraped_species.R**
**04. prepare_abs_for_geoparse.R**	
**05. geographic_analyses.R**
**06. aggregate_scraped_species.R**
**07. genus_counts_histogram.R**
**08. genera_change_over_time.R**
**09. randomly_sample_abstracts_validation.R**
**10. calculate_scrape_recall.R**
**11. validation_relatedness_pollination.R**	
**12. geoparse_validation_maps.R**
**13. geoparse_validation_exact_match_comparison.R**
**14. prisma_diagram.R**