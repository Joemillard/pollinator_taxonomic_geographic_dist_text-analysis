# Quantifying the taxonomic and geographic distribution of the animal pollination literature

This repository contains all the scripts used for the text analysis carried out in the below review:

> **Millard et al (in prep.), A novel text-mining approach to quantifying the taxonomic and geographic distribution of the animal pollination literature, and implications for the systematic review**

There are 14 R scripts and 1 Python script in this analysis:

00. functions.R
01. scrape_abstracts.R
02. clean_catologue-of-life.R
03. clean_scraped_species.R
04. prepare_abs_for_geoparse.R
05. geographic_analyses.R
06. aggregate_scraped_species.R
07. genus_counts_histogram.R
08. genera_change_over_time.R
09. randomly_sample_abstracts_validation.R
10. calculate_scrape_recall.R
11. validation_relatedness_pollination.R
12. geoparse_validation_maps.R
13. geoparse_validation_exact_match_comparison.R
14. prisma_diagram.R

## See below for brief script overviews and session info:

**00. functions.R** - all functions used as part of the analysis, sourced into R scripts for analysis where appropriate

**01. scrape_abstracts.R** - scrapes potential taxonomic records from abstracts using scrapenames() in the taxize package

Session info
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
---
**02. clean_catologue-of-life.R** - removes author information from the scientific names column for string matches in 03.

Session info
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
[1] bindrcpp_0.2.2    data.table_1.11.8 stringr_1.3.1     dplyr_0.7.6      

loaded via a namespace (and not attached):
 [1] Rcpp_0.12.19     crayon_1.3.4     assertthat_0.2.0 R6_2.2.2         magrittr_1.5     pillar_1.3.0     stringi_1.1.7   
 [8] rlang_0.2.2      rstudioapi_0.8   tools_3.5.1      glue_1.3.0       purrr_0.2.5      compiler_3.5.1   pkgconfig_2.0.2 
[15] bindr_0.1.1      tidyselect_0.2.4 tibble_1.4.2    
```
---
**03. clean_scraped_species.R** - identifies animal species records in the initial scrape using matches with the COL

Session info
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
[1] bindrcpp_0.2.2    data.table_1.11.8 stringr_1.3.1     dplyr_0.7.6      

loaded via a namespace (and not attached):
 [1] Rcpp_0.12.19     crayon_1.3.4     assertthat_0.2.0 R6_2.2.2         magrittr_1.5     pillar_1.3.0     stringi_1.1.7   
 [8] rlang_0.2.2      rstudioapi_0.8   tools_3.5.1      glue_1.3.0       purrr_0.2.5      compiler_3.5.1   pkgconfig_2.0.2 
[15] bindr_0.1.1      tidyselect_0.2.4 tibble_1.4.2
```
---
**04. prepare_abs_for_geoparse.R** - abstract csv prepared for geoparsing with CLIFF-CLAVIN

Session info
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
[1] bindrcpp_0.2.2    stringi_1.1.7     data.table_1.11.8 dplyr_0.7.6      

loaded via a namespace (and not attached):
 [1] Rcpp_0.12.19     crayon_1.3.4     assertthat_0.2.0 R6_2.2.2         magrittr_1.5     pillar_1.3.0     rlang_0.2.2     
 [8] rstudioapi_0.8   tools_3.5.1      glue_1.3.0       purrr_0.2.5      compiler_3.5.1   pkgconfig_2.0.2  bindr_0.1.1     
[15] tidyselect_0.2.4 tibble_1.4.2
```
---
**05. geographic_analyses.R** - all mapping and country distribution figures following CLIFF-CLAVIN geoparse

Session info
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
 [1] patchwork_0.0.1   plyr_1.8.4        stringr_1.3.1     forcats_0.3.0     raster_2.6-7      data.table_1.11.8
 [7] ggplot2_3.0.0     rworldxtra_1.01   rworldmap_1.3-6   sp_1.3-1          dplyr_0.7.6      

loaded via a namespace (and not attached):
 [1] Rcpp_0.12.19     pillar_1.3.0     compiler_3.5.1   bindr_0.1.1      tools_3.5.1      dotCall64_1.0-0  tibble_1.4.2    
 [8] gtable_0.2.0     lattice_0.20-35  pkgconfig_2.0.2  rlang_0.2.2      rstudioapi_0.8   spam_2.2-0       bindrcpp_0.2.2  
[15] withr_2.1.2      fields_9.6       maps_3.3.0       grid_3.5.1       tidyselect_0.2.4 glue_1.3.0       R6_2.2.2        
[22] foreign_0.8-70   purrr_0.2.5      magrittr_1.5     scales_1.0.0     maptools_0.9-4   assertthat_0.2.0 colorspace_1.3-2
[29] stringi_1.1.7    lazyeval_0.2.1   munsell_0.5.0    crayon_1.3.4
```
---
**06. aggregate_scraped_species.R** - aggregation of confirmed animal species at the level of taxonomic record and DOI

Session info
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
[1] stringr_1.3.1     data.table_1.11.8 reshape2_1.4.3    dplyr_0.7.6      

loaded via a namespace (and not attached):
 [1] Rcpp_0.12.19     crayon_1.3.4     assertthat_0.2.0 plyr_1.8.4       R6_2.2.2         magrittr_1.5     pillar_1.3.0    
 [8] stringi_1.1.7    rlang_0.2.2      rstudioapi_0.8   bindrcpp_0.2.2   tools_3.5.1      glue_1.3.0       purrr_0.2.5     
[15] compiler_3.5.1   pkgconfig_2.0.2  bindr_0.1.1      tidyselect_0.2.4 tibble_1.4.2
```
---
**07. genus_counts_histogram.R** - scripts for building genera and order level distribution for confirmed scraped animal species

Session info
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
[1] patchwork_0.0.1 stringr_1.3.1   forcats_0.3.0   ggplot2_3.0.0   dplyr_0.7.6    

loaded via a namespace (and not attached):
 [1] Rcpp_0.12.19     rstudioapi_0.8   bindr_0.1.1      magrittr_1.5     tidyselect_0.2.4 munsell_0.5.0    colorspace_1.3-2
 [8] R6_2.2.2         rlang_0.2.2      plyr_1.8.4       tools_3.5.1      grid_3.5.1       gtable_0.2.0     withr_2.1.2     
[15] lazyeval_0.2.1   assertthat_0.2.0 tibble_1.4.2     crayon_1.3.4     bindrcpp_0.2.2   purrr_0.2.5      glue_1.3.0      
[22] stringi_1.1.7    compiler_3.5.1   pillar_1.3.0     scales_1.0.0     pkgconfig_2.0.2
```
---
**08. genera_change_over_time.R** - scripts for quantifying change over time for Apis, Bombus, and all other genera

Session info
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
[1] viridis_0.5.1     viridisLite_0.3.0 forcats_0.3.0     ggplot2_3.0.0     reshape2_1.4.3    stringr_1.3.1     dplyr_0.7.6      

loaded via a namespace (and not attached):
 [1] Rcpp_0.12.19     rstudioapi_0.8   bindr_0.1.1      magrittr_1.5     tidyselect_0.2.4 munsell_0.5.0    colorspace_1.3-2
 [8] R6_2.2.2         rlang_0.2.2      plyr_1.8.4       tools_3.5.1      grid_3.5.1       gtable_0.2.0     withr_2.1.2     
[15] lazyeval_0.2.1   assertthat_0.2.0 tibble_1.4.2     crayon_1.3.4     bindrcpp_0.2.2   gridExtra_2.3    purrr_0.2.5     
[22] glue_1.3.0       stringi_1.1.7    compiler_3.5.1   pillar_1.3.0     scales_1.0.0     pkgconfig_2.0.2
```
---
**09. randomly_sample_abstracts_validation.R** - randomly sample abstracts for validation

Session info
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
[1] dplyr_0.7.6

loaded via a namespace (and not attached):
 [1] Rcpp_0.12.19     crayon_1.3.4     assertthat_0.2.0 R6_2.2.2         magrittr_1.5     pillar_1.3.0     rlang_0.2.2     
 [8] rstudioapi_0.8   bindrcpp_0.2.2   tools_3.5.1      glue_1.3.0       purrr_0.2.5      compiler_3.5.1   pkgconfig_2.0.2 
[15] bindr_0.1.1      tidyselect_0.2.4 tibble_1.4.2    
```
---
**10. calculate_scrape_recall.R** - scripts for comparing manual scrape of abstracts for taxonomic records with the programmatic approach

Session info
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
[1] stringr_1.3.1 dplyr_0.7.6  

loaded via a namespace (and not attached):
 [1] Rcpp_0.12.19     crayon_1.3.4     assertthat_0.2.0 R6_2.2.2         magrittr_1.5     pillar_1.3.0     stringi_1.1.7   
 [8] rlang_0.2.2      rstudioapi_0.8   bindrcpp_0.2.2   tools_3.5.1      glue_1.3.0       purrr_0.2.5      compiler_3.5.1  
[15] pkgconfig_2.0.2  bindr_0.1.1      tidyselect_0.2.4 tibble_1.4.2
```
---
**11. validation_relatedness_pollination.R** - script for constructing relatedness to polliantion figures

Session info
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
[1] patchwork_0.0.1 ggplot2_3.0.0   dplyr_0.7.6    

loaded via a namespace (and not attached):
 [1] Rcpp_0.12.19     rstudioapi_0.8   bindr_0.1.1      magrittr_1.5     tidyselect_0.2.4 munsell_0.5.0    colorspace_1.3-2
 [8] R6_2.2.2         rlang_0.2.2      plyr_1.8.4       tools_3.5.1      grid_3.5.1       gtable_0.2.0     withr_2.1.2     
[15] lazyeval_0.2.1   assertthat_0.2.0 tibble_1.4.2     crayon_1.3.4     bindrcpp_0.2.2   purrr_0.2.5      glue_1.3.0      
[22] compiler_3.5.1   pillar_1.3.0     scales_1.0.0     pkgconfig_2.0.2
```
---
**12. geoparse_validation_maps.R** - script for constructing geoparse automated/manual validation map figure

Session info
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
[1] rworldxtra_1.01 rworldmap_1.3-6 sp_1.3-1        dplyr_0.7.6     ggplot2_3.0.0  

loaded via a namespace (and not attached):
 [1] Rcpp_0.12.19     rstudioapi_0.8   bindr_0.1.1      magrittr_1.5     maptools_0.9-4   maps_3.3.0       tidyselect_0.2.4
 [8] munsell_0.5.0    colorspace_1.3-2 lattice_0.20-35  R6_2.2.2         rlang_0.2.2      plyr_1.8.4       fields_9.6      
[15] tools_3.5.1      dotCall64_1.0-0  grid_3.5.1       spam_2.2-0       gtable_0.2.0     withr_2.1.2      lazyeval_0.2.1  
[22] assertthat_0.2.0 tibble_1.4.2     crayon_1.3.4     bindrcpp_0.2.2   purrr_0.2.5      glue_1.3.0       compiler_3.5.1  
[29] pillar_1.3.0     scales_1.0.0     foreign_0.8-70   pkgconfig_2.0.2
```
---
**13. geoparse_validation_exact_match_comparison.R** - script for building figure to compare CLIFF-CLAVIN with character string matches

Session info
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
[1] patchwork_0.0.1   raster_2.6-7      rworldxtra_1.01   rworldmap_1.3-6   sp_1.3-1          forcats_0.3.0     ggplot2_3.0.0    
[8] data.table_1.11.8 dplyr_0.7.6      

loaded via a namespace (and not attached):
 [1] Rcpp_0.12.19     pillar_1.3.0     compiler_3.5.1   plyr_1.8.4       bindr_0.1.1      tools_3.5.1      dotCall64_1.0-0 
 [8] tibble_1.4.2     gtable_0.2.0     lattice_0.20-35  pkgconfig_2.0.2  rlang_0.2.2      rstudioapi_0.8   spam_2.2-0      
[15] bindrcpp_0.2.2   withr_2.1.2      fields_9.6       maps_3.3.0       grid_3.5.1       tidyselect_0.2.4 glue_1.3.0      
[22] R6_2.2.2         foreign_0.8-70   purrr_0.2.5      magrittr_1.5     scales_1.0.0     maptools_0.9-4   assertthat_0.2.0
[29] colorspace_1.3-2 lazyeval_0.2.1   munsell_0.5.0    crayon_1.3.4
```
---
**14. prisma_diagram.R** - script for building PRISMA diagram of paper, species, genera, and order number

Session info
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
[1] bindrcpp_0.2.2    stringr_1.3.1     dplyr_0.7.6       rsvg_1.3          DiagrammeRsvg_0.1 DiagrammeR_1.0.0 

loaded via a namespace (and not attached):
 [1] Rcpp_0.12.19       plyr_1.8.4         pillar_1.3.0       compiler_3.5.1     RColorBrewer_1.1-2 influenceR_0.1.0  
 [7] bindr_0.1.1        viridis_0.5.1      tools_3.5.1        digest_0.6.17      jsonlite_1.5       viridisLite_0.3.0 
[13] gtable_0.2.0       tibble_1.4.2       rgexf_0.15.3       pkgconfig_2.0.2    rlang_0.2.2        igraph_1.2.2      
[19] rstudioapi_0.8     yaml_2.2.0         curl_3.2           gridExtra_2.3      downloader_0.4     htmlwidgets_1.3   
[25] hms_0.4.2          grid_3.5.1         tidyselect_0.2.4   glue_1.3.0         R6_2.2.2           Rook_1.1-1        
[31] XML_3.98-1.16      readr_1.1.1        purrr_0.2.5        tidyr_0.8.1        ggplot2_3.0.0      magrittr_1.5      
[37] scales_1.0.0       htmltools_0.3.6    assertthat_0.2.0   colorspace_1.3-2   brew_1.0-6         V8_1.5            
[43] stringi_1.1.7      visNetwork_2.0.4   lazyeval_0.2.1     munsell_0.5.0      crayon_1.3.4
```