# Analytics file

# the script must recognize the current date
# We need to identify the old data
# how long has it been since the last update?
# If if is null, then setup a batch historic download
# if not, fetch the missing days.
# automate so that the missing dates are a day at most
# find the most cost effective solution between GCS and BQ


# First we need to identify the latest day in BQ data
# if no data, then retrieve all time, else get only latest
sql<-"
      Select 
            min(date) as min,
            max(date) as max
      from [my-body-moon:initial.analytics]
"
# Fetch query result and store in dataframe
dates<-query_exec(query = sql, project = project, max_pages = Inf, use_legacy_sql = TRUE)

# Check if earliest day is '2015-05-29' and construct the date range
if(dates$min<'2017-01-01'){
  d_r <- c(dates$max+1, today-1)
  } else {
  d_r<-  c(as.Date('2015-05-29'), today-1)
  }

# Execute the queryto get the above date range analytics data
query_4_analytics<-google_analytics_4(ga_id, 
                                       date_range = d_r,
                                       dimensions=c('date','deviceCategory', 'ga:landingPagePath', "ga:sourceMedium", 'ga:campaign', 'country'), 
                                       metrics = c('sessions', 'bounces', 'pageViews', 'goal1Completions', 'goal2Completions',
                                                   'goal3Completions', 'goal4Completions', 'goal5Completions'), 
                                       met_filters = NULL, 
                                       dim_filters = NULL, 
                                       filtersExpression =NULL,
                                       order = order_type('sessions', sort_order = "DESCENDING"),
                                    anti_sample = TRUE,
                                    slow_fetch = TRUE
                                    )

# Save the result in a csv
if(file.exists('./files/analytics.csv')){
      file.remove('./files/analytics.csv')
      write.csv(x = query_4_analytics, './files/analytics.csv', row.names = F)
      }

# Upload to the initial data set in BigQuery by appending
if(dates$min<'2017-01-01'){
  move_to_bq<-'bq load --skip_leading_rows=1  --replace=false --source_format=CSV --null_marker="NA" initial.analytics ./files/analytics.csv date:date,deviceCategory:string,landingPagePath:string,sourceMedium:string,campaign:string,country:string,sessions:integer,bounces:integer,pageViews:integer,goal1Completions:integer,goal2Completions:integer,goal3Completions:integer,goal4Completions:integer,goal5Completions:integer'
} else {
  move_to_bq<-'bq load --skip_leading_rows=1  --replace=true --source_format=CSV --null_marker="NA" initial.analytics ./files/analytics.csv date:date,deviceCategory:string,landingPagePath:string,sourceMedium:string,campaign:string,country:string,sessions:integer,bounces:integer,pageViews:integer,goal1Completions:integer,goal2Completions:integer,goal3Completions:integer,goal4Completions:integer,goal5Completions:integer'
}
system(move_to_bq)
# Check if it went right
# delete the csv
# if(file.exists('./files/analytics.csv')) file.remove('./files/analytics.csv')

# Get the maps from Google Drive
# This lists all files that the service acccount hass access to
maps<-drive_ls()
# Landing ID
landing<-maps$id[maps$name == 'Landing Page Mapping']
# DOwnload the damn file
drive_download(as_id(landing), path = './files/landing.csv', overwrite = TRUE)

# Search Terms ID
terms<-maps$id[maps$name == 'SearchTerm Mapping']
# DOwnload the damn file
drive_download(as_id(terms), path = './files/terms.csv', overwrite = TRUE)

# Adwords ID
adwords<-maps$id[maps$name == 'Adwords Lookup']
# DOwnload the damn file
drive_download(as_id(adwords), path = './files/adwords.csv', overwrite = TRUE)

# Command for upload to BQ
move_to_bq<-'bq load --skip_leading_rows=1  --replace=true --source_format=CSV --null_marker="NA" initial.landing ./files/landing.csv landing_page:string,lp_group:string,context_1:string,context2:string,context3:string,sessions:integer'
# Execute command
system(move_to_bq)

# Command for upload to BQ
move_to_bq<-'bq load --skip_leading_rows=1  --replace=true --source_format=CSV --null_marker="NA" initial.adwords ./files/adwords.csv campaign:string,ad_group:string,label1:string,label2:string'
# Execute command
system(move_to_bq)

# Command for upload to BQ
move_to_bq<-'bq load --skip_leading_rows=1  --replace=true --source_format=CSV --null_marker="NA" initial.terms ./files/terms.csv keyword:string,impressions:string,treatment:string,brand:string,dhi:string,maxigreffe:string,operation:string,chirurgie:string,grefef:string,capillaire:string,implant:string,femme:string,clinique:string,cheveux:string,fue:string,location:string,cout:string,context:string,cher:string,barbe:string'
# Execute command
system(move_to_bq)

# Overwrite the analytics ttable but this time having the mappings of landing pages
# Write the query
sql<-"
  SELECT a.date as date, a.deviceCategory as deviceCategory, 
        a.landingPagePath as landingPagePath, a.sourceMedium as sourceMedium,
        a.campaign as campaign, a.country as country, a.sessions as sessions, 
        a.bounces as bounces, a.pageViews as pageViews, 
        a.goal1Completions as goal1Completions,
        a.goal2Completions as goal2Completions, 
        a.goal3Completions as goal3Completions, 
        a.goal4Completions as goal4Completions, 
        a.goal5Completions as goal5Completions, 
        b.lp_group as landing_group,
        b.context_1 as context1,
        b.context2 as context_2,
        b.context3 as context_3
  from [my-body-moon:initial.analytics] a
  LEFT JOIN [my-body-moon:initial.landing] b
  on a.landingPagePath = b.landing_page
"
# Execute job
wait_for(insert_query_job(query = sql, project = project, max_pages = Inf, use_legacy_sql = TRUE,destination_table = 'initial.mapped_analytics' , write_disposition = 'WRITE_TRUNCATE'))
