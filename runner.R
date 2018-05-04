# this is the runner file

# Find how to set working directory to home directory
# so that we only use relative (and short) paths

# we need to load the libraries needed for the below analysis
source('./libraries.R')

# we need to set some oprions on the system
source('./options.R')

# First we need to authenticate
# So, something like 
source('./keys/authentication.R')


# Set something up that will show if everything went OK
# Run dummy query in BQ
# get yesterday's sessions


# The analytics script must run
source('./analytics.R')

# Salesforce Data Need to be retrieved
# After having retrieved the data, this file must be executed in order to update the Salesforce Dashboard
source('./salesforce.R')

# adwords script must run
# same logic as ith analytics
# keep an eye on the conversion window
# always rewrite the last 28 days (30)
# we need to fetch the labels of the campaigns
# We need to fetch the adgroup or ad api
# and then the performance report from API.
# find the most cost effective solution between GCS and BQ
# source('~/adwords.R')

# search console data
# let's use the connector of Data Studio for starters and then we go custom

# Search terms data from adwords

# Search terms data from search console

# Create some scripts that will write the final tables in BQ

# Create Dashboards in Data Studio pointing to the BQ tables

# find a way to automate the whole process
