# options file

# Set working directory to project directory
setwd("D:/R Projects/my-body-moon")

# Set scope item to contain a vector of scopes in strings
scope<-c(
  "https://www.googleapis.com/auth/webmasters",
  "https://www.googleapis.com/auth/analytics",
  "https://www.googleapis.com/auth/analytics.readonly",
  "https://www.googleapis.com/auth/devstorage.full_control",
  "https://www.googleapis.com/auth/cloud-platform",
  "https://www.googleapis.com/auth/bigquery",
  "https://www.googleapis.com/auth/bigquery.insertdata",
  "https://www.googleapis.com/auth/drive",
  "https://www.googleapis.com/auth/drive.readonly"
)

# Pass this into the options
options(googleAuthR.scopes.selected = scope)

# Set project name
project<-"my-body-moon"

# Get today's date
today<-Sys.Date()

# Zone in GCP
zone<-'europe-west1-c'
zone_n<-19
