#Folder paths
snp_path = ""
file_path = ""
data_path = ""
split_sample_path = ""

#Write .do code to keep SNPs for each trait for MR data

#Load in harmonised data
exposure_dat_harmonised = read.csv(paste(snp_path,"\\exposure_dat_harmonised_8.csv",sep=""))
traits = unique(exposure_dat_harmonised$trait[exposure_dat_harmonised$included == 1])
file = paste(file_path,"\\snps_to_keep.do",sep="")
write("**Do file to keep SNPs for each exposure",file,append=FALSE)
write(paste('cd ',data_path,sep=""),file,append=TRUE)
for(t in traits) {
  snps = as.character(unique(exposure_dat_harmonised$SNP[exposure_dat_harmonised$trait == t & exposure_dat_harmonised$included == 1]))
  write(paste("*Trait = ",t,sep=""),file,append=TRUE)
  write('use "snp_ipd.dta", clear',file,append=TRUE)
  write(" ",file,append=TRUE)
  snps_line = "keep id_ieu "
  for(s in snps){
    snps_line = paste(snps_line,s,"_ ",sep="")
  }
  write(snps_line,file,append=TRUE)
  write(paste('save "snps\\snps_',t,'.dta", replace',sep=""),file,append=TRUE)
  write('merge 1:1 id_ieu using "snps\\outcomes.dta", nogen',file,append=TRUE)
  
  #Breast cancer should only have women
  if(t == "breast_carcinoma"){
    write("keep if sex == 0",file,append=TRUE)
  }
  
  #Depression (Wray) should only have non-pilot people
  if(t == "Major_Depressive_Disorder"){
    write("keep if pilot == 0",file,append=TRUE)
  }
  write('gen snp = ""
        gen effect_allele = ""
        gen eaf = .
        gen outcome = ""
        gen beta = .
        gen se = .
        gen p = .
        gen cases = .
        gen controls = .
        gen n_total = .
        local i = 1
        foreach outcome of varlist eco* soc* {
        local out = substr("`outcome\'",5,.)
        local out = subinstr("`out\'","_"," ",.)
        *Continuous outcomes
        if "`out\'" == "household income" | "`out\'" == "tdi" | "`out\'" == "household income re" | "`out\'" == "household income equi" {
          qui regress `outcome\' rs* age sex pc*
        }
        *Binary outcomes
        else {
          qui logit `outcome\' rs* age sex pc*
        }
        
        foreach snp of varlist rs* {
        local snpx = substr("`snp\'",1,length("`snp\'")-2)
        qui replace snp = "`snpx\'" in `i\'  
        qui replace outcome = "`out\'" in `i\'
        
        qui replace beta = _b[`snp\'] if snp == "`snpx\'" & outcome == "`out\'"
        qui replace se = _se[`snp\'] if snp == "`snpx\'" & outcome == "`out\'"
        qui sum `snp\'  
        qui replace eaf = r(mean)/2 if snp == "`snpx\'"  
        local effect_allele = upper(substr("`snp\'",length("`snp\'"),1))
        qui replace effect_allele = "`effect_allele\'" if snp == "`snpx\'" 
        local i = `i\'+1
        }
        }
        
        *Ns
        foreach outcome of varlist eco* soc* {
        *Continuous outcomes
        qui sum `outcome\'
        local out = substr("`outcome\'",5,.)
        local out = subinstr("`out\'","_","",.)
        if "`out\'" == "household income" | "`out\'" == "tdi" | "`out\'" == "household income re" | "`out\'" == "household income equi" {
        qui replace n_total = r(N) if outcome == "`out\'"
        }
        *Binary outcomes
        else {
        qui replace cases = r(N)*r(mean) if outcome == "`out\'"
        qui replace controls = r(N)-r(N)*r(mean) if outcome == "`out\'"
        qui replace n_total = r(N) if outcome == "`out\'"
        }
        }
        
        keep snp-n_total
        keep if snp != ""
        qui replace p = 2*normal(-abs(beta/se))',file,append=TRUE)
  write(paste('save "snps\\results_',t,'.dta", replace',sep=""),file,append=TRUE)
  
  write("",file,append=TRUE)
}

######################################################################################################

#Load in harmonised data - SPLIT SAMPLE
exposure_dat_harmonised = read.csv(paste(split_sample_path,"\\exposure_dat_harmonised_ss.csv",sep=""))
exposure_dat_harmonised$trait = gsub("sig_","",exposure_dat_harmonised$trait)
exposure_dat_harmonised$exposure = gsub("sig_","",exposure_dat_harmonised$exposure)
traits = unique(exposure_dat_harmonised$trait[exposure_dat_harmonised$included == 1])
file = paste(file_path,"\\snps_to_keep_ss.do",sep="")
write("**Do file to keep SNPs for each exposure",file,append=FALSE)
write(paste('cd ',data_path,sep=""),file,append=TRUE)
for(t in traits) {
  snps = as.character(unique(exposure_dat_harmonised$SNP[exposure_dat_harmonised$trait == t & exposure_dat_harmonised$included == 1]))
  write(paste("*Trait = ",t,sep=""),file,append=TRUE)
  write('use "snp_ipd_ss.dta", clear',file,append=TRUE)
  write(" ",file,append=TRUE)
  snps_line = "keep id_ieu "
  for(s in snps){
    snps_line = paste(snps_line,s,"_ ",sep="")
  }
  write(snps_line,file,append=TRUE)
  write(paste('save "snps_ss\\snps_',t,'.dta", replace',sep=""),file,append=TRUE)
  write('merge 1:1 id_ieu using "snps_ss\\outcomes.dta", nogen',file,append=TRUE)
  
  #Breast cancer shoujld only have women
  if(t == "breast_carcinoma"){
    write("keep if sex == 0",file,append=TRUE)
  }
  
  #Split sample, so only need half the sample in the regressions
  x = nchar(t)
  if(substr(t,x,x) == "1"){
    write("keep if sample == 2",file,append=TRUE)
  }
  else{
    write("keep if sample == 1",file,append=TRUE)
  }
  
  write('gen snp = ""
        gen effect_allele = ""
        gen eaf = .
        gen outcome = ""
        gen beta = .
        gen se = .
        gen p = .
        gen cases = .
        gen controls = .
        gen n_total = .
        local i = 1
        foreach outcome of varlist eco* soc* {
        local out = substr("`outcome\'",5,.)
        local out = subinstr("`out\'","_"," ",.)
        *Continuous outcomes
        if "`out\'" == "household income" | "`out\'" == "tdi" | "`out\'" == "household income re" | "`out\'" == "household income equi" {
        qui regress `outcome\' rs* age sex pc*
        }
        *Binary outcomes
        else {
        qui logit `outcome\' rs* age sex pc*
        }
        
        foreach snp of varlist rs* {
        local snpx = substr("`snp\'",1,length("`snp\'")-2)
        qui replace snp = "`snpx\'" in `i\'  
        qui replace outcome = "`out\'" in `i\'
        
        qui replace beta = _b[`snp\'] if snp == "`snpx\'" & outcome == "`out\'"
        qui replace se = _se[`snp\'] if snp == "`snpx\'" & outcome == "`out\'"
        qui sum `snp\'  
        qui replace eaf = r(mean)/2 if snp == "`snpx\'"  
        local effect_allele = upper(substr("`snp\'",length("`snp\'"),1))
        qui replace effect_allele = "`effect_allele\'" if snp == "`snpx\'" 
        local i = `i\'+1
        }
        }
        
        *Ns
        foreach outcome of varlist eco* soc* {
        *Continuous outcomes
        qui sum `outcome\'
        local out = substr("`outcome\'",5,.)
        local out = subinstr("`out\'","_"," ",.)
        if "`out\'" == "household income" | "`out\'" == "tdi" | "`out\'" == "household income re" | "`out\'" == "household income equi" {
        qui replace n_total = r(N) if outcome == "`out\'"
        }
        *Binary outcomes
        else {
        qui replace cases = r(N)*r(mean) if outcome == "`out\'"
        qui replace controls = r(N)-r(N)*r(mean) if outcome == "`out\'"
        qui replace n_total = r(N) if outcome == "`out\'"
        }
        }
        
        keep snp-n_total
        keep if snp != ""
        qui replace p = 2*normal(-abs(beta/se))',file,append=TRUE)
  write(paste('save "snps_ss\\results_',t,'.dta", replace',sep=""),file,append=TRUE)
  
  write("",file,append=TRUE)
        }