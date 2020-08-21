#Folder paths
wd_path = ""

#Create do files do automations of ICD9 and ICD10 capture
setwd(wd_path)
icd9 = read.csv("data/HES/icd9.csv",header = FALSE)
file = "do/Automated/ICD_codes9.do"

write("*ICD-9 code",file,append=FALSE)
for(i in 1:41){
  write("foreach var of varlist s_41203* s_41205* {",file,append=TRUE)
  write(paste("  foreach icd in ",icd9$V1[i]," {",sep=""),file,append=TRUE)
  write(paste("  qui replace x",i," = 1 if strpos(`var',\"`icd'\") > 0",sep=""),file,append=TRUE)
  write("  }",file,append=TRUE)
  write("}",file,append=TRUE)
}


icd10 = read.csv("data/HES/icd10.csv",header=FALSE)
file = "do/Automated/ICD_codes10.do"

write("*ICD-10 code",file,append=FALSE)
for(i in 1:42){
  write("foreach var of varlist diag* {",file,append=TRUE)
  write(paste("  foreach icd in ",icd10$V1[i]," {",sep=""),file,append=TRUE)
  write(paste("  qui replace v",i," = 1 if strpos(`var',\"`icd'\") > 0",sep=""),file,append=TRUE)
  write("  }",file,append=TRUE)
  write("}",file,append=TRUE)
}