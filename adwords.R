yesterday <- gsub("-","",format(Sys.Date()-1,"%Y-%m-%d"))
thirtydays<- gsub("-","",format(Sys.Date()-29,"%Y-%m-%d"))


# Create statement
body <- statement(select = c(
  "CampaignName",
  "AdGroupName",
  "Criteria",
  "KeywordMatchType",
  "QualityScore",
  "Impressions",
  "Clicks",
  "Ctr",
  "ConvertedClicks",
  "AverageCpc",
  "Cost",
  "Date"),
  report = "KEYWORDS_PERFORMANCE_REPORT",
  where = "AdNetworkType1 = SEARCH",
  start = thirtydays)
  
# Pull data from Adwords
# Check with UO
adwordsData <- getData(clientCustomerId=adwordsCustomerID, google_auth=google_auth, statement=body)

# Alex says that we need :
# Adgroup Performance without getting the conversion name and type
# Adgroup performance report with conversions with all the breakdowns
# Label report me labelID
