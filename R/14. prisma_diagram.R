## script for putting together prisma meta analysis paper/species subset path

## set up checkpoint for reproducibility
library(checkpoint)
checkpoint("2018-04-01")

## packages 
library(DiagrammeR)
library(DiagrammeRsvg)
library(rsvg)

grViz("
      
      digraph boxes_and_circles{
      
      ## node statement format
      node [shape = box
      fontname = Helvetica]
      
      ## statement structure
      # papers
      '37895 (pollinat* papers)'; 36127; 30546; 22469; 3974; 2087
      
      # species
      '2254 (animal species)'; 1673
      
      # genera
      '1013 (animal genera)'; 765
      
      # orders
      '63 (animal orders)'; 47
      
      ## edge statements
      # papers
      '37895 (pollinat* papers)' -> 36127 [label = '   Filter non English'
      fontname = Helvetica];
      36127 -> 30546 [label = '   Filter non Article'
      fontname = Helvetica];
      30546 -> 22469 [label = '   Filter non potential species record'
      fontname = Helvetica];
      22469 -> 3974 [label = '   Filter non animal species record'
      fontname = Helvetica]; 
      3974 -> 2087;
      
      # species
      '2254 (animal species)'-> 1673
      
      # genera
      '1013 (animal genera)'-> 765
      
      # orders
      '63 (animal orders)'-> 47 [label = '   Filter non potential geographic record'
      fontname = Helvetica] 
      
      subgraph {
      rank = same; '3974'; '1013 (animal genera)'; '63 (animal orders)' ; '2254 (animal species)'
      }
      
      }
      ") %>%
  
  export_svg %>% charToRaw %>% rsvg_pdf("prisma-diagram_abstract-scrape-03.pdf", width = 700, height= 700)
