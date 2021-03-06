# the files are here
extract_directory<-'./files/salesforce'

# Add logic to find the latest ZIP file
# Find the latest modification date of the files
paths <- dir(extract_directory, full.names=TRUE)
mt<-max(file.info(paths)$mtime)
# insert Logic to detect the zip file

# Find the modification date of the zip file
zipmt<-file.info('./files/WE_00D0Y000001kRXSUA2_1.zip')$mtime
# If the Zip is newer than the files then Unzip the ZIP
if (zipmt>mt){unzip(zipfile = './files/WE_00D0Y000001kRXSUA2_1.zip',exdir = extract_directory)}
# We need to load all the files in the environment
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


#Retrieve data from the csv's

# We need to flag each lead depending on if it has uploaded anu photos
query<-"SELECT l.id as leadID , a.ID as accountID, l.FirstName, l.LastName, a.Name, l.LeadSource, l.status, l.ConvertedAccountID, 
                        l.InterventionSouhaitee__c, l.Prix__c, l.Pays__c,
                        l.IsConverted, 
                        date(l.CreatedDate) as leadCreateDate,  
                        date(l.ConvertedDate) as leadConvDate,   
                        date(a.CreatedDate) as AccCreateDate,
                        date(l.Date_d_intervention__c) as leadOperDate, 
                        date(l.DateDemande__c) as leadQueryDate,
                        date(a.Date_d_intervention_compte__c) as AccOperDate,
                        case when date(l.CreatedDate) is not null then 1 else 0 end as is_lead,
                        case when date(l.ConvertedDate) is not null then 1 else 0 end as has_conv_dt,
                        case when date(a.Date_d_intervention_compte__c) is not null then 1 else 0 end as has_acc_oper_dt,
                        case when date(l.Date_d_intervention__c) is not null then 1 else 0 end as has_oper_dt,
                        case when l.Photo_1__c = '' then 0 else 1 end as uploaded_photo
        FROM `Lead.csv` as l
        LEFT JOIN `Account.csv` as a
        ON l.ConvertedAccountId = a.Id
"
salesforce<-sqldf(query)
# get how many photos has got uploaded
photos<-sqldf("SELECT cdl.LinkedEntityId as leid, count(cv.ContentDocumentId) as follow_up_photo
                      FROM `ContentDocumentLink.csv` as cdl
              LEFT JOIN `ContentVersion.csv` as cv
              ON cdl.ContentDocumentId = cv.ContentDocumentId
              WHERE cv.IsLatest = 1
              AND cv.FileType NOT IN ('UNKNOWN', 'SNOTE')
              GROUP BY 1")
# Join with how many photos are added afterwards
salesforce<-sqldf("SELECT salesforce.*, photos.follow_up_photo
                   FROM salesforce
                   LEFT JOIN photos
                   ON salesforce.leadID = photos.leid
                   WHERE salesforce.has_conv_dt = 0
                   UNION ALL 
                   SELECT salesforce.*, photos.follow_up_photo
                   FROM salesforce
                   LEFT JOIN photos
                   ON salesforce.ConvertedAccountID = photos.leid
                   WHERE salesforce.has_conv_dt = 1")
# Convert photos as boolean
salesforce$follow_up_photo<-as.integer(!is.na(salesforce$follow_up_photo))
# salesforce2$follow_up_photo<-as.integer(!is.na(salesforce2$follow_up_photo))
# this needs to be checked as only 751 leads seem to have not null follow up photos 
# but the photos are 831 rows long
# there of 779 in leads and Accounts


# write.csv(x = salesforce, file = './files/salesforce.csv',row.names = F)
###############################
# Write a checker dataframe to check the correct movement of total metrics in the dashboard
checker<-data.frame(leads = sum(salesforce$is_lead),
                    conversions = sum(salesforce$has_acc_oper_dt),
                    price = sum(salesforce$Prix__c, na.rm = TRUE)
                    )



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
salesforce$AccOperDate<-as.Date(salesforce$AccOperDate)

# Find implausible rows
salesforce$is_plausible <- !(( salesforce$leadCreateDate > salesforce$leadOperDate ) |
                           ( salesforce$leadCreateDate > salesforce$AccOperDate) |
                           ( salesforce$leadCreateDate > salesforce$leadConvDate ) |
                           ( salesforce$leadConvDate > salesforce$AccOperDate))
# If it is not plausible, check if it one of the bulk conversions of October, and turn to plausible.
salesforce$final <- salesforce$leadCreateDate <= '2017-10-15' | salesforce$is_plausible

# Check the final implausibilities
# We maybe should get provide pecial feeedback on those 34 cases so that they are corrected manually
# implausible cases are listed in the second slide of the dashboard

# Sanitize the country
salesforce$Pays__c[salesforce$Pays__c == 'France' |
                     salesforce$Pays__c == 'FRANCE'|
                     salesforce$Pays__c == '30320 POULX'|
                     salesforce$Pays__c == 'Fance'|
                     salesforce$Pays__c == 'saint etienne'|
                     salesforce$Pays__c == 'liles'|
                     salesforce$Pays__c == 'france']<- 'France'
salesforce$Pays__c[salesforce$Pays__c == 'Belgique' |
                     salesforce$Pays__c == 'BELGIQUE'|
                     salesforce$Pays__c == 'Bruxelles'|
                     salesforce$Pays__c == 'belgique' ]<- 'Belgium'
salesforce$Pays__c[salesforce$Pays__c == 'Suisse'|
                     salesforce$Pays__c == 'Switzerland'|
                     salesforce$Pays__c == 'suisse' ]<- 'Switzerland'
salesforce$Pays__c[salesforce$Pays__c == 'Algerie'|
                     salesforce$Pays__c == 'Algιrie'|
                     grepl('Alg', salesforce$Pays__c, ignore.case = FALSE, perl = FALSE,
                           fixed = FALSE, useBytes = FALSE)]<- 'Algeria'
salesforce$Pays__c[salesforce$Pays__c == 'US'|
                     salesforce$Pays__c == 'Usa' ]<- 'USA'
salesforce$Pays__c[salesforce$Pays__c == 'Angleterre'|
                     salesforce$Pays__c == 'Londres' ]<- 'UK'
salesforce$Pays__c[salesforce$Pays__c == 'djibouti'|
                     salesforce$Pays__c == 'Djibouti' ]<- 'Djibouti'
salesforce$Pays__c[salesforce$Pays__c == 'MAROC'|
                     salesforce$Pays__c == 'Maroc' ]<- 'Morocco'
salesforce$Pays__c[salesforce$Pays__c == 'Brasil'|salesforce$Pays__c == 'Brasil.'|salesforce$Pays__c == 'Brazil'|
                     salesforce$Pays__c == 'Bresil'|salesforce$Pays__c == 'Brésil'|salesforce$Pays__c == 'Brιsil' ]<- 'Brésil'
salesforce$Pays__c[grepl('union', salesforce$Pays__c, ignore.case = TRUE, perl = FALSE,
                         fixed = FALSE, useBytes = FALSE)]<- 'Ile de la Reunion'

# Calculate legitimate days between operation and conversion
salesforce$bto <- salesforce$AccOperDate - salesforce$AccCreateDate 

# Actions per lead missing

# Write to file
# Save the result in a csv
if(file.exists('./files/salesforce.csv')){
  file.remove('./files/salesforce.csv')}
write.csv(x = salesforce, './files/salesforce.csv', row.names = F)

# Upload to BQ
move_to_bq<-'bq load --skip_leading_rows=1  --replace=true --source_format=CSV --null_marker="NA" initial.salesforce ./files/salesforce.csv leadID:string,accountID:string,FirstName:string,LastName:string,Name:string,LeadSource:string,status:string,convertedAccountID:string,desiredOperation:string,price:float,country:string,isCOnverted:integer,leadCreateDate:date,leadConvDate:date,accCreateDate:date,leadOperDate:date,leadQueryDate:date,AccOperDate:date,is_lead:integer,has_conv_dt:integer,has_acc_oper_dt:integer,has_oper_dt:integer,uploaded_photo:integer,follow_up_photo:integer,is_plausible:boolean,final:boolean,bto:integer'
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
