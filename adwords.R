reports()
metrics(report='CAMPAIGN_PERFORMANCE_REPORT')
metrics(report='ADGROUP_PERFORMANCE_REPORT')
metrics(report = 'KEYWORDS_PERFORMANCE_REPORT')
metrics(report = 'SEARCH_QUERY_PERFORMANCE_REPORT')

yesterday <- gsub("-","",format(Sys.Date()-1,"%Y-%m-%d"))
thirtydays<- gsub("-","",format(Sys.Date()-29,"%Y-%m-%d"))



# Create statement
# adwords_keywords
body1 <- statement(select=c('CampaignName','AdGroupName', 'QualityScore', 'Device', 'Date','Criteria', 'Id','TopOfPageCpc',
                           'AdNetworkType2','Clicks','Impressions','Cost','AveragePosition', 'Conversions',
                           'SearchImpressionShare', 'SearchRankLostImpressionShare' ),
                  report="KEYWORDS_PERFORMANCE_REPORT",
                  start="2018-05-01",
                  end="2018-06-01")

# adwords_search_term
body2 <- statement(select=c('CampaignName','AdGroupName', 'Device', 'Date','Query', 'QueryMatchTypeWithVariant',
                            'KeywordId',
                           'Clicks','Impressions','Cost','AverageCpc', 'AveragePosition', 'Conversions', 'ConversionRate'),
                  report="SEARCH_QUERY_PERFORMANCE_REPORT",
                  # where="CampaignName STARTS_WITH 'A' AND Clicks > 100",
                  start="2018-05-01",
                  end="2018-05-31")

# What is needed is the map of ID and Keywords from the one report so that we can join them to the seconf report
# Just search the report name to the adwords api docs so that we find out the proper names of the columns needed
# Manipulation is needed afterqwards for formatting reasons
# Check the Top Of Page CPC format, seems a bit weird
  
# Pull data from Adwords
# Check with UO
adwords_keywords <- getData(clientCustomerId=adwordsCustomerID, google_auth=google_auth, statement=body1)
adwords_search_term <- getData(clientCustomerId=adwordsCustomerID, google_auth=google_auth, statement=body2)

# Alex says that we need :
# Adgroup Performance without getting the conversion name and type
# Adgroup performance report with conversions with all the breakdowns
# Label report me labelID


# Upload to BQ etc
