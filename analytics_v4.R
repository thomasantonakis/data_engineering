# https://cran.r-project.org/web/packages/googleAnalyticsR/vignettes/googleAnalyticsR.html

# Filters creation on metrics
mf <- met_filter("bounces", "GREATER_THAN", 0)
mf2<- met_filter(metric = "sessions", operator = "GREATER", 2)

# Filters creation on dimensions
df <- dim_filter("source", "BEGINS_WITH", "1", not = T)
df2<- dim_filter("source", "BEGINS_WITH", "a", not = T)

# construct filter object
fc2 <- filter_clause_ga4(list(df, df2), operator = "AND")
fc <- filter_clause_ga4(list(mf, mf2), operator = "AND")

# make v4 request
ga_dataframe<- google_analytics_4( viewId = ga_id,
                                   date_range = c("2018-01-01", "2018-02-01"),
                                   dimensions = c('source', 'medium'),
                                   metrics = c('sessions', 'bounces'),
                                   met_filters = fc,
                                   dim_filters = fc2,
                                   filtersExpression = "ga:source!=(direct)"
                                   )
ga_dataframe

# Querying multiple report types at a time

# # two date ranges
# multidate_test<- make_ga_4_req(viewId = ga_id,
#                                date_range = c("2018-01-01", "2018-01-12", "2018-02-01", "2018-02-15"),
#                                dimensions = c('source', 'medium'),
#                                metrics = c('sessions', 'bounces')
#                                )
# ga_data2<-fetch_google_analytics_4(multidate_test)
ga_data2<-google_analytics_4( viewId = ga_id,
                            date_range = c("2018-01-01", "2018-01-12", "2018-02-01", "2018-02-15"),
                            dimensions = c('source', 'medium'),
                            metrics = c('sessions', 'bounces'),
                            # met_filters = fc,
                            # dim_filters = fc2,
                            filtersExpression = "ga:source!=(direct)"
                            )
ga_data2

multidate_test2<- make_ga_4_req(viewId = ga_id,
                               date_range = c("2018-02-01", "2018-02-15"),
                               dimensions = c('hour', 'medium'),
                               metrics = c('sessions', 'bounces')
                               )
ga_data3<-fetch_google_analytics_4(multidate_test2)

# two reports
 # must have the same viewID
ga_data3<-fetch_google_analytics_4(multidate_test, multidate_test2)



# On the fly calculated metrics
gadata4<-google_analytics_4(viewId = ga_id,
                            date_range = c("2018-02-01", "2018-02-15"),
                            dimensions = c('medium'),
                            metrics = c(visitspervisitor = "ga:visits/ga:visitors", 'bounces'),
                            metricFormat = c("FLOAT", "INTEGER")
                            )
gadata4


# Segments on v4
# Create a segment element
se <- segment_element("sessions",operator = "GREATER_THAN", type = "METRIC", comparisonValue = 1, scope = "USER")
se2 <- segment_element("medium", operator = "EXACT", type = "DIMENSION", expressions = "organic")

# choose betwee segment_vector_simple or segment_vector_sequence
## Elements can be combined into clauses, which can then be combined into OR filter clauses
sv_simple<-segment_vector_simple(list(list(se)))
sv_simple2<-segment_vector_simple(list(list(se2)))
## Each segment can then be combined into a logical AND
seg_defined <- segment_define(list(sv_simple, sv_simple2))

# if only one AND definition, you can leave out wraper list()
seg_defined_one <-segment_define(sv_simple)

## Each segment definition can apply to users, sessions or both.
## You can pass a list of several segments
segment4<-segment_ga4("simple", user_segment = seg_defined)

# add the segments to the segment parameter
segment_example<- google_analytics_4(ga_id,
                                     date_range = c("2018-02-01", "2018-02-15"),
                                     dimensions = c('source', 'medium', 'segment'),
                                     segments = segment4,
                                     metrics = c( 'sessions', 'bounces')
                                     )
segment_example

## Sequence segment
se3<-segment_element("medium", operator = "EXACT", type = "DIMENSION", expressions = "organic")
se4<-segment_element("medium", operator = "EXACT", type = "DIMENSION", not= T, expressions = "organic")
# step sequence
## users that arrived via organic then via referral
sv_sequence<-segment_vector_sequence(list(list(se3), list(se4)))

seq_defined2<-segment_define(list(sv_sequence))
segment4_seq<-segment_ga4("sequence", user_segment = seq_defined2)

## Add the segments to the segments parameter
segment_sequence_example<-google_analytics_4(ga_id,
                                             date_range =  c("2018-01-01", "2018-02-01"),
                                             dimensions = c('source', 'segment'),
                                             segments = segment4_seq,
                                             metrics = c('sessions', 'bounces')
                                             )
segment_sequence_example


# Cohort Requests

# Pivot requests



# compare data retrieved to Web UI

# create queries for basic metrics to check
# https://developers.google.com/analytics/devguides/reporting/core/dimsmets

# Source Medium sessions, Bounces, New Users, Session Duration 
q1<-google_analytics_4(ga_id,
                                             date_range =  c("2018-01-01", "2018-02-01"),
                                             dimensions = c('source', 'medium'),
                                             # segments = segment4_seq,
                                             metrics = c('sessions', 'ga:newUsers', 'bounces', 'avgSessionDuration', 'organicSearches')
)
# Adwords
q2<-google_analytics_4(ga_id,
                       date_range =  c("2018-01-01", "2018-02-01"),
                       dimensions = c('adgroup', 'adMatchedQuery'),
                       # segments = segment4_seq,
                       metrics = c('impressions', 'adClicks', 'adCost', 'CPC', 'CPM', 'CTR', 'costPerConversion')
)

# Platform / Device
q3<-google_analytics_4(ga_id,
                       date_range =  c("2018-01-01", "2018-02-01"),
                       dimensions = c('deviceCategory', 'dataSource', 'brower'),
                       # segments = segment4_seq,
                       metrics = c('sessions', 'bounces')
)

# Goal and Goal Conversion
q4<-google_analytics_4(ga_id,
                       date_range =  c("2018-01-01", "2018-02-01"),
                       dimensions = c('source'),
                       # segments = segment4_seq,
                       metrics = c('goal1Completions', 'goal2Completions')
)



# get dynamic date params
# compare with UI
# compare with Data Studio

# create a request that looks like the Website analysis from efood