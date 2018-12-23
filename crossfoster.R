library (krsp)
library (tidyverse)

con <- krsp_connect(group="krsp-aws") 

alias<-tbl(con, 'squirrel_alias') %>% 
  select(squirrel_id, taglft) %>% 
  collect()



cross_foster<-read_csv("cross_fostering.csv") 

cross_foster<-cross_foster %>% 
  filter(!is.na(pup_alpha_taglft)) %>% 
  mutate(pup_alpha_taglft=ifelse(pup_alpha_taglft=="D1559", "D1560", pup_alpha_taglft)) %>% 
  distinct()
# Looks like these tags got reversed in the pup in my cross-foster data
# D1559/D1560 should be D1560/D1559


  
cross_foster<-cross_foster %>% 
  left_join(y=alias, by=c("pup_alpha_taglft" = "taglft")) %>% 
  rename (pup_squirrel_id = squirrel_id)

cross_foster<-cross_foster %>% 
  left_join(y=alias, by=c("dam_origin_alpha_taglft" = "taglft")) %>% 
  rename (dam_origin_squirrel_id = squirrel_id)


cross_foster<-cross_foster %>% 
  left_join(y=alias, by=c("dam_rearing_alpha_taglft" = "taglft")) %>% 
  rename (dam_rearing_squirrel_id = squirrel_id)


cross_foster<-cross_foster %>% 
  mutate(dam_origin_squirrel_id=ifelse(dam_origin_alpha_taglft=="A9679", 4925, dam_origin_squirrel_id)) %>%  
  mutate(dam_origin_squirrel_id=ifelse(dam_origin_alpha_taglft=="A6998", 5354, dam_origin_squirrel_id)) %>% 
  mutate(dam_rearing_squirrel_id=ifelse(dam_rearing_alpha_taglft=="A9679", 4925, dam_rearing_squirrel_id)) %>% 
# There were a few tag combinations that were not in the squirrel alias table because of changed taglft
# A9679/C4770
# A6998/A6999
  select (pup_squirrel_id, dam_origin_squirrel_id, dam_rearing_squirrel_id)

rm(alias)
summary (cross_foster)

