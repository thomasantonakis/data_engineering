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
if(dates$min=='2015-05-29'){
  d_r <- c(dates$max+1, today-1)
  } else {
  d_r<-  c(dates$min, today-1)
  }

# Execute the queryto get the above date range analytics data
query_4_analytics<-google_analytics(ga_id, 
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
if(file.exists('./files/analytics.csv')) file.remove('./files/analytics.csv')
write.csv(x = query_4_analytics, './files/analytics.csv', row.names = F)

# Upload to the initial data set in BigQuery by appending
if(dates$min=='2015-05-29'){
  move_to_bq<-'bq load --skip_leading_rows=1  --replace=true --source_format=CSV --null_marker="NA" initial.analytics ./files/analytics.csv date:date,deviceCategory:string,landingPagePath:string,sourceMedium:string,campaign:string,country:string,sessions:integer,bounces:integer,pageViews:integer,goal1Completions:integer,goal2Completions:integer,goal3Completions:integer,goal4Completions:integer,goal5Completions:integer'
} else {
  move_to_bq<-'bq load --skip_leading_rows=1  --replace=false --source_format=CSV --null_marker="NA" initial.analytics ./files/analytics.csv date:date,deviceCategory:string,landingPagePath:string,sourceMedium:string,campaign:string,country:string,sessions:integer,bounces:integer,pageViews:integer,goal1Completions:integer,goal2Completions:integer,goal3Completions:integer,goal4Completions:integer,goal5Completions:integer'
}
system(move_to_bq)
# Check if it went right
# delete the csv
if(file.exists('./files/analytics.csv')) file.remove('./files/analytics.csv')

# Save a mapped table in the data_sources data set 
# query initial.analytics and join with mapping.landng
sql<-"
      Select *
from [my-body-moon:maps.landing]
"
# Fetch query result and store in dataframe
map<-query_exec(query = sql, project = project, max_pages = Inf, use_legacy_sql = TRUE)

