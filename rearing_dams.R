# In 1999 and 2000 151 offspring were cross-fostered.
# This code starts with the pedigree and then creates columns of squirrel_ids for both the birth_dam and the rearing_dam
# based on the crossfoster data.

#  McAdam
#  January 4, 2019

library (tidyverse)
library (krsp)
select = dplyr::select # necessary as MASS also has a select function

# Connecting to the cloud database
con = krsp_connect(group = "krsp-aws")


# Create pedigree
library(RCurl)
script <- getURL("https://raw.githubusercontent.com/KluaneRedSquirrelProject/krsp-functions/master/create_pedigree.R", ssl.verifypeer = FALSE)
eval(parse(text = script))


###  Gather Cross-Fostering Data
script <- getURL("https://raw.githubusercontent.com/KluaneRedSquirrelProject/krsp-functions/master/crossfoster.R", ssl.verifypeer = FALSE)
eval(parse(text = script))


rearing_dams<-krsp_pedigree %>% 
  mutate(id = as.numeric(id)) %>% 
  left_join(cross_foster, by=c("id" = "pup_squirrel_id")) %>% 
  mutate (dam_rearing_squirrel_id = ifelse(is.na(dam_rearing_squirrel_id), dam, dam_rearing_squirrel_id)) %>% 
  select(id, birth_dam = dam, rearing_dam = dam_rearing_squirrel_id)






