# the files are here
extract_directory<-'./files/salesforce'
# Unzip the ZIP
unzip(zipfile = './files/WE_00D0Y000001kRXSUA2_1.zip',exdir = extract_directory)
# list files in folders
files<-list.files(path = extract_directory, all.files=FALSE,
           full.names=FALSE)
# Change the working directory so that the load is quicker
setwd(extract_directory)
# Load files
for (i in 1:length(files)) {
  # get loic here to understand to load only non empty csv's
  assign(files[i], read.csv(files[i]))
}

# we need to understand what is going on and how the files are connected
# https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/sforce_api_erd_majors.htm



# end of file
# Set working directory to project directory
setwd("D:/R Projects/my-body-moon")