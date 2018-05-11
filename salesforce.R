# the files are here
extract_directory<-'./files/salesforce'

# Add logic to find the latest ZIP file
# Add logic to check if files exist 
# Modification Dates maybe
## With a vector of multiple paths
paths <- dir(extract_directory, full.names=TRUE)
mt<-max(file.info(paths)$mtime)

zipmt<-file.info('./files/WE_00D0Y000001kRXSUA2_1.zip')$mtime
# Unzip the ZIP
unzip(zipfile = './files/WE_00D0Y000001kRXSUA2_1.zip',exdir = extract_directory)
# list files in folders
files<-list.files(path = extract_directory, all.files=FALSE,
           full.names=FALSE)
# Change the working directory so that we do not have to specify te path every time :)
setwd(extract_directory)
# Load files
for (i in 1:length(files)) {
  assign(files[i], read.csv(files[i], stringsAsFactors = FALSE))
}

# end of file
# Set working directory to project directory
# setwd("D:/R Projects/my-body-moon")
setwd("C:/Users/BI/R Projects/my-body-moon")

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


###############################
#############Test##################
###############################
query<-"select l.id as leadID , a.ID as accountID, l.FirstName, l.LastName, a.Name, l.LeadSource, l.status, l.ConvertedAccountID, 
                        l.InterventionSouhaitee__c, l.Prix__c, l.Pays__c,
                        l.IsConverted, 
                        date(l.CreatedDate) as leadCreateDate,  
                        date(l.ConvertedDate) as leadConvDate,   
                        date(a.CreatedDate) as AccCreateDate,
                        date(l.Date_d_intervention__c) as leadOperDate, 
                        date(l.DateDemande__c) as leadQueryDate,
                        date(a.Date_d_intervention_compte__c) as AccdontKnow,
                        case when date(l.CreatedDate) is not null then 1 else 0 end as is_lead,
                        case when date(l.ConvertedDate) is not null then 1 else 0 end as has_conv_dt,
                        case when date(a.CreatedDate) is not null then 1 else 0 end as has_acc_create_dt,
                        case when date(l.Date_d_intervention__c) is not null then 1 else 0 end as has_oper_dt
        from `Lead.csv` as l
        LEFT JOIN `Account.csv` as a
        ON l.ConvertedAccountId = a.Id
"
salesforce<-sqldf(query)
# write.csv(x = salesforce, file = './files/salesforce.csv',row.names = F)
###############################




# Clean up the file
# Dates as dates and not characters
# Fix creation and last modif date
salesforce$leadCreateDate<-as.Date(salesforce$leadCreateDate)

# Fix Lead COnversion Date
salesforce$leadConvDate<-as.Date(salesforce$leadConvDate)

# Fix Account COnversion Date
salesforce$AccCreateDate<-as.Date(salesforce$AccCreateDate)

# Fix Surgery date
salesforce$leadOperDate<-as.Date(salesforce$leadOperDate)

# Fix Query date
salesforce$leadQueryDate<-as.Date(salesforce$leadQueryDate)

# Fix Unknown date
salesforce$AccdontKnow<-as.Date(salesforce$AccdontKnow)

# Find implausible rows
salesforce$is_plausible <- (( salesforce$leadConvDate >= salesforce$leadCreateDate ) &
                           ( salesforce$leadOperDate >= salesforce$leadCreateDate ) &
                           ( salesforce$leadOperDate >= salesforce$leadConvDate)) | salesforce$leadConvDate == '1970-01-01'
# If it is not plausible, check if it one of the bulk conversions of October, and turn to plausible.
salesforce$final <- salesforce$leadConvDate <= '2017-10-15' | salesforce$is_plausible

# Check the final implausibilities
# table(salesforce$final)

# We maybe should get provide pecial feeedback on those 34 cases so that they are corrected manually


# Calculate differences


# Actions per lead missing

# Write to file
# Save the result in a csv
if(file.exists('./files/salesforce.csv')){
  file.remove('./files/salesforce.csv')}
write.csv(x = salesforce, './files/salesforce.csv', row.names = F)

# Upload to BQ
move_to_bq<-'bq load --skip_leading_rows=1  --replace=true --source_format=CSV --null_marker="NA" initial.salesforce ./files/salesforce.csv leadID:string,accountID:string,FirstName:string,LastName:string,Name:string,LeadSource:string,status:string,convertedAccountID:string,desiredOperation:string,price:float,country:string,isCOnverted:integer,leadCreateDate:date,leadConvDate:date,accCreateDate:date,leadOperDate:date,leadQueryDate:date,AccIDNDate:date,is_lead:integer,has_conv_dt:integer,has_acc_create_dt:integer,has_oper_dt:integer,is_plausible:boolean,final:boolean'
# Execute the command
system(move_to_bq)


# # This is unnecessary because we do not do anything else
# # THis needs to be updated
# sql<-"
#   SELECT id,LeadSource,status,ConvertedAccountID,CreatedDate,InterventionSouhete,prix,country,surgery,surgeryDate
# FROM [my-body-moon:initial.salesforce] 
# 
# "
# wait_for(insert_query_job(query = sql, project = project, max_pages = Inf, use_legacy_sql = TRUE,destination_table = 'initial.salesforce' , write_disposition = 'WRITE_TRUNCATE'))
