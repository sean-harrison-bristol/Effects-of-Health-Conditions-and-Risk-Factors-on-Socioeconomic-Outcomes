#Folder paths
folder_path = ""
data_path = paste(folder_path,"/Stata",sep="")
wd_path = paste(data_path,"/Graphs",sep="")
mr_wd_path = paste(wd_path,"/Main analysis",sep="")
mr_ss_wd_path = paste(wd_path,"/Split sample",sep="")
figure_path = paste(folder_path,"/manuscript/figures",sep="")

#Create MR graphs from main analysis
setwd(wd_path)

library(TwoSampleMR)
library(MRInstruments)
library(data.table)
library("ggplot2")
library(plyr); library(dplyr)

dat = read.csv("mr_analysis.csv",stringsAsFactors = FALSE)
dat = rename(dat,effect_allele.outcome = effect_allele_outcome, eaf.outcome = eaf_outcome, beta.outcome = beta_outcome, se.outcome = se_outcome,
             pval.outcome = pval_outcome, ncase.outcome = ncases_outcome, ncontrol.outcome = ncontrol_outcome, beta.exposure = beta_exposure,
             se.exposure = se_exposure, id.exposure = id_exposure, id.outcome = id_outcome)

dat$mr_keep = TRUE

#MR plots
setwd(mr_wd_path)
res <- mr(dat)
p1 <- mr_scatter_plot(res, dat)

x = res[res$method == "Inverse variance weighted" | res$method == "Wald ratio",c("outcome","exposure")]

for(i in 1:length(p1)){
  exposure = x$outcome[i]
  exposure = gsub("/"," per ",exposure)
  outcome = x$exposure[i]
  outcome = gsub("/"," per ",outcome)
  outcome = gsub("Â","",outcome)
  ggsave(p1[[i]], file=paste("IVW/",outcome," - ",exposure,".png",sep=""), width=7, height=7)
}

#Forest plots
res_single <- mr_singlesnp(dat)
p2 <- mr_forest_plot(res_single)

for(i in 1:length(p2)){
  exposure = x$outcome[i]
  exposure = gsub("/"," per ",exposure)
  outcome = x$exposure[i]
  outcome = gsub("/"," per ",outcome)
  ggsave(p2[[i]], file=paste("Forest plots/",outcome," - ",exposure,".png",sep=""), width=7, height=7)
}

#############################################################################

#Split sample plots
setwd(wd_path)

dat = read.csv("split_sample.csv",stringsAsFactors = FALSE)
dat = rename(dat,effect_allele.outcome = effect_allele_outcome, eaf.outcome = eaf_outcome, beta.outcome = beta_outcome, se.outcome = se_outcome,
             pval.outcome = pval_outcome, ncase.outcome = ncases_outcome, ncontrol.outcome = ncontrol_outcome, beta.exposure = beta_exposure,
             se.exposure = se_exposure, id.exposure = id_exposure, id.outcome = id_outcome)

dat$mr_keep = TRUE

#MR plots
setwd(mr_ss_wd_path)
res <- mr(dat)
p1 <- mr_scatter_plot(res, dat)

x = res[res$method == "Inverse variance weighted" | res$method == "Wald ratio",c("outcome","exposure")]

for(i in 1:length(p1)){
  exposure = x$outcome[i]
  exposure = gsub("/"," per ",exposure)
  outcome = x$exposure[i]
  outcome = gsub("/"," per ",outcome)
  ggsave(p1[[i]], file=paste("IVW/",outcome," - ",exposure,".png",sep=""), width=7, height=7)
}

#Forest plots
res_single <- mr_singlesnp(dat)
p2 <- mr_forest_plot(res_single)

for(i in 1:length(p2)){
  exposure = x$outcome[i]
  exposure = gsub("/"," per ",exposure)
  outcome = x$exposure[i]  
  outcome = gsub("/"," per ",outcome)
  ggsave(p2[[i]], file=paste("Forest plots/",outcome," - ",exposure,".png",sep=""), width=7, height=7)
}

##############################################################################

#Heat maps for main results
library(ggplot2)

setwd(data_path)
heatmap = read.csv("Tables\\Main results P.csv",stringsAsFactors = FALSE)
heatmap$effect[heatmap$p2>0] = 1
heatmap$effect[heatmap$p2<0] = -1
heatmap$p2 = abs(heatmap$p2)
heatmap$value2[heatmap$effect == 1] = "+"
heatmap$value2[heatmap$effect == -1] = "-"

ggplot(data = heatmap, aes(Exposure, Outcome, fill = p2))+
  geom_tile(color = "grey")+
  geom_text(aes(label = value))+
  geom_text(aes(label = value2),nudge_y=-0.3,size = 2)+
  scale_fill_gradient2(low = "white", high = "blue", mid = "cornflowerblue", 
                       midpoint = 10, limit = c(0,20), space = "Lab", guide = "legend",
                       name="-log10\nP value") +
  theme_minimal()+ 
  theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                   size = 8, hjust = 1))+
  labs(x = "Health Condition/Risk Factor") +
  facet_wrap(~ outcome_type, dir="v",scales="free",strip.position="top",shrink=FALSE)

ggsave(file="Graphs\\Results\\Main analysis P.png", dpi=1200,height=6, width = 6)

#And for sex/dep at birth
for(k in c("male","female","low","mid","high")){
  heatmap = read.csv(paste("Tables\\Results P (",k,").csv",sep=""),stringsAsFactors = FALSE)
  heatmap$effect[heatmap$p2>0] = 1
  heatmap$effect[heatmap$p2<0] = -1
  heatmap$p2 = abs(heatmap$p2)
  heatmap$value2[heatmap$effect == 1] = "+"
  heatmap$value2[heatmap$effect == -1] = "-"

  if(k == "male"){
      k2 = "Male"
  }
  if(k == "female"){
    k2 = "Female"
  }
  if(k == "low"){
    k2 = "Low deprivation at birth"
  }
  if(k == "mid"){
    k2 = "Mid deprivation at birth"
  }
  if(k == "high"){
    k2 = "High deprivation at birth"
  }
  
  ggplot(data = heatmap, aes(Exposure, Outcome, fill = p2))+
    geom_tile(color = "grey")+
    geom_text(aes(label = value))+
    geom_text(aes(label = value2),nudge_y=-0.3,size = 2)+
    scale_fill_gradient2(low = "white", high = "blue", mid = "cornflowerblue", 
                         midpoint = 10, limit = c(0,20), space = "Lab", guide = "legend",
                         name="-log10\nP value") +
    theme_minimal()+ 
    theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                     size = 8, hjust = 1))+
    ggtitle(k2) +
    labs(x = "Health Condition/Risk Factor") +
    facet_wrap(~ outcome_type, dir="v",scales="free",strip.position="top",shrink=FALSE)  
  
  ggsave(file=paste("Graphs\\Results\\Analysis P (",k,").png",sep=""), dpi = 1200,height=6, width = 6)
}

#Split sample
heatmap = read.csv("Tables\\Split results P.csv",stringsAsFactors = FALSE)
heatmap$effect[heatmap$p2>0] = 1
heatmap$effect[heatmap$p2<0] = -1
heatmap$p2 = abs(heatmap$p2)
heatmap$value2[heatmap$effect == 1] = "+"
heatmap$value2[heatmap$effect == -1] = "-"

ggplot(data = heatmap, aes(Exposure, Outcome, fill = p2))+
  geom_tile(color = "grey")+
  geom_text(aes(label = value))+
  geom_text(aes(label = value2),nudge_y=-0.3,size = 2)+
  scale_fill_gradient2(low = "white", high = "blue", mid = "cornflowerblue", 
                       midpoint = 20.75, limit = c(0,41.5), space = "Lab", guide = "legend",
                       name="-log10\nP value") +
  theme_minimal()+ 
  theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                   size = 8, hjust = 1))+
  labs(x = "Health Condition/Risk Factor")+
  facet_wrap(~ outcome_type, dir="v",scales="free",strip.position="top",shrink=FALSE)

ggsave(file="Graphs\\Results\\Split analysis P.png", dpi=1200,height=6, width = 6)


#MR results
heatmap = read.csv("Tables\\MR results P.csv",stringsAsFactors = FALSE)
heatmap$effect[heatmap$p2>0] = 1
heatmap$effect[heatmap$p2<0] = -1
heatmap$p2 = abs(heatmap$p2)
heatmap$value2[heatmap$effect == 1] = "+"
heatmap$value2[heatmap$effect == -1] = "-"

ggplot(data = heatmap, aes(Exposure, Outcome, fill = p2))+
  geom_tile(color = "grey")+
  geom_text(aes(label = value))+
  geom_text(aes(label = value2),nudge_y=-0.3,size = 2)+
  scale_fill_gradient2(low = "white", high = "blue", mid = "cornflowerblue", 
                       midpoint = 10, limit = c(0,20), space = "Lab", guide = "legend",
                       name="-log10\nP value") +
  theme_minimal()+ 
  theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                   size = 8, hjust = 1))+

  labs(x = "Health Condition/Risk Factor") +
  facet_wrap(~ outcome_type, dir="v",scales="free",strip.position="top")

ggsave(file="Graphs\\Results\\MR analysis P.png", dpi=1200,height=6, width = 6)

#############################################################################

#Forest plots for ALL analyses
setwd(data_path)
#install.packages("forestplot")
library(forestplot)

master_data = read.csv("Tables\\metan_r.csv",stringsAsFactors = FALSE)

#By Exposure
#Iterate through social/socioeconomic outcomes for all health conditions/risk factors
x_list = c("Social Contact and Wellbeing","Socioeconomic")
y_list = unique(master_data$exposure)
for(x in x_list){
  for(y in y_list) {
  
    data = master_data[master_data$outcome_type == x,]
    data = data[data$exposure == y,]
    data = data[order(data$outcome,data$type),]
    tabletext = cbind(unique(data$outcome))
    exposure_type = data$exposure_type[1]
    
    if(x == "Socioeconomic"){
      height = 800
      width = 600
      xlab_size = 1.2
      xtick_size = 1
      label_size = 1.2
      hrzl_lines = list("1"=gpar(lty=1),"2"=gpar(lty=2),"3"=gpar(lty=2),"4"=gpar(lty=2),"5"=gpar(lty=2),
                     "6"=gpar(lty=2),"7"=gpar(lty=2),"8"=gpar(lty=2),"9"=gpar(lty=1))
    } else {
      height = 800
      width = 600
      xlab_size = 1.2
      xtick_size = 1
      label_size = 1.2
      hrzl_lines = list("1"=gpar(lty=1),"2"=gpar(lty=2),"3"=gpar(lty=2),"4"=gpar(lty=2),"5"=gpar(lty=2),
                     "6"=gpar(lty=2),"7"=gpar(lty=2),"8"=gpar(lty=2),"9"=gpar(lty=2),"10"=gpar(lty=2),
                     "11"=gpar(lty=2),"12"=gpar(lty=1))
    }
    
    title = paste(y," - ",x,sep="")
    filename = paste("Graphs\\Forest plots\\By Exposure\\",gsub("/"," per ",y)," - ",x,".png",sep="")
    png(file=filename, width = width, height = height) 
    
    group = median(data$group)
    
    if(group == 0){
      xticks = c(-5,-4,-3,-2,-1, 0, 1,2,3,4, 5)
    } else if(group == 1){
      xticks = c(-10,-8,-6, -4, -2, 0, 2, 4,6, 8,10)
    } else if(group == 2){
      xticks = c(-20,-15, -10, -5, 0,5, 10, 15, 20)
    } else if(group == 3){
      xticks = c(-30,-20,-10, 0, 10, 20,30)
    } else if(group == 4){
      xticks = c(-40,-30, -20, -10, 0,10, 20, 30, 40)
    } else if(group == 5){
      xticks = c(-50,-40,-30, -20, -10, 0, 10, 20,30, 40,50)
    } else if(group == 6){
      xticks = c(-60,-40, -20, 0, 20, 40, 60)
    } else if(group == 7){
      xticks = c(-70,-50,-30, -10, 0, 10,30, 50,70)
    } else if(group == 8){
      xticks = c(-80,-60, -40, -20, 0,20, 40, 60, 80)
    } else if(group == 9){
      xticks = c(-90,-60, -30, 0,30, 60, 90)
    } else {
      xticks = c(-100,-75, -50, -25, 0, 25, 50,75, 100)
    }
    
    if(x == "Socioeconomic" & y == "Body Mass Index (5 kg/m2)"){
      xticks = c(-12,-10,-8,-6, -4, -2, 0, 2, 4,6, 8,10,12)
    }
    if(exposure_type == "Health Condition"){
      xticks = c(-50,-40,-30, -20, -10, 0, 10, 20,30, 40,50)
    }
    
    
    forestplot(tabletext, 
               legend = c("Main Analysis MR", "Split-Sample MR","Multivariable Adjusted"),
                title = title,
               mean = cbind(data$beta[data$type == "Main Analysis MR"], data$beta[data$type == "Split-Sample MR"], 
                            data$beta[data$type == "Multivariable Adjusted"]),
               lower = cbind(data$lower[data$type == "Main Analysis MR"], data$lower[data$type == "Split-Sample MR"], 
                            data$lower[data$type == "Multivariable Adjusted"]),
               upper = cbind(data$upper[data$type == "Main Analysis MR"], data$upper[data$type == "Split-Sample MR"], 
                            data$upper[data$type == "Multivariable Adjusted"]),
               clip = xticks,
               col=fpColors(box=c("blue", "darkred","black"),
                            zero=c("darkblue")),
               boxsize = 0.1,
               line.margin = 0.2,
               xticks = xticks,
               grid = TRUE,
               hrzl_lines=hrzl_lines,
               txt_gp = fpTxtGp(xlab=gpar(cex=xlab_size),
                                ticks = gpar(cex=xtick_size),
                                label = gpar(cex=label_size)),
                xlab = "Absolute Percentage Change"
    )
    dev.off() 
  }
}  

#By Outcome
x_list = unique(master_data$outcome)
y_list = unique(master_data$exposure_type)

for(x in x_list){
  for(y in y_list) {
    data = master_data[master_data$exposure_type == y,]
    data = data[data$outcome == x,]
    data = data[order(data$outcome,data$type),]
    tabletext = unique(data$exposure)
    
    height = 800
    width = 600
    xlab_size = 1.2
    xtick_size = 1
    label_size = 1.2
    if(y == "Risk Factor"){
      hrzl_lines = list("1"=gpar(lty=1),"2"=gpar(lty=2),"3"=gpar(lty=2),"4"=gpar(lty=2),"5"=gpar(lty=2),
                        "6"=gpar(lty=2),"7"=gpar(lty=1))
    } else {
      hrzl_lines = list("1"=gpar(lty=1),"2"=gpar(lty=2),"3"=gpar(lty=2),"4"=gpar(lty=2),"5"=gpar(lty=2),
                        "6"=gpar(lty=2),"7"=gpar(lty=2),"8"=gpar(lty=2),"9"=gpar(lty=1))
    }
    
    title = paste(x," - ",y,sep="")
    filename = paste("Graphs\\Forest plots\\By Outcome\\",x," - ",y,".png",sep="")
    png(file=filename, width = width, height = height) 
    
    if(x == "Household Income"){
      xticks = c(-60,-50,-40,-30,-20,-10,0,10,20)
      xlab = "Change in Household Income (£1,000s)"
    } else if(x == "Household Income (retired excluded)"){
      xticks = c(-60,-50,-40,-30,-20,-10,0,10)
      xlab = "Change in Household Income (£1,000s)"
    } else if(x == "Deprivation at Recruitment" & y == "Health Condition"){
      xticks = c(-1,0,1,2,3,4,5)
      xlab = "Change in Townsend Deprivation Index"
    } else if(x == "Deprivation at Recruitment"){
      xticks = c(-1,0,1,2,3)
      xlab = "Change in Townsend Deprivation Index"
    } else if(y != "Health Condition") {
      xticks = c(-30, -20, -10, 0, 10, 20)
      xlab = "Absolute percentage change"
    } else {
      xticks = c(-50,-40,-30, -20, -10, 0, 10, 20,30, 40,50)
      xlab = "Absolute percentage change"
    }
    
    forestplot(tabletext, 
               legend = c("Main Analysis", "Split-Sample","Multivariable Adjusted"),
               title = title,
               mean = cbind(data$beta[data$type == "Main Analysis MR"], data$beta[data$type == "Split-Sample MR"], 
                            data$beta[data$type == "Multivariable Adjusted"]),
               lower = cbind(data$lower[data$type == "Main Analysis MR"], data$lower[data$type == "Split-Sample MR"], 
                             data$lower[data$type == "Multivariable Adjusted"]),
               upper = cbind(data$upper[data$type == "Main Analysis MR"], data$upper[data$type == "Split-Sample MR"], 
                             data$upper[data$type == "Multivariable Adjusted"]),
               clip = xticks,
               col=fpColors(box=c("blue", "darkred","black"),
                            zero=c("darkblue")),
               boxsize = 0.1,
               line.margin = 0.2,
               xticks = xticks,
               grid = TRUE,
               hrzl_lines=hrzl_lines,
               txt_gp = fpTxtGp(xlab=gpar(cex=xlab_size),
                                ticks = gpar(cex=xtick_size),
                                label = gpar(cex=label_size)),
               xlab = xlab
    )
    dev.off() 
  }
}

#####################################################################################################################################
#Figures for manuscript - colour

library(ggplot2)
library(forestplot)

#Figure 1
setwd(data_path)
heatmap = read.csv("Tables\\Main results P.csv",stringsAsFactors = FALSE)
heatmap$effect[heatmap$p2>0] = 1
heatmap$effect[heatmap$p2<0] = -1
heatmap$p2 = abs(heatmap$p2)
heatmap$value2[heatmap$effect == 1] = "+"
heatmap$value2[heatmap$effect == -1] = "-"

ggplot(data = heatmap, aes(Exposure, Outcome, fill = p2))+
  geom_tile(color = "grey")+
  geom_text(aes(label = value))+
  geom_text(aes(label = value2),nudge_y=-0.3,size = 2)+
  scale_fill_gradient2(low = "white", high = "blue", mid = "cornflowerblue", 
                       midpoint = 10, limit = c(0,20), space = "Lab", guide = "legend",
                       name="-log10\nP value") +
  theme_minimal()+ 
  theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                   size = 8, hjust = 1))+
  labs(x = "Health Condition/Risk Factor") +
  facet_wrap(~ outcome_type, dir="v",scales="free",strip.position="top",shrink=FALSE)

ggsave(file=paste(figure_path,"\\Figure 1.tiff",sep=""), dpi=600, height=6, width = 6,compression="lzw")

#Figures 2-5
#By Outcome
master_data = read.csv("Tables\\metan_r.csv",stringsAsFactors = FALSE)
x_list = c("Household Income","Lonely")
y_list = c("Health Condition","Risk Factor")
i=1

for(x in x_list){
  for(y in y_list) {
    i=i+1
    data = master_data[master_data$exposure_type == y,]
    data = data[data$outcome == x,]
    data = data[order(data$outcome,data$type),]
    tabletext = unique(data$exposure)
    
    height = 10
    width = 8
    xlab_size = 1.2
    xtick_size = 1
    label_size = 1.2
    if(y == "Risk Factor"){
      hrzl_lines = list("1"=gpar(lty=1),"2"=gpar(lty=2),"3"=gpar(lty=2),"4"=gpar(lty=2),"5"=gpar(lty=2),
                        "6"=gpar(lty=2),"7"=gpar(lty=1))
    } else {
      hrzl_lines = list("1"=gpar(lty=1),"2"=gpar(lty=2),"3"=gpar(lty=2),"4"=gpar(lty=2),"5"=gpar(lty=2),
                        "6"=gpar(lty=2),"7"=gpar(lty=2),"8"=gpar(lty=2),"9"=gpar(lty=1))
    }
    
    title = paste(x," - ",y,sep="")
    filename = paste(figure_path,"\\Figure ",i,".tiff",sep="")
    tiff(file=filename, res=600, width = width, height = height,units = "in",compression="lzw") 
    
    if(x == "Household Income" & y == "Risk Factor"){
      xticks = c(-40,-30,-20,-10,0,10)
      xlab = "Change in Household Income (£1,000s)"
    } else if(x == "Household Income" & y == "Health Condition"){
      xticks = c(-60,-50,-40,-30,-20,-10,0,10,20)
      xlab = "Change in Household Income (£1,000s)"
    } else if(x == "Lonely" & y == "Risk Factor") {
      xticks = c(-5, 0, 5, 10, 15, 20)
      xlab = "Absolute percentage change"
    } else {
      xticks = c(-30, -20, -10, 0, 10, 20,30, 40,50,60,70,80)
      xlab = "Absolute percentage change"
    }
    
    forestplot(tabletext, 
               legend = c("Main Analysis", "Split-Sample","Multivariable Adjusted"),
               title = title,
               mean = cbind(data$beta[data$type == "Main Analysis MR"], data$beta[data$type == "Split-Sample MR"], 
                            data$beta[data$type == "Multivariable Adjusted"]),
               lower = cbind(data$lower[data$type == "Main Analysis MR"], data$lower[data$type == "Split-Sample MR"], 
                             data$lower[data$type == "Multivariable Adjusted"]),
               upper = cbind(data$upper[data$type == "Main Analysis MR"], data$upper[data$type == "Split-Sample MR"], 
                             data$upper[data$type == "Multivariable Adjusted"]),
               clip = xticks,
               col=fpColors(box=c("blue", "darkred","black"),
                            zero=c("darkblue")),
               boxsize = 0.1,
               line.margin = 0.2,
               xticks = xticks,
               grid = TRUE,
               hrzl_lines=hrzl_lines,
               txt_gp = fpTxtGp(xlab=gpar(cex=xlab_size),
                                ticks = gpar(cex=xtick_size),
                                label = gpar(cex=label_size)),
               xlab = xlab
    )
    dev.off() 
  }
}

#####################################################################################################################################
#Figures for manuscript - greyscale

#Figure 1
setwd(data_path)
heatmap = read.csv("Tables\\Main results P.csv",stringsAsFactors = FALSE)
heatmap$effect[heatmap$p2>0] = 1
heatmap$effect[heatmap$p2<0] = -1
heatmap$p2 = abs(heatmap$p2)
heatmap$value2[heatmap$effect == 1] = "+"
heatmap$value2[heatmap$effect == -1] = "-"

library(ggplot2)
library(forestplot)

ggplot(data = heatmap, aes(Exposure, Outcome, fill = p2))+
  geom_tile(color = "grey")+
  geom_text(aes(label = value))+
  geom_text(aes(label = value2),nudge_y=-0.3,size = 2)+
  scale_fill_gradient2(low = "gray100", high = "gray30", mid = "gray65", 
                       midpoint = 10, limit = c(0,20), space = "Lab", guide = "legend",
                       name="-log10\nP value") +
  theme_minimal()+ 
  theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                   size = 8, hjust = 1))+
  labs(x = "Health Condition/Risk Factor") +
  facet_wrap(~ outcome_type, dir="v",scales="free",strip.position="top",shrink=FALSE)

ggsave(file=paste(figure_path,"\\Figure 1 (gs).tiff",sep=""), dpi=600, height=6, width = 6,compression="lzw")

#Figures 2-5
#By Outcome
master_data = read.csv("Tables\\metan_r.csv",stringsAsFactors = FALSE)
x_list = c("Household Income","Lonely")
y_list = c("Health Condition","Risk Factor")
i=1

for(x in x_list){
  for(y in y_list) {
    i=i+1
    data = master_data[master_data$exposure_type == y,]
    data = data[data$outcome == x,]
    data = data[order(data$outcome,data$type),]
    tabletext = unique(data$exposure)
    
    height = 10
    width = 8
    xlab_size = 1.2
    xtick_size = 1
    label_size = 1.2
    if(y == "Risk Factor"){
      hrzl_lines = list("1"=gpar(lty=1),"2"=gpar(lty=2),"3"=gpar(lty=2),"4"=gpar(lty=2),"5"=gpar(lty=2),
                        "6"=gpar(lty=2),"7"=gpar(lty=1))
    } else {
      hrzl_lines = list("1"=gpar(lty=1),"2"=gpar(lty=2),"3"=gpar(lty=2),"4"=gpar(lty=2),"5"=gpar(lty=2),
                        "6"=gpar(lty=2),"7"=gpar(lty=2),"8"=gpar(lty=2),"9"=gpar(lty=1))
    }
    
    title = paste(x," - ",y,sep="")
    filename = paste(figure_path,"\\Figure ",i," (gs).tiff",sep="")
    tiff(file=filename, res=600, width = width, height = height,units = "in",compression="lzw") 
    
    if(x == "Household Income" & y == "Risk Factor"){
      xticks = c(-40,-30,-20,-10,0,10)
      xlab = "Change in Household Income (£1,000s)"
    } else if(x == "Household Income" & y == "Health Condition"){
      xticks = c(-60,-50,-40,-30,-20,-10,0,10,20)
      xlab = "Change in Household Income (£1,000s)"
    } else if(x == "Lonely" & y == "Risk Factor") {
      xticks = c(-5, 0, 5, 10, 15, 20)
      xlab = "Absolute percentage change"
    } else {
      xticks = c(-30, -20, -10, 0, 10, 20,30, 40,50,60,70,80)
      xlab = "Absolute percentage change"
    }
    
    forestplot(tabletext, 
               legend = c("Main Analysis", "Split-Sample","Multivariable Adjusted"),
               title = title,
               mean = cbind(data$beta[data$type == "Main Analysis MR"], data$beta[data$type == "Split-Sample MR"], 
                            data$beta[data$type == "Multivariable Adjusted"]),
               lower = cbind(data$lower[data$type == "Main Analysis MR"], data$lower[data$type == "Split-Sample MR"], 
                             data$lower[data$type == "Multivariable Adjusted"]),
               upper = cbind(data$upper[data$type == "Main Analysis MR"], data$upper[data$type == "Split-Sample MR"], 
                             data$upper[data$type == "Multivariable Adjusted"]),
               clip = xticks,
               col=fpColors(box=c("grey", "grey32","black"),
                            zero=c("black")),
               boxsize = 0.1,
               line.margin = 0.2,
               xticks = xticks,
               grid = TRUE,
               hrzl_lines=hrzl_lines,
               txt_gp = fpTxtGp(xlab=gpar(cex=xlab_size),
                                ticks = gpar(cex=xtick_size),
                                label = gpar(cex=label_size)),
               xlab = xlab
    )
    dev.off() 
  }
}