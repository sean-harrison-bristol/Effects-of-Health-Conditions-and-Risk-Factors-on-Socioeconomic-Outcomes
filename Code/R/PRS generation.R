#Folder paths
source_path = ""
main_path = ""
gscan_path = ""
split_sample_path = ""
tables_path = ""

#Load in the function
remove(list=ls())
source(paste(source_path,"\\mrbase_grs_v2.02.r",sep=""))

#set working directory
setwd(main_path)

#All subcategories look helpful, just look at traits
traits = mrbase_grs(output="traits", population = "European")

# alcohol = GSCAN
# asthma = 44
# BMI = 835
# breast cancer = "GCST004988"
# cholesterol = 307
# coronary heart disease = 8
# depression = 1187
# diabetes = 26
# eczema = 996
# migraine = "GCST003720"
# osteoarthritis = "GCST002155"
# smoking = GSCAN
# systolic blood pressure = Download

studies_list = c(8,26,44,307,835,996,1000,1187)

#Note: MR Base has clumped on 5e-08, but one of the studies has been clumped incorrectly, so specify slightly more than 5e-08
dat8 = mrbase_grs(output="code", studies=studies_list,p=5.000001e-8)

################################################################################################################################

#Ebi-GWAS

data("gwas_catalog")
head("gwas_catalog")

study_list = c("GCST004988","GCST003720","GCST002155")
ebi = gwas_catalog[gwas_catalog$STUDY.ACCESSION %in% study_list,]

#Need to conform to MR-Base and restrict to P value threshold, clump too

#Conform to MR-Base
ebi_dat = data.frame(ebi$STUDY.ACCESSION)
ebi_dat = rename(ebi_dat,id.exposure = "ebi.STUDY.ACCESSION")
ebi_dat$SNP = ebi$SNP
ebi_dat$effect_allele.exposure = ebi$effect_allele
ebi_dat$other_allele.exposure = ebi$other_allele
ebi_dat$eaf.exposure = ebi$eaf
ebi_dat$beta.exposure = ebi$beta
ebi_dat$samplesize.exposure = NA
ebi_dat$SNP = ebi$SNP
ebi_dat$ncase.exposure = NA
ebi_dat$ncontrol.exposure = NA
ebi_dat$pval.exposure = ebi$pval
ebi_dat$se.exposure = ebi$se
ebi_dat$units.exposure = ebi$units
ebi_dat$exposure = ebi$Phenotype_simple
ebi_dat$mr_keep.exposure = TRUE
ebi_dat$pval_origin.exposure = "reported"
ebi_dat$data_source.exposure = "EBI GWAS Database"
ebi_dat$clumped = FALSE
ebi_dat$priority = 1
ebi_dat$trait = ebi$MAPPED_TRAIT_EFO

#Restrict to P < 5e-08
ebi_dat = ebi_dat[ebi_dat$pval.exposure <= 5e-08,]

#Remove SNPs without effect and other alleles
ebi_dat = ebi_dat[which(!is.na(ebi_dat$effect_allele.exposure) | !is.na(ebi_dat$other_allele.exposure)),]

#############################################################################################################

#Downloaded SNPs
download_snps = read.csv("download_snps_bp.csv",header = TRUE,stringsAsFactors = FALSE)
download_snps = rename(download_snps, id.exposure = ï..id.exposure)
download_snps = download_snps[download_snps$pval.exposure <= 5e-08,]

#############################################################################################################

#Smoking SNPs from Robyn/GSCAN (minus UK Biobank & 23andMe)
x = read.delim(paste(gscan_path,"\\smoking_initiation.txt",sep=""),sep="",header=TRUE,stringsAsFactors = FALSE)
y = x[x$PVALUE<=5e-08,]
y$trait = "Smoking Initation"

x = read.delim(paste(gscan_path,"\\alcohol intake.txt",sep=""),sep="",header=TRUE,stringsAsFactors = FALSE)
x = x[x$PVALUE<=5e-08,]
x$trait = "Alcohol Intake"

y = rbind(x,y)

#Rename to fit with others
smoke_dat = data.frame(y$trait,stringsAsFactors = FALSE)
smoke_dat = rename(smoke_dat,id.exposure = "y.trait")
smoke_dat$SNP = y$RSID
smoke_dat$effect_allele.exposure = y$ALT
smoke_dat$other_allele.exposure = y$REF
smoke_dat$eaf.exposure = NA
smoke_dat$beta.exposure = y$BETA
smoke_dat$samplesize.exposure = y$N
smoke_dat$ncase.exposure = NA
smoke_dat$ncontrol.exposure = NA
smoke_dat$pval.exposure = y$PVALUE
smoke_dat$se.exposure = y$SE
smoke_dat$units.exposure = NA
smoke_dat$exposure = y$trait
smoke_dat$mr_keep.exposure = TRUE
smoke_dat$pval_origin.exposure = "reported"
smoke_dat$data_source.exposure = "GSCAN (excl. UK Biobank & 23andMe)"
smoke_dat$clumped = FALSE
smoke_dat$priority = 1
smoke_dat$trait = y$trait

smoke_dat$id.exposure[smoke_dat$id.exposure == "Smoking Initiation"] = "s1"
smoke_dat$id.exposure[smoke_dat$id.exposure == "Smoking Cessation"] = "s2"
#Smoking cessation has been removed from analysis
smoke_dat = smoke_dat[smoke_dat$id.exposure != "s2",]
smoke_dat$id.exposure[smoke_dat$id.exposure == "Alcohol Intake"] = "s3"

#############################################################################################################

#Combine all data
exposure_dat = bind_rows(dat8, ebi_dat, smoke_dat, download_snps)

mrbase_grs(output="code", exposure_dat = exposure_dat,suffix="_8",ipd=TRUE)

#############################################################################################################





#End of main analysis





#############################################################################################################

#Code for smoking intensity SNP - rs1051730
download_snps = read.csv("rs1051730.csv",header = TRUE,stringsAsFactors = FALSE)
download_snps = rename(download_snps, id.exposure = ï..id.exposure)
download_snps$effect_allele.exposure = "T"
mrbase_grs(output="code", exposure_dat = download_snps,suffix="_rs1051730",ipd=TRUE,proxies = FALSE)

#############################################################################################################


#Supplementary Table 2 - PRS
table_3 = ebi[,c("STUDY.ACCESSION","PubmedID","Author","Year")]
table_3 = unique(table_3)
table_3 = rename(table_3,GWAS_ID = STUDY.ACCESSION,Pubmed_ID = PubmedID)
table_3$Consortium = NA

ao = available_outcomes()
studies_list = c(8,26,44,307,835,996,1000,1187)
ao = ao[which(ao$id %in% studies_list),c("author","consortium","id","pmid","year")]
ao = rename(ao, Author=author, Consortium = consortium, GWAS_ID = id, Pubmed_ID = pmid, Year = year)

table_3 = rbind(table_3,ao)

write.csv(table_3,paste(tables_path,"\\Table 2 (R).csv",sep=""),row.names=FALSE)


