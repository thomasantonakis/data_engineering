# the files are here
extract_directory<-'./files/salesforce'
# Unzip the ZIP
unzip(zipfile = './files/WE_00D0Y000001kRXSUA2_1.zip',exdir = extract_directory)
# list files in folders
files<-list.files(path = extract_directory, all.files=FALSE,
           full.names=FALSE)
# Change the working directory so that the load is quicker
setwd(extract_directory)
# Load files
for (i in 1:length(files)) {
  assign(files[i], read.csv(files[i], stringsAsFactors = FALSE))
}

# end of file
# Set working directory to project directory
setwd("D:/R Projects/my-body-moon")

# Clean up empty Dataframes
## create a function that returns a logical value
isEmpty <- function(x) {
  is.data.frame(x) && nrow(x) == 0L
}
## apply it over the environment
empty <- unlist(eapply(.GlobalEnv, isEmpty))
## remove the empties
rm(list = names(empty)[empty])

# we need to understand what is going on and how the files are connected
# https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/sforce_api_erd_majors.htm

# Get the main file for leads from the feed
salesforce<- Lead.csv
# place here the names of columns to keep
cols_to_keep<- names(salesforce) %in% c("Id", "LeadSource", "Status", "ConvertedAccountId",
                                        "CreatedDate","InterventionSouhaitee__c", "Prix__c",
                                        "Date_d_arriv_e__c", "Date_d_intervention__c", "Pays__c") 
# Keep only those columns
salesforce <- salesforce[cols_to_keep]
# Clean up the file
# Dates as dates and not characters


# Fix creation and last modif date
salesforce$CreatedDate<-as.Date(salesforce$CreatedDate)
# Fix Surgery date
salesforce$surgery<-ifelse (salesforce$Date_d_intervention__c!='', TRUE , FALSE )
salesforce$surgery_date<- ifelse (salesforce$Date_d_intervention__c!='', salesforce$Date_d_intervention__c, "1970-01-01 00:00:00")
salesforce$surgery_date<-as.Date(salesforce$surgery_date)

# Drop Unneeded columns
salesforce$Date_d_intervention__c<-NULL;salesforce$Date_d_arriv_e__c<-NULL
# Calculate differences
# salesforce$days_to_convert<-salesforce$ConvertedDate - salesforce$CreatedDate
# salesforce$days_to_convert[salesforce$IsConverted < 1]<-NA
# salesforce$conv_to_surg<-salesforce$surgery_date - salesforce$ConvertedDate
# salesforce$conv_to_surg[salesforce$IsConverted < 1]<-NA
# salesforce$conv_to_surg[salesforce$surgery_date =='1970-01-01']<-NA

# Actions per lead missing

# Write to file
# Save the result in a csv
if(file.exists('./files/salesforce.csv')){
  file.remove('./files/salesforce.csv')}
write.csv(x = salesforce, './files/salesforce.csv', row.names = F)

# Move to BQ
move_to_bq<-'bq load --skip_leading_rows=1  --replace=true --source_format=CSV --null_marker="NA" initial.salesforce ./files/salesforce.csv id:string,LeadSource:string,status:string,ConvertedAccountID:string,CreatedDate:date,InterventionSouhete:string,prix:float,country:string,surgery:boolean,surgeryDate:date'
system(move_to_bq)

sql<-"
  SELECT id,LeadSource,status,ConvertedAccountID,CreatedDate,InterventionSouhete,prix,country,surgery,surgeryDate
FROM [my-body-moon:initial.salesforce] 

"
wait_for(insert_query_job(query = sql, project = project, max_pages = Inf, use_legacy_sql = TRUE,destination_table = 'initial.salesforce' , write_disposition = 'WRITE_TRUNCATE'))
