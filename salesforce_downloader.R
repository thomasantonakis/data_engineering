download.file(url = 'https://eu11.salesforce.com/servlet/servlet.OrgExport?fileName=WE_00D0Y000001kRXSUA2_1.ZIP&id=0920Y000004ZaEU', destfile = 'thomas.zip', quiet = FALSE, method = 'wininet')
download.file(url = 'https://`cathy@mybodymoon.com`:`Berlin1978`@eu11.salesforce.com/servlet/servlet.OrgExport?fileName=WE_00D0Y000001kRXSUA2_1.ZIP&id=0920Y000004ZaEU', destfile = 'thomas.zip', quiet = FALSE, method = 'wininet')
unzip(zipfile = './thomas.zip')

command<-'curl -L -b ./keys/cookies.txt https://eu11.salesforce.com/servlet/servlet.OrgExport?fileName=WE_00D0Y000001kRXSUA2_1.ZIP&id=0920Y000004ZaEU -o thomas.zip'
system(command)
