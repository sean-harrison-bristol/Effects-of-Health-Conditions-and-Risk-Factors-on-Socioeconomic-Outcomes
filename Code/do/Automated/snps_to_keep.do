**Do file to keep SNPs for each exposure
cd M:\projects\ieu2\_working\IEU2_P6_005\data\Stata\data
*Trait = Body_mass_index
use "snp_ipd.dta", clear
 
keep id_ieu rs1000940_ rs10132280_ rs1016287_ rs10182181_ rs10733682_ rs10938397_ rs10968576_ rs11030104_ rs11057405_ rs11165643_ rs1167827_ rs11727676_ rs12286929_ rs12429545_ rs12940622_ rs12986742_ rs13021737_ rs13078960_ rs13107325_ rs13191362_ rs1516725_ rs1528435_ rs1558902_ rs16851483_ rs16951275_ rs17001654_ rs17024393_ rs17066856_ rs17094222_ rs17405819_ rs17724992_ rs1808579_ rs1928295_ rs2033529_ rs2033732_ rs205262_ rs2112347_ rs2121279_ rs2176598_ rs2207139_ rs2245368_ rs2287019_ rs2365389_ rs2820292_ rs29941_ rs3101336_ rs3736485_ rs3817334_ rs3849570_ rs3888190_ rs4256980_ rs4740619_ rs4889606_ rs543874_ rs6477694_ rs6567160_ rs657452_ rs6656785_ rs6804842_ rs7138803_ rs7141420_ rs758747_ rs7599312_ rs7899106_ rs7903146_ rs879620_ rs9400239_ rs9579083_ rs9926784_ 
save "snps\snps_Body_mass_index.dta", replace
merge 1:1 id_ieu using "snps\outcomes.dta", nogen
gen snp = ""
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
        local out = substr("`outcome'",5,.)
        local out = subinstr("`out'","_"," ",.)
        *Continuous outcomes
        if "`out'" == "household income" | "`out'" == "tdi" | "`out'" == "household income re" | "`out'" == "household income equi" {
          qui regress `outcome' rs* age sex pc*
        }
        *Binary outcomes
        else {
          qui logit `outcome' rs* age sex pc*
        }
        
        foreach snp of varlist rs* {
        local snpx = substr("`snp'",1,length("`snp'")-2)
        qui replace snp = "`snpx'" in `i'  
        qui replace outcome = "`out'" in `i'
        
        qui replace beta = _b[`snp'] if snp == "`snpx'" & outcome == "`out'"
        qui replace se = _se[`snp'] if snp == "`snpx'" & outcome == "`out'"
        qui sum `snp'  
        qui replace eaf = r(mean)/2 if snp == "`snpx'"  
        local effect_allele = upper(substr("`snp'",length("`snp'"),1))
        qui replace effect_allele = "`effect_allele'" if snp == "`snpx'" 
        local i = `i'+1
        }
        }
        
        *Ns
        foreach outcome of varlist eco* soc* {
        *Continuous outcomes
        qui sum `outcome'
        local out = substr("`outcome'",5,.)
        local out = subinstr("`out'","_","",.)
        if "`out'" == "household income" | "`out'" == "tdi" | "`out'" == "household income re" | "`out'" == "household income equi" {
        qui replace n_total = r(N) if outcome == "`out'"
        }
        *Binary outcomes
        else {
        qui replace cases = r(N)*r(mean) if outcome == "`out'"
        qui replace controls = r(N)-r(N)*r(mean) if outcome == "`out'"
        qui replace n_total = r(N) if outcome == "`out'"
        }
        }
        
        keep snp-n_total
        keep if snp != ""
        qui replace p = 2*normal(-abs(beta/se))
save "snps\results_Body_mass_index.dta", replace

*Trait = breast_carcinoma
use "snp_ipd.dta", clear
 
keep id_ieu rs10022462_ rs10096351_ rs1011970_ rs10760444_ rs10816625_ rs10885405_ rs10941679_ rs10995201_ rs11117758_ rs11135046_ rs11199914_ rs11205303_ rs11249433_ rs113577745_ rs11571833_ rs11583393_ rs11624333_ rs11627032_ rs11684853_ rs117618124_ rs11822830_ rs11977670_ rs12207986_ rs12250948_ rs1230666_ rs12422552_ rs12479355_ rs12519859_ rs12546444_ rs1268974_ rs1292011_ rs13066793_ rs13267382_ rs1353747_ rs1552172_ rs1685191_ rs16991615_ rs1707302_ rs17156577_ rs17268829_ rs17356907_ rs17426269_ rs17838698_ rs1973765_ rs2016394_ rs202049448_ rs206966_ rs2403907_ rs2432539_ rs2506889_ rs2787486_ rs28512361_ rs2853669_ rs2965183_ rs2992756_ rs35383942_ rs3769821_ rs3821902_ rs3903072_ rs4233486_ rs4286946_ rs4442975_ rs4496150_ rs4562056_ rs4702131_ rs4784227_ rs4820318_ rs4848599_ rs4971059_ rs4973768_ rs527616_ rs56387622_ rs58058861_ rs6001982_ rs60954078_ rs6122906_ rs62048402_ rs62331150_ rs62355901_ rs62485509_ rs630965_ rs6436017_ rs6472903_ rs6562760_ rs6569648_ rs6596100_ rs6597981_ rs6725517_ rs6776003_ rs6787391_ rs68056147_ rs6815814_ rs6882649_ rs6904031_ rs7072776_ rs7149262_ rs71557345_ rs71559437_ rs7223535_ rs7258465_ rs72658071_ rs72755295_ rs7297051_ rs7500067_ rs7697216_ rs7707921_ rs77528541_ rs78540526_ rs7971_ rs848087_ rs9361840_ rs941764_ rs9693444_ rs9833888_ 
save "snps\snps_breast_carcinoma.dta", replace
merge 1:1 id_ieu using "snps\outcomes.dta", nogen
keep if sex == 0
gen snp = ""
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
        local out = substr("`outcome'",5,.)
        local out = subinstr("`out'","_"," ",.)
        *Continuous outcomes
        if "`out'" == "household income" | "`out'" == "tdi" | "`out'" == "household income re" | "`out'" == "household income equi" {
          qui regress `outcome' rs* age sex pc*
        }
        *Binary outcomes
        else {
          qui logit `outcome' rs* age sex pc*
        }
        
        foreach snp of varlist rs* {
        local snpx = substr("`snp'",1,length("`snp'")-2)
        qui replace snp = "`snpx'" in `i'  
        qui replace outcome = "`out'" in `i'
        
        qui replace beta = _b[`snp'] if snp == "`snpx'" & outcome == "`out'"
        qui replace se = _se[`snp'] if snp == "`snpx'" & outcome == "`out'"
        qui sum `snp'  
        qui replace eaf = r(mean)/2 if snp == "`snpx'"  
        local effect_allele = upper(substr("`snp'",length("`snp'"),1))
        qui replace effect_allele = "`effect_allele'" if snp == "`snpx'" 
        local i = `i'+1
        }
        }
        
        *Ns
        foreach outcome of varlist eco* soc* {
        *Continuous outcomes
        qui sum `outcome'
        local out = substr("`outcome'",5,.)
        local out = subinstr("`out'","_","",.)
        if "`out'" == "household income" | "`out'" == "tdi" | "`out'" == "household income re" | "`out'" == "household income equi" {
        qui replace n_total = r(N) if outcome == "`out'"
        }
        *Binary outcomes
        else {
        qui replace cases = r(N)*r(mean) if outcome == "`out'"
        qui replace controls = r(N)-r(N)*r(mean) if outcome == "`out'"
        qui replace n_total = r(N) if outcome == "`out'"
        }
        }
        
        keep snp-n_total
        keep if snp != ""
        qui replace p = 2*normal(-abs(beta/se))
save "snps\results_breast_carcinoma.dta", replace

*Trait = Major_Depressive_Disorder
use "snp_ipd.dta", clear
 
keep id_ieu rs10149470_ rs10950398_ rs10959913_ rs11135349_ rs11643192_ rs11663393_ rs11682175_ rs1226412_ rs12552_ rs12666117_ rs12958048_ rs1354115_ rs1363104_ rs1432639_ rs159963_ rs17727765_ rs1806153_ rs2005864_ rs2389016_ rs247910_ rs34215985_ rs4074723_ rs4904738_ rs5758265_ rs61867293_ rs62099069_ rs6905391_ rs7198928_ rs7430565_ rs76485002_ rs7856424_ rs8025231_ rs8063603_ rs915057_ rs9402472_ rs9427672_ 
save "snps\snps_Major_Depressive_Disorder.dta", replace
merge 1:1 id_ieu using "snps\outcomes.dta", nogen
keep if pilot == 0
gen snp = ""
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
        local out = substr("`outcome'",5,.)
        local out = subinstr("`out'","_"," ",.)
        *Continuous outcomes
        if "`out'" == "household income" | "`out'" == "tdi" | "`out'" == "household income re" | "`out'" == "household income equi" {
          qui regress `outcome' rs* age sex pc*
        }
        *Binary outcomes
        else {
          qui logit `outcome' rs* age sex pc*
        }
        
        foreach snp of varlist rs* {
        local snpx = substr("`snp'",1,length("`snp'")-2)
        qui replace snp = "`snpx'" in `i'  
        qui replace outcome = "`out'" in `i'
        
        qui replace beta = _b[`snp'] if snp == "`snpx'" & outcome == "`out'"
        qui replace se = _se[`snp'] if snp == "`snpx'" & outcome == "`out'"
        qui sum `snp'  
        qui replace eaf = r(mean)/2 if snp == "`snpx'"  
        local effect_allele = upper(substr("`snp'",length("`snp'"),1))
        qui replace effect_allele = "`effect_allele'" if snp == "`snpx'" 
        local i = `i'+1
        }
        }
        
        *Ns
        foreach outcome of varlist eco* soc* {
        *Continuous outcomes
        qui sum `outcome'
        local out = substr("`outcome'",5,.)
        local out = subinstr("`out'","_","",.)
        if "`out'" == "household income" | "`out'" == "tdi" | "`out'" == "household income re" | "`out'" == "household income equi" {
        qui replace n_total = r(N) if outcome == "`out'"
        }
        *Binary outcomes
        else {
        qui replace cases = r(N)*r(mean) if outcome == "`out'"
        qui replace controls = r(N)-r(N)*r(mean) if outcome == "`out'"
        qui replace n_total = r(N) if outcome == "`out'"
        }
        }
        
        keep snp-n_total
        keep if snp != ""
        qui replace p = 2*normal(-abs(beta/se))
save "snps\results_Major_Depressive_Disorder.dta", replace

*Trait = migraine_disorder
use "snp_ipd.dta", clear
 
keep id_ieu rs10155855_ rs10218452_ rs1024905_ rs10456100_ rs10895275_ rs11031122_ rs11172113_ rs11624776_ rs12260159_ rs1268083_ rs13078967_ rs138556413_ rs144017103_ rs1572668_ rs17857135_ rs186166891_ rs1925950_ rs2078371_ rs2223089_ rs2506142_ rs4081947_ rs4814864_ rs4839827_ rs4910165_ rs561561_ rs566529_ rs6478241_ rs6791480_ rs75213074_ rs9349379_ 
save "snps\snps_migraine_disorder.dta", replace
merge 1:1 id_ieu using "snps\outcomes.dta", nogen
gen snp = ""
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
        local out = substr("`outcome'",5,.)
        local out = subinstr("`out'","_"," ",.)
        *Continuous outcomes
        if "`out'" == "household income" | "`out'" == "tdi" | "`out'" == "household income re" | "`out'" == "household income equi" {
          qui regress `outcome' rs* age sex pc*
        }
        *Binary outcomes
        else {
          qui logit `outcome' rs* age sex pc*
        }
        
        foreach snp of varlist rs* {
        local snpx = substr("`snp'",1,length("`snp'")-2)
        qui replace snp = "`snpx'" in `i'  
        qui replace outcome = "`out'" in `i'
        
        qui replace beta = _b[`snp'] if snp == "`snpx'" & outcome == "`out'"
        qui replace se = _se[`snp'] if snp == "`snpx'" & outcome == "`out'"
        qui sum `snp'  
        qui replace eaf = r(mean)/2 if snp == "`snpx'"  
        local effect_allele = upper(substr("`snp'",length("`snp'"),1))
        qui replace effect_allele = "`effect_allele'" if snp == "`snpx'" 
        local i = `i'+1
        }
        }
        
        *Ns
        foreach outcome of varlist eco* soc* {
        *Continuous outcomes
        qui sum `outcome'
        local out = substr("`outcome'",5,.)
        local out = subinstr("`out'","_","",.)
        if "`out'" == "household income" | "`out'" == "tdi" | "`out'" == "household income re" | "`out'" == "household income equi" {
        qui replace n_total = r(N) if outcome == "`out'"
        }
        *Binary outcomes
        else {
        qui replace cases = r(N)*r(mean) if outcome == "`out'"
        qui replace controls = r(N)-r(N)*r(mean) if outcome == "`out'"
        qui replace n_total = r(N) if outcome == "`out'"
        }
        }
        
        keep snp-n_total
        keep if snp != ""
        qui replace p = 2*normal(-abs(beta/se))
save "snps\results_migraine_disorder.dta", replace

*Trait = Coronary_heart_disease
use "snp_ipd.dta", clear
 
keep id_ieu rs10455872_ rs1122608_ rs11556924_ rs12190287_ rs1333045_ rs17114036_ rs2219939_ rs2306374_ rs2351524_ rs4714955_ rs599839_ rs7651039_ rs9351814_ rs964184_ rs9982601_ 
save "snps\snps_Coronary_heart_disease.dta", replace
merge 1:1 id_ieu using "snps\outcomes.dta", nogen
gen snp = ""
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
        local out = substr("`outcome'",5,.)
        local out = subinstr("`out'","_"," ",.)
        *Continuous outcomes
        if "`out'" == "household income" | "`out'" == "tdi" | "`out'" == "household income re" | "`out'" == "household income equi" {
          qui regress `outcome' rs* age sex pc*
        }
        *Binary outcomes
        else {
          qui logit `outcome' rs* age sex pc*
        }
        
        foreach snp of varlist rs* {
        local snpx = substr("`snp'",1,length("`snp'")-2)
        qui replace snp = "`snpx'" in `i'  
        qui replace outcome = "`out'" in `i'
        
        qui replace beta = _b[`snp'] if snp == "`snpx'" & outcome == "`out'"
        qui replace se = _se[`snp'] if snp == "`snpx'" & outcome == "`out'"
        qui sum `snp'  
        qui replace eaf = r(mean)/2 if snp == "`snpx'"  
        local effect_allele = upper(substr("`snp'",length("`snp'"),1))
        qui replace effect_allele = "`effect_allele'" if snp == "`snpx'" 
        local i = `i'+1
        }
        }
        
        *Ns
        foreach outcome of varlist eco* soc* {
        *Continuous outcomes
        qui sum `outcome'
        local out = substr("`outcome'",5,.)
        local out = subinstr("`out'","_","",.)
        if "`out'" == "household income" | "`out'" == "tdi" | "`out'" == "household income re" | "`out'" == "household income equi" {
        qui replace n_total = r(N) if outcome == "`out'"
        }
        *Binary outcomes
        else {
        qui replace cases = r(N)*r(mean) if outcome == "`out'"
        qui replace controls = r(N)-r(N)*r(mean) if outcome == "`out'"
        qui replace n_total = r(N) if outcome == "`out'"
        }
        }
        
        keep snp-n_total
        keep if snp != ""
        qui replace p = 2*normal(-abs(beta/se))
save "snps\results_Coronary_heart_disease.dta", replace

*Trait = Blood_Pressure
use "snp_ipd.dta", clear
 
keep id_ieu rs10760117_ rs11105354_ rs11128722_ rs12243859_ rs12247028_ rs12627651_ rs12656497_ rs12705390_ rs12958173_ rs13107325_ rs1327235_ rs1361831_ rs1371182_ rs1450271_ rs1458038_ rs1620668_ rs17010957_ rs17037390_ rs17608766_ rs1799945_ rs2291435_ rs2493134_ rs2521501_ rs2586886_ rs2594992_ rs2898290_ rs3184504_ rs3735533_ rs3741378_ rs4691707_ rs592373_ rs6026748_ rs633185_ rs6442101_ rs6779380_ rs6919440_ rs7076398_ rs711737_ rs7213273_ rs740746_ rs7515635_ rs932764_ rs936226_ rs943037_ 
save "snps\snps_Blood_Pressure.dta", replace
merge 1:1 id_ieu using "snps\outcomes.dta", nogen
gen snp = ""
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
        local out = substr("`outcome'",5,.)
        local out = subinstr("`out'","_"," ",.)
        *Continuous outcomes
        if "`out'" == "household income" | "`out'" == "tdi" | "`out'" == "household income re" | "`out'" == "household income equi" {
          qui regress `outcome' rs* age sex pc*
        }
        *Binary outcomes
        else {
          qui logit `outcome' rs* age sex pc*
        }
        
        foreach snp of varlist rs* {
        local snpx = substr("`snp'",1,length("`snp'")-2)
        qui replace snp = "`snpx'" in `i'  
        qui replace outcome = "`out'" in `i'
        
        qui replace beta = _b[`snp'] if snp == "`snpx'" & outcome == "`out'"
        qui replace se = _se[`snp'] if snp == "`snpx'" & outcome == "`out'"
        qui sum `snp'  
        qui replace eaf = r(mean)/2 if snp == "`snpx'"  
        local effect_allele = upper(substr("`snp'",length("`snp'"),1))
        qui replace effect_allele = "`effect_allele'" if snp == "`snpx'" 
        local i = `i'+1
        }
        }
        
        *Ns
        foreach outcome of varlist eco* soc* {
        *Continuous outcomes
        qui sum `outcome'
        local out = substr("`outcome'",5,.)
        local out = subinstr("`out'","_","",.)
        if "`out'" == "household income" | "`out'" == "tdi" | "`out'" == "household income re" | "`out'" == "household income equi" {
        qui replace n_total = r(N) if outcome == "`out'"
        }
        *Binary outcomes
        else {
        qui replace cases = r(N)*r(mean) if outcome == "`out'"
        qui replace controls = r(N)-r(N)*r(mean) if outcome == "`out'"
        qui replace n_total = r(N) if outcome == "`out'"
        }
        }
        
        keep snp-n_total
        keep if snp != ""
        qui replace p = 2*normal(-abs(beta/se))
save "snps\results_Blood_Pressure.dta", replace

*Trait = Eczema
use "snp_ipd.dta", clear
 
keep id_ieu rs10790275_ rs12144049_ rs12188917_ rs12334935_ rs2212434_ rs2918299_ rs3120745_ rs4151657_ rs479844_ rs6062486_ rs6419573_ rs8066625_ 
save "snps\snps_Eczema.dta", replace
merge 1:1 id_ieu using "snps\outcomes.dta", nogen
gen snp = ""
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
        local out = substr("`outcome'",5,.)
        local out = subinstr("`out'","_"," ",.)
        *Continuous outcomes
        if "`out'" == "household income" | "`out'" == "tdi" | "`out'" == "household income re" | "`out'" == "household income equi" {
          qui regress `outcome' rs* age sex pc*
        }
        *Binary outcomes
        else {
          qui logit `outcome' rs* age sex pc*
        }
        
        foreach snp of varlist rs* {
        local snpx = substr("`snp'",1,length("`snp'")-2)
        qui replace snp = "`snpx'" in `i'  
        qui replace outcome = "`out'" in `i'
        
        qui replace beta = _b[`snp'] if snp == "`snpx'" & outcome == "`out'"
        qui replace se = _se[`snp'] if snp == "`snpx'" & outcome == "`out'"
        qui sum `snp'  
        qui replace eaf = r(mean)/2 if snp == "`snpx'"  
        local effect_allele = upper(substr("`snp'",length("`snp'"),1))
        qui replace effect_allele = "`effect_allele'" if snp == "`snpx'" 
        local i = `i'+1
        }
        }
        
        *Ns
        foreach outcome of varlist eco* soc* {
        *Continuous outcomes
        qui sum `outcome'
        local out = substr("`outcome'",5,.)
        local out = subinstr("`out'","_","",.)
        if "`out'" == "household income" | "`out'" == "tdi" | "`out'" == "household income re" | "`out'" == "household income equi" {
        qui replace n_total = r(N) if outcome == "`out'"
        }
        *Binary outcomes
        else {
        qui replace cases = r(N)*r(mean) if outcome == "`out'"
        qui replace controls = r(N)-r(N)*r(mean) if outcome == "`out'"
        qui replace n_total = r(N) if outcome == "`out'"
        }
        }
        
        keep snp-n_total
        keep if snp != ""
        qui replace p = 2*normal(-abs(beta/se))
save "snps\results_Eczema.dta", replace

*Trait = Type_2_diabetes
use "snp_ipd.dta", clear
 
keep id_ieu rs10954284_ rs11709077_ rs1801214_ rs2383208_ rs3802177_ rs3915932_ rs4506565_ rs5015480_ rs7651090_ rs7933855_ rs864745_ rs9368222_ rs9936385_ 
save "snps\snps_Type_2_diabetes.dta", replace
merge 1:1 id_ieu using "snps\outcomes.dta", nogen
gen snp = ""
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
        local out = substr("`outcome'",5,.)
        local out = subinstr("`out'","_"," ",.)
        *Continuous outcomes
        if "`out'" == "household income" | "`out'" == "tdi" | "`out'" == "household income re" | "`out'" == "household income equi" {
          qui regress `outcome' rs* age sex pc*
        }
        *Binary outcomes
        else {
          qui logit `outcome' rs* age sex pc*
        }
        
        foreach snp of varlist rs* {
        local snpx = substr("`snp'",1,length("`snp'")-2)
        qui replace snp = "`snpx'" in `i'  
        qui replace outcome = "`out'" in `i'
        
        qui replace beta = _b[`snp'] if snp == "`snpx'" & outcome == "`out'"
        qui replace se = _se[`snp'] if snp == "`snpx'" & outcome == "`out'"
        qui sum `snp'  
        qui replace eaf = r(mean)/2 if snp == "`snpx'"  
        local effect_allele = upper(substr("`snp'",length("`snp'"),1))
        qui replace effect_allele = "`effect_allele'" if snp == "`snpx'" 
        local i = `i'+1
        }
        }
        
        *Ns
        foreach outcome of varlist eco* soc* {
        *Continuous outcomes
        qui sum `outcome'
        local out = substr("`outcome'",5,.)
        local out = subinstr("`out'","_","",.)
        if "`out'" == "household income" | "`out'" == "tdi" | "`out'" == "household income re" | "`out'" == "household income equi" {
        qui replace n_total = r(N) if outcome == "`out'"
        }
        *Binary outcomes
        else {
        qui replace cases = r(N)*r(mean) if outcome == "`out'"
        qui replace controls = r(N)-r(N)*r(mean) if outcome == "`out'"
        qui replace n_total = r(N) if outcome == "`out'"
        }
        }
        
        keep snp-n_total
        keep if snp != ""
        qui replace p = 2*normal(-abs(beta/se))
save "snps\results_Type_2_diabetes.dta", replace

*Trait = Alcohol_Intake
use "snp_ipd.dta", clear
 
keep id_ieu rs11940694_ rs1229984_ rs2165670_ rs55872084_ rs676388_ rs7187575_ 
save "snps\snps_Alcohol_Intake.dta", replace
merge 1:1 id_ieu using "snps\outcomes.dta", nogen
gen snp = ""
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
        local out = substr("`outcome'",5,.)
        local out = subinstr("`out'","_"," ",.)
        *Continuous outcomes
        if "`out'" == "household income" | "`out'" == "tdi" | "`out'" == "household income re" | "`out'" == "household income equi" {
          qui regress `outcome' rs* age sex pc*
        }
        *Binary outcomes
        else {
          qui logit `outcome' rs* age sex pc*
        }
        
        foreach snp of varlist rs* {
        local snpx = substr("`snp'",1,length("`snp'")-2)
        qui replace snp = "`snpx'" in `i'  
        qui replace outcome = "`out'" in `i'
        
        qui replace beta = _b[`snp'] if snp == "`snpx'" & outcome == "`out'"
        qui replace se = _se[`snp'] if snp == "`snpx'" & outcome == "`out'"
        qui sum `snp'  
        qui replace eaf = r(mean)/2 if snp == "`snpx'"  
        local effect_allele = upper(substr("`snp'",length("`snp'"),1))
        qui replace effect_allele = "`effect_allele'" if snp == "`snpx'" 
        local i = `i'+1
        }
        }
        
        *Ns
        foreach outcome of varlist eco* soc* {
        *Continuous outcomes
        qui sum `outcome'
        local out = substr("`outcome'",5,.)
        local out = subinstr("`out'","_","",.)
        if "`out'" == "household income" | "`out'" == "tdi" | "`out'" == "household income re" | "`out'" == "household income equi" {
        qui replace n_total = r(N) if outcome == "`out'"
        }
        *Binary outcomes
        else {
        qui replace cases = r(N)*r(mean) if outcome == "`out'"
        qui replace controls = r(N)-r(N)*r(mean) if outcome == "`out'"
        qui replace n_total = r(N) if outcome == "`out'"
        }
        }
        
        keep snp-n_total
        keep if snp != ""
        qui replace p = 2*normal(-abs(beta/se))
save "snps\results_Alcohol_Intake.dta", replace

*Trait = Smoking_Initiation
use "snp_ipd.dta", clear
 
keep id_ieu rs12441907_ rs1355334_ rs1979004_ rs2162965_ rs2186874_ rs3001723_ rs6756212_ rs7613360_ rs77311064_ rs883323_ 
save "snps\snps_Smoking_Initiation.dta", replace
merge 1:1 id_ieu using "snps\outcomes.dta", nogen
gen snp = ""
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
        local out = substr("`outcome'",5,.)
        local out = subinstr("`out'","_"," ",.)
        *Continuous outcomes
        if "`out'" == "household income" | "`out'" == "tdi" | "`out'" == "household income re" | "`out'" == "household income equi" {
          qui regress `outcome' rs* age sex pc*
        }
        *Binary outcomes
        else {
          qui logit `outcome' rs* age sex pc*
        }
        
        foreach snp of varlist rs* {
        local snpx = substr("`snp'",1,length("`snp'")-2)
        qui replace snp = "`snpx'" in `i'  
        qui replace outcome = "`out'" in `i'
        
        qui replace beta = _b[`snp'] if snp == "`snpx'" & outcome == "`out'"
        qui replace se = _se[`snp'] if snp == "`snpx'" & outcome == "`out'"
        qui sum `snp'  
        qui replace eaf = r(mean)/2 if snp == "`snpx'"  
        local effect_allele = upper(substr("`snp'",length("`snp'"),1))
        qui replace effect_allele = "`effect_allele'" if snp == "`snpx'" 
        local i = `i'+1
        }
        }
        
        *Ns
        foreach outcome of varlist eco* soc* {
        *Continuous outcomes
        qui sum `outcome'
        local out = substr("`outcome'",5,.)
        local out = subinstr("`out'","_","",.)
        if "`out'" == "household income" | "`out'" == "tdi" | "`out'" == "household income re" | "`out'" == "household income equi" {
        qui replace n_total = r(N) if outcome == "`out'"
        }
        *Binary outcomes
        else {
        qui replace cases = r(N)*r(mean) if outcome == "`out'"
        qui replace controls = r(N)-r(N)*r(mean) if outcome == "`out'"
        qui replace n_total = r(N) if outcome == "`out'"
        }
        }
        
        keep snp-n_total
        keep if snp != ""
        qui replace p = 2*normal(-abs(beta/se))
save "snps\results_Smoking_Initiation.dta", replace

*Trait = Asthma
use "snp_ipd.dta", clear
 
keep id_ieu rs1295686_ rs17843604_ rs1837253_ rs2284033_ rs2290400_ rs3771166_ rs744910_ rs992969_ 
save "snps\snps_Asthma.dta", replace
merge 1:1 id_ieu using "snps\outcomes.dta", nogen
gen snp = ""
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
        local out = substr("`outcome'",5,.)
        local out = subinstr("`out'","_"," ",.)
        *Continuous outcomes
        if "`out'" == "household income" | "`out'" == "tdi" | "`out'" == "household income re" | "`out'" == "household income equi" {
          qui regress `outcome' rs* age sex pc*
        }
        *Binary outcomes
        else {
          qui logit `outcome' rs* age sex pc*
        }
        
        foreach snp of varlist rs* {
        local snpx = substr("`snp'",1,length("`snp'")-2)
        qui replace snp = "`snpx'" in `i'  
        qui replace outcome = "`out'" in `i'
        
        qui replace beta = _b[`snp'] if snp == "`snpx'" & outcome == "`out'"
        qui replace se = _se[`snp'] if snp == "`snpx'" & outcome == "`out'"
        qui sum `snp'  
        qui replace eaf = r(mean)/2 if snp == "`snpx'"  
        local effect_allele = upper(substr("`snp'",length("`snp'"),1))
        qui replace effect_allele = "`effect_allele'" if snp == "`snpx'" 
        local i = `i'+1
        }
        }
        
        *Ns
        foreach outcome of varlist eco* soc* {
        *Continuous outcomes
        qui sum `outcome'
        local out = substr("`outcome'",5,.)
        local out = subinstr("`out'","_","",.)
        if "`out'" == "household income" | "`out'" == "tdi" | "`out'" == "household income re" | "`out'" == "household income equi" {
        qui replace n_total = r(N) if outcome == "`out'"
        }
        *Binary outcomes
        else {
        qui replace cases = r(N)*r(mean) if outcome == "`out'"
        qui replace controls = r(N)-r(N)*r(mean) if outcome == "`out'"
        qui replace n_total = r(N) if outcome == "`out'"
        }
        }
        
        keep snp-n_total
        keep if snp != ""
        qui replace p = 2*normal(-abs(beta/se))
save "snps\results_Asthma.dta", replace

*Trait = osteoarthritis
use "snp_ipd.dta", clear
 
keep id_ieu rs3757837_ rs6094710_ 
save "snps\snps_osteoarthritis.dta", replace
merge 1:1 id_ieu using "snps\outcomes.dta", nogen
gen snp = ""
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
        local out = substr("`outcome'",5,.)
        local out = subinstr("`out'","_"," ",.)
        *Continuous outcomes
        if "`out'" == "household income" | "`out'" == "tdi" | "`out'" == "household income re" | "`out'" == "household income equi" {
          qui regress `outcome' rs* age sex pc*
        }
        *Binary outcomes
        else {
          qui logit `outcome' rs* age sex pc*
        }
        
        foreach snp of varlist rs* {
        local snpx = substr("`snp'",1,length("`snp'")-2)
        qui replace snp = "`snpx'" in `i'  
        qui replace outcome = "`out'" in `i'
        
        qui replace beta = _b[`snp'] if snp == "`snpx'" & outcome == "`out'"
        qui replace se = _se[`snp'] if snp == "`snpx'" & outcome == "`out'"
        qui sum `snp'  
        qui replace eaf = r(mean)/2 if snp == "`snpx'"  
        local effect_allele = upper(substr("`snp'",length("`snp'"),1))
        qui replace effect_allele = "`effect_allele'" if snp == "`snpx'" 
        local i = `i'+1
        }
        }
        
        *Ns
        foreach outcome of varlist eco* soc* {
        *Continuous outcomes
        qui sum `outcome'
        local out = substr("`outcome'",5,.)
        local out = subinstr("`out'","_","",.)
        if "`out'" == "household income" | "`out'" == "tdi" | "`out'" == "household income re" | "`out'" == "household income equi" {
        qui replace n_total = r(N) if outcome == "`out'"
        }
        *Binary outcomes
        else {
        qui replace cases = r(N)*r(mean) if outcome == "`out'"
        qui replace controls = r(N)-r(N)*r(mean) if outcome == "`out'"
        qui replace n_total = r(N) if outcome == "`out'"
        }
        }
        
        keep snp-n_total
        keep if snp != ""
        qui replace p = 2*normal(-abs(beta/se))
save "snps\results_osteoarthritis.dta", replace

*Trait = Cholesterol
use "snp_ipd.dta", clear
 
keep id_ieu rs445925_ rs602633_ 
save "snps\snps_Cholesterol.dta", replace
merge 1:1 id_ieu using "snps\outcomes.dta", nogen
gen snp = ""
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
        local out = substr("`outcome'",5,.)
        local out = subinstr("`out'","_"," ",.)
        *Continuous outcomes
        if "`out'" == "household income" | "`out'" == "tdi" | "`out'" == "household income re" | "`out'" == "household income equi" {
          qui regress `outcome' rs* age sex pc*
        }
        *Binary outcomes
        else {
          qui logit `outcome' rs* age sex pc*
        }
        
        foreach snp of varlist rs* {
        local snpx = substr("`snp'",1,length("`snp'")-2)
        qui replace snp = "`snpx'" in `i'  
        qui replace outcome = "`out'" in `i'
        
        qui replace beta = _b[`snp'] if snp == "`snpx'" & outcome == "`out'"
        qui replace se = _se[`snp'] if snp == "`snpx'" & outcome == "`out'"
        qui sum `snp'  
        qui replace eaf = r(mean)/2 if snp == "`snpx'"  
        local effect_allele = upper(substr("`snp'",length("`snp'"),1))
        qui replace effect_allele = "`effect_allele'" if snp == "`snpx'" 
        local i = `i'+1
        }
        }
        
        *Ns
        foreach outcome of varlist eco* soc* {
        *Continuous outcomes
        qui sum `outcome'
        local out = substr("`outcome'",5,.)
        local out = subinstr("`out'","_","",.)
        if "`out'" == "household income" | "`out'" == "tdi" | "`out'" == "household income re" | "`out'" == "household income equi" {
        qui replace n_total = r(N) if outcome == "`out'"
        }
        *Binary outcomes
        else {
        qui replace cases = r(N)*r(mean) if outcome == "`out'"
        qui replace controls = r(N)-r(N)*r(mean) if outcome == "`out'"
        qui replace n_total = r(N) if outcome == "`out'"
        }
        }
        
        keep snp-n_total
        keep if snp != ""
        qui replace p = 2*normal(-abs(beta/se))
save "snps\results_Cholesterol.dta", replace

*Trait = Depressive_symptoms
use "snp_ipd.dta", clear
 
keep id_ieu rs62100776_ rs7973260_ 
save "snps\snps_Depressive_symptoms.dta", replace
merge 1:1 id_ieu using "snps\outcomes.dta", nogen
gen snp = ""
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
        local out = substr("`outcome'",5,.)
        local out = subinstr("`out'","_"," ",.)
        *Continuous outcomes
        if "`out'" == "household income" | "`out'" == "tdi" | "`out'" == "household income re" | "`out'" == "household income equi" {
          qui regress `outcome' rs* age sex pc*
        }
        *Binary outcomes
        else {
          qui logit `outcome' rs* age sex pc*
        }
        
        foreach snp of varlist rs* {
        local snpx = substr("`snp'",1,length("`snp'")-2)
        qui replace snp = "`snpx'" in `i'  
        qui replace outcome = "`out'" in `i'
        
        qui replace beta = _b[`snp'] if snp == "`snpx'" & outcome == "`out'"
        qui replace se = _se[`snp'] if snp == "`snpx'" & outcome == "`out'"
        qui sum `snp'  
        qui replace eaf = r(mean)/2 if snp == "`snpx'"  
        local effect_allele = upper(substr("`snp'",length("`snp'"),1))
        qui replace effect_allele = "`effect_allele'" if snp == "`snpx'" 
        local i = `i'+1
        }
        }
        
        *Ns
        foreach outcome of varlist eco* soc* {
        *Continuous outcomes
        qui sum `outcome'
        local out = substr("`outcome'",5,.)
        local out = subinstr("`out'","_","",.)
        if "`out'" == "household income" | "`out'" == "tdi" | "`out'" == "household income re" | "`out'" == "household income equi" {
        qui replace n_total = r(N) if outcome == "`out'"
        }
        *Binary outcomes
        else {
        qui replace cases = r(N)*r(mean) if outcome == "`out'"
        qui replace controls = r(N)-r(N)*r(mean) if outcome == "`out'"
        qui replace n_total = r(N) if outcome == "`out'"
        }
        }
        
        keep snp-n_total
        keep if snp != ""
        qui replace p = 2*normal(-abs(beta/se))
save "snps\results_Depressive_symptoms.dta", replace

