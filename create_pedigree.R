#This function will create a pedigree from the flastall2 table in the cloud version of the krsp database.  The pedigree will be called 'krsp_pedigree'.  flastall2 contains all squirrels born in the study (including those not tagged).
#The data can be further filtered as needed.

# Since the pedigree is very large the pedigree summary statistics can take a VERY long time to calculate.  These steps are only needed to provide summary data on the pedigree.  
# They are currently commented out to avoid running accidentally.  They can be un-commented as needed.

# Install packages as needed
# install.packages("tidyverse")
# install.packages("pedantics")

# Install krsp package from GitHub
# install.packages("devtools")
# library (devtools)
# devtools::install_github("KluaneRedSquirrelProject/krsp")




library (tidyverse)
library (krsp)
library (pedantics)
select = dplyr::select # necessary as MASS also has a select function

# Connecting to the cloud database
con = krsp_connect(group = "krsp-aws")

# Create pedigree from flastall2
krsp_pedigree<-tbl(con, "flastall2") %>% 
  select(id=squirrel_id, dam=dam_id, sire=sire_id) %>% 
  filter(!(is.na(id))) %>% 
  group_by(id) %>% 
  collect() %>% 
  filter(row_number() == 1) %>% 
  ungroup()

krsp_pedigree = fixPedigree(krsp_pedigree)

#Summaries:

# krspPedigreeSummary<-pedigreeStats(krsp_pedigree, graphicalReport="n")
# pedStatSummary(krspPedigreeSummary)

#drawPedigree(krsp_pedigree)