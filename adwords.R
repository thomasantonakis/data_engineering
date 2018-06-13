# reports()
metrics(report='CAMPAIGN_PERFORMANCE_REPORT')
metrics(report='ADGROUP_PERFORMANCE_REPORT')

yesterday <- gsub("-","",format(Sys.Date()-1,"%Y-%m-%d"))
thirtydays<- gsub("-","",format(Sys.Date()-29,"%Y-%m-%d"))



# Create statement
#Example 1
# body <- statement(select=c('Clicks','Impressions','Cost','AverageCpc'),
#                   report="ACCOUNT_PERFORMANCE_REPORT",
#                   start="2018-05-01",
#                   end="2018-06-01")
#Example 2
body <- statement(select=c('CampaignName','CampaignType', 'Device',
                           'Clicks','Impressions','Cost','AverageCpc', 'AveragePosition', 'Conversions', 'ConversionRate',
                           'SearchBudgetLostImpressionShare', 'SearchRankLostImpressionShare' ),
                  report="CAMPAIGN_PERFORMANCE_REPORT",
                  # where="CampaignName STARTS_WITH 'A' AND Clicks > 100",
                  start="2018-05-01",
                  end="2018-05-31")
# #Example 3
# body <- statement(select=c('Criteria','Clicks','Cost','Ctr'),
#                   report="KEYWORDS_PERFORMANCE_REPORT",
#                   where="Clicks > 100",
#                   start="2018-05-01",
#                   end="2018-06-01")                     
  
# Pull data from Adwords
# Check with UO
adwordsData <- getData(clientCustomerId=adwordsCustomerID, google_auth=google_auth, statement=body)

# Alex says that we need :
# Adgroup Performance without getting the conversion name and type
# Adgroup performance report with conversions with all the breakdowns
# Label report me labelID
