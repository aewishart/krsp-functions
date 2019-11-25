#Code for extracting focal observations from longterm database 

#Motivation: Since there is no focal ID in the longterm database that allows users to identify unique focal observations, this code enables users to extract focal observations from the database and assign a unique focal ID for further analysis

#This code was created by M.Stimas-Mackey and last modified on November 20, 2019 by E. Siracusa

#Required Packages

library(tidyverse)
library(lubridate)
library(krsp)

# Import Data
# con <- krsp_connect(group="krsp-aws")  # This connection no longer works
con <- krsp_connect (host = "krsp.cepb5cjvqban.us-east-2.rds.amazonaws.com",
                    dbname ="krsp",
                    username = Sys.getenv("krsp_user"),
                    password = Sys.getenv("krsp_password")
) #This is the new preferred connection style

behav <- tbl(con, "behaviour") %>% 
  # remove squirrels with no id
  filter(!is.na(squirrel_id)) %>% 
  # subset for adult focals only
  filter(mode == "3") %>% 
  # remove behaviours with an na entry
  filter(!is.na(behaviour)) %>% 
  # pull data from database into r
  collect() %>% 
  # create a datetime stamp
  mutate(dt = ymd_hms(paste(date, coalesce(time, "00:00:00"))))

# A focal consists of several behaviour records having the same squirrel_id, date, and observer
# To distinguish between focals on the same day we require that groups of records from different focals be separated by t minutes
t <- 10
focals <- behav %>% 
  arrange(squirrel_id, date, observer, dt) %>% 
  group_by(squirrel_id, date, observer) %>% 
  # check for multiple focal groups on same day
  mutate(dd = (dt - lag(dt) >= 60 * t),
         dd = coalesce(dd, FALSE))
# now dd == TRUE signifies a new focal on the same day
# assign a unique id to these focals
focals <- focals %>% 
  # unique id within groups
  mutate(focal_num = cumsum(dd) + 1) %>% 
  ungroup()
# globally unique id
focals$focal_id <- focals %>% 
  group_indices(squirrel_id, date, observer, focal_num)
focals <- focals %>% 
  select(-dd, -focal_num)

write.csv(focals, "../output/Matt's_long_term_focals.csv") #csv file with ALL focal observations
# Note the above requires teh presence of an 'output' folder in the current working folder


#M.Strimas-Mackey's code ends here 
#Below is E.Siracusa's example of how to pull out "accurate" 7 minute focals collected before 2008. This is b/c when couting number of observations per focal there are still some focals with too many observations per focal e.g. >30 and some with too few e.g. < 10. 

#This code can be modified and applied to any portion of the data as long as you know how focals were collected in a given year

focals <- read.csv("../output/Matt's_long_term_focals.csv")
row.per.focal <- focals %>% group_by(focal_id) %>% summarise(n = n()) 
ggplot(row.per.focal) + geom_histogram(aes(x=n), binwidth =1) + xlab("Number of observations/focal")

#Critical incidents were first collected starting in 2008. Therefore all focals prior to 2008 should be 10 min focals with 20 observations 

focals$date <- as.Date(focals$date, "%Y-%m-%d")
focals$yr <- as.numeric(as.character(focals$date, "%Y"))

#Filter for focals before 2008
focals2007 <- focals %>% filter(yr < 2008)
summary2007 <- focals2007 %>% group_by(focal_id) %>% summarise(n = n()) 
ggplot(summary2007) + geom_histogram(aes(x=n), binwidth =1) + xlab("Number of observations/focal")
#This plot appears to agree with my assessent above - that most focals prior to 2008 should have 20 observations

#This is very conservative and eliminates any focals that do not have exactly 20 observations, one could be more liberal and include focals that have e.g. 19-21 observations
fix <- summary2007 %>% filter(n < 20 | n > 20)
fix.v <- fix$focal_id #create a vector of focal IDs that do not have the right number of observations

focals2007new <- focals2007[!(focals2007$focal_id %in% fix.v),] #remove all of these focal IDs from the data

#Check that this worked
summary2007new <- focals2007new %>% group_by(focal_id) %>% summarise(n = n()) 
summary(summary2007new$n)

#You now have as close to "accurate" focals as possible. You can write them to a csv for analysis if desired so that you don't have to rerun the code above.

write.csv(focals2007new, "Pre-2008_Accurate_LT_Focals.csv") #csv file with focal_ids with 20 observations per focal prior to 2008 
