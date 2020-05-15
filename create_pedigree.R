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
#library (pedantics)
select = dplyr::select # necessary as MASS also has a select function

# Connecting to the cloud database
con <- krsp_connect (host = "krsp.cepb5cjvqban.us-east-2.rds.amazonaws.com",
                     dbname ="krsp",
                     username = Sys.getenv("krsp_user"),
                     password = Sys.getenv("krsp_password")
)



# Create pedigree from flastall2
krsp_pedigree<-tbl(con, "flastall2") %>% 
  select(id=squirrel_id, dam=dam_id, sire=sire_id) %>% 
  filter(!(is.na(id))) %>% 
  group_by(id) %>% 
  collect() %>% 
  filter(row_number() == 1) %>% 
  ungroup()



#  There were 4 errors discovered in January 2019 when McAdam wrote this code to bring in the cross-foster data.  These will be fixed manually here, 
#  but will be corrected within the juvenile table once the annual data cleanup is done for the 2019 season.  These juveniles did not survive the summer
#  so these errors in dam assignment have not had large issues for previous pedigree analyses
krsp_pedigree <- krsp_pedigree %>% 
  mutate (dam = ifelse(id==4367, 4608, dam),
          dam = ifelse(id==3934, 4682, dam),
          dam = ifelse(id==4249, 4425, dam),
          dam = ifelse(id==4034, 4125, dam))

### fixPedigree from pedantics
fixPedigree <-
  function(Ped, dat=NULL){
    
    if(is.null(dat)==FALSE&&is.null(dim(dat))==FALSE&&length(Ped[,1])!=length(dat[,1])) {
      cat(paste("Pedigree and cohorts differ in length.",'\n')); flush.console(); stop();
    }
    if(is.null(dat)==FALSE&&is.null(dim(dat))&&length(Ped[,1])!=length(dat)) {
      cat(paste("Pedigree and cohorts differ in length.",'\n')); flush.console(); stop();
    }
    
    names(Ped)<-c("id","dam","sire")
    ntotal<-length(Ped$id)*3
    IDs<-array(dim=ntotal)
    for(x in 1:length(Ped$id)) {
      IDs[x]<-as.character(Ped$id[x])
      IDs[x+ntotal]<-as.character(Ped$dam[x])
      IDs[x+ntotal*2]<-as.character(Ped$sire[x])
    }
    IDs<-as.data.frame(IDs)
    IDs<-unique(IDs)
    IDs<-subset(IDs,is.na(IDs)==FALSE)
    names(IDs)<-"id"
    IDs$dam<-Ped$dam[match(IDs$id,Ped$id)]
    IDs$sire<-Ped$sire[match(IDs$id,Ped$id)]
    orderPed<-function(ped){
      reorder<-ped[order(kindepth(ped[,1],ped[,2],ped[,3]), decreasing=FALSE),]
      return(reorder)
    }
    fixedPedigree<-orderPed(IDs)
    if(is.null(dat)==FALSE){
      if(names(dat)[1]=='id'|names(dat)[1]=='ID'|names(dat)[1]=='ids'|names(dat)[1]=='IDS'){
        for(x in 2:length(dat[1,])){
          fixedPedigree[,(3+x-1)]<-dat[match(fixedPedigree[,1],dat[,1]),x]
        }
      } else {
        cat(paste("No id column detected in dat, assuming same order as Ped.",'\n')); flush.console();
        dat$id<-Ped[,1]
        for(x in 1:(length(dat[1,])-1)){
          fixedPedigree[,(3+x-1)]<-dat[match(fixedPedigree[,1],dat$id),x]
        }
      }
    }
    for(x in 1:3) fixedPedigree[,x]<-as.factor(fixedPedigree[,x])
    fixedPedigree
  }



 krsp_pedigree = fixPedigree(krsp_pedigree)
# NOTE that fixPedigree does not change the id's it just changes the order of the records
# so that maternal records occur before the first records of their offspring.


#Summaries:

# krspPedigreeSummary<-pedigreeStats(krsp_pedigree, graphicalReport="n")
# pedStatSummary(krspPedigreeSummary)

#drawPedigree(krsp_pedigree)