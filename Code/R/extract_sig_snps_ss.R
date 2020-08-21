#Folder paths
source_path = ""
wd_path = ""

#Take the significant SNPs from the split sample GWAS & run the mrbase_grs script to create PRS

setwd(wd_path)

print("starting")
sig_list = read.delim("sig_list.txt",stringsAsFactors=FALSE,header = FALSE)

snps = read.delim(sig_list$V1[1],stringsAsFactors = FALSE,sep="")

trait = gsub("_a_imputed.txt","",sig_list$V1[1])
trait = gsub("_"," ",trait)
snps$trait = trait
snps$id = 1

sig_list = sig_list[sig_list$V1 != sig_list$V1[1],]

j=2
for(i in sig_list){
  print(paste("i = ",i,sep=""))
  x = read.table(i,stringsAsFactors=FALSE)
  x$CHISQ_BOLT_LMM = NULL
  x$P_BOLT_LMM = NULL
  trait = gsub("_a_imputed.txt","",i)
  trait = gsub("_"," ",trait)
  x$trait = trait
  x$id = j
  snps = rbind(snps,x)
  j = j + 1 
}

table(snps$trait)

source(paste(source_path,"\\mrbase_grs_v2.02.r",sep=""))

#Coerce to mrbase_grs format

ebi_dat = data.frame(snps$SNP)
ebi_dat$id.exposure = snps$id
ebi_dat$effect_allele.exposure = snps$ALLELE1
ebi_dat$other_allele.exposure = snps$ALLELE0
ebi_dat$eaf.exposure = snps$A1FREQ
ebi_dat$beta.exposure = snps$BETA
ebi_dat$samplesize.exposure = NA
ebi_dat$ncase.exposure = NA
ebi_dat$ncontrol.exposure = NA
ebi_dat$pval.exposure = snps$P_BOLT_LMM_INF
ebi_dat$se.exposure = snps$SE
ebi_dat$units.exposure = "log-OR"
ebi_dat$exposure = snps$trait
ebi_dat$mr_keep.exposure = TRUE
ebi_dat$pval_origin.exposure = "Bolt-LMM"
ebi_dat$data_source.exposure = "UK Biobank Split Sample"
ebi_dat$clumped = FALSE
ebi_dat$priority = 1
ebi_dat$trait = snps$trait

ebi_dat$trait = gsub("sig.txt","",ebi_dat$trait)
ebi_dat = rename(ebi_dat,"SNP"="snps.SNP")

mrbase_grs(output = "code",exposure_dat = ebi_dat, ipd = TRUE, clumped = FALSE, suffix = "_ss")