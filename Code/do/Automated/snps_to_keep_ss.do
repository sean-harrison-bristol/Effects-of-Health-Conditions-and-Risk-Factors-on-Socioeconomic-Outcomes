**Do file to keep SNPs for each exposure
cd M:\projects\ieu2\_working\IEU2_P6_005\data\Stata\data
*Trait = Cholesterol_1
use "snp_ipd_ss.dta", clear
 
keep id_ieu rs10086411_ rs11065384_ rs11206517_ rs11254464_ rs113240350_ rs113867958_ rs11591147_ rs117310449_ rs11789603_ rs118039278_ rs12208357_ rs12472790_ rs12740374_ rs12916_ rs13222935_ rs140798831_ rs1408579_ rs145286082_ rs147711004_ rs148601586_ rs1580180_ rs1634776_ rs16844299_ rs17248720_ rs17248748_ rs174576_ rs17561950_ rs17569873_ rs1800562_ rs1800961_ rs183130_ rs1883711_ rs2000999_ rs2066714_ rs2073547_ rs261290_ rs2617801_ rs2618568_ rs2642438_ rs2737245_ rs2740488_ rs2792703_ rs28374129_ rs28601761_ rs2908806_ rs2972166_ rs35081008_ rs35135293_ rs35936756_ rs369648654_ rs3732356_ rs3741298_ rs3752448_ rs3756772_ rs41290120_ rs4299376_ rs472495_ rs4804576_ rs4860951_ rs4939883_ rs507666_ rs541041_ rs556107_ rs56163357_ rs5749600_ rs58542926_ rs5943056_ rs597808_ rs61679753_ rs62275881_ rs633695_ rs6475606_ rs6602913_ rs6709904_ rs686030_ rs6874202_ rs6920309_ rs71536551_ rs73013176_ rs7534572_ rs7567229_ rs76651220_ rs77542162_ rs7787020_ rs77960347_ rs780093_ rs7908745_ rs836550_ rs9987289_ 
save "snps_ss\snps_Cholesterol_1.dta", replace
merge 1:1 id_ieu using "snps_ss\outcomes.dta", nogen
keep if sample == 2
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
        local out = subinstr("`out'","_"," ",.)
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
save "snps_ss\results_Cholesterol_1.dta", replace

*Trait = Systolic_BP_1
use "snp_ipd_ss.dta", clear
 
keep id_ieu rs1010064_ rs10786736_ rs10857147_ rs10882398_ rs11072508_ rs11222084_ rs11629342_ rs12258967_ rs12656497_ rs12926788_ rs12978472_ rs13436194_ rs1687294_ rs17011002_ rs17033041_ rs186895872_ rs200233542_ rs2392929_ rs2643826_ rs2681485_ rs2782980_ rs284278_ rs2844543_ rs331635_ rs34611819_ rs35429334_ rs3753580_ rs3790605_ rs392956_ rs4480845_ rs4932373_ rs55881012_ rs569550_ rs60129878_ rs60289499_ rs6040076_ rs604723_ rs62162674_ rs6461992_ rs6918586_ rs7107356_ rs7302981_ rs73046792_ rs73563812_ rs76785323_ rs77870048_ rs79938490_ rs891511_ rs935168_ rs9804478_ 
save "snps_ss\snps_Systolic_BP_1.dta", replace
merge 1:1 id_ieu using "snps_ss\outcomes.dta", nogen
keep if sample == 2
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
        local out = subinstr("`out'","_"," ",.)
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
save "snps_ss\results_Systolic_BP_1.dta", replace

*Trait = Cholesterol_2
use "snp_ipd_ss.dta", clear
 
keep id_ieu rs10103996_ rs10438978_ rs10787429_ rs10832963_ rs111784051_ rs11206517_ rs112201728_ rs113293079_ rs114863007_ rs115478735_ rs11591147_ rs11641811_ rs1169292_ rs117310449_ rs11772705_ rs117733303_ rs11789603_ rs118039278_ rs12471768_ rs12916_ rs13076933_ rs13107325_ rs13108218_ rs147711004_ rs148601586_ rs1500187_ rs1532085_ rs174564_ rs1800961_ rs1883711_ rs2066714_ rs2068888_ rs2073547_ rs224424_ rs2287622_ rs2459975_ rs2569550_ rs261334_ rs2617801_ rs2618567_ rs2642438_ rs2737245_ rs2740488_ rs2854275_ rs28601761_ rs34042070_ rs35081008_ rs3732359_ rs3822855_ rs41290120_ rs4299376_ rs4307732_ rs463599_ rs472495_ rs4738684_ rs4841132_ rs4970704_ rs553427_ rs55714927_ rs55938402_ rs56325564_ rs563290_ rs581080_ rs58198139_ rs5943037_ rs615031_ rs61775180_ rs6459450_ rs6511720_ rs6602911_ rs6709904_ rs68033110_ rs6943272_ rs72631343_ rs72694393_ rs73009557_ rs7310615_ rs74186130_ rs7528419_ rs7534572_ rs7558332_ rs7640978_ rs77542162_ rs77960347_ rs780094_ rs79220007_ rs8107974_ rs821840_ rs865716_ rs870527_ rs964184_ rs9669354_ rs9884390_ 
save "snps_ss\snps_Cholesterol_2.dta", replace
merge 1:1 id_ieu using "snps_ss\outcomes.dta", nogen
keep if sample == 1
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
        local out = subinstr("`out'","_"," ",.)
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
save "snps_ss\results_Cholesterol_2.dta", replace

*Trait = BMI_1
use "snp_ipd_ss.dta", clear
 
keep id_ieu rs1013293_ rs10237317_ rs10404726_ rs10740991_ rs10789334_ rs10804139_ rs10887571_ rs10938398_ rs11030119_ rs11074651_ rs11181001_ rs112859723_ rs113784412_ rs11650332_ rs11907932_ rs12357890_ rs1264014_ rs12678759_ rs1286065_ rs12951079_ rs12972720_ rs13002946_ rs13028310_ rs13135092_ rs1359956_ rs1379871_ rs138628404_ rs1412239_ rs141820783_ rs1421085_ rs1441264_ rs144443274_ rs144713920_ rs147678035_ rs148965598_ rs149457_ rs150223295_ rs1520455_ rs1554654_ rs16903285_ rs1914888_ rs201162508_ rs2039916_ rs2234458_ rs2307111_ rs2396625_ rs2436726_ rs2678204_ rs28722029_ rs2904880_ rs2933223_ rs2979247_ rs329118_ rs34388845_ rs34602370_ rs34811474_ rs34837197_ rs350832_ rs35559811_ rs35623690_ rs35957544_ rs3729628_ rs3810291_ rs3814883_ rs3931548_ rs4430895_ rs4721096_ rs4755725_ rs4776970_ rs539515_ rs57636386_ rs58084604_ rs5910416_ rs5968872_ rs6054427_ rs61813324_ rs62104476_ rs62106258_ rs62477719_ rs62513343_ rs6575340_ rs6658723_ rs6713781_ rs6741951_ rs6861649_ rs6940215_ rs7132908_ rs71658797_ rs72820274_ rs73230043_ rs7480395_ rs75411091_ rs75584730_ rs76327888_ rs770082_ rs77483079_ rs7828172_ rs7928842_ rs7961981_ rs799447_ rs8015400_ rs8051062_ rs869400_ rs879620_ rs9277992_ rs9387640_ rs9691724_ rs980183_ rs9812425_ rs9843653_ rs9861443_ rs987237_ 
save "snps_ss\snps_BMI_1.dta", replace
merge 1:1 id_ieu using "snps_ss\outcomes.dta", nogen
keep if sample == 2
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
        local out = subinstr("`out'","_"," ",.)
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
save "snps_ss\results_BMI_1.dta", replace

*Trait = BMI_2
use "snp_ipd_ss.dta", clear
 
keep id_ieu rs10144144_ rs10195674_ rs10423928_ rs10750450_ rs10774018_ rs10920678_ rs10938397_ rs11012732_ rs11129662_ rs11150461_ rs11165643_ rs113866544_ rs11642015_ rs117422098_ rs11779446_ rs12140153_ rs12205339_ rs12339822_ rs12578952_ rs12651833_ rs1283032_ rs12926311_ rs12975415_ rs13264909_ rs1344385_ rs1379871_ rs138848010_ rs1412234_ rs1413030_ rs1441264_ rs1451077_ rs1454687_ rs147576596_ rs147730268_ rs149049023_ rs17057975_ rs17520121_ rs2234458_ rs2239647_ rs2253310_ rs2326844_ rs236651_ rs245774_ rs2494114_ rs2708149_ rs2815749_ rs28848873_ rs2952863_ rs29947_ rs34045288_ rs34341_ rs34811474_ rs35087366_ rs35225200_ rs35957544_ rs372038686_ rs3784710_ rs39330_ rs41279738_ rs4722398_ rs4743930_ rs4780885_ rs4790841_ rs4800488_ rs4808844_ rs4938180_ rs529200_ rs543874_ rs557748_ rs56803094_ rs568303215_ rs571312_ rs59956089_ rs6142059_ rs61909165_ rs62031389_ rs62057232_ rs62107261_ rs62136794_ rs62136859_ rs62622852_ rs6265_ rs6585200_ rs6638417_ rs66460909_ rs6739303_ rs6739755_ rs6746013_ rs6934662_ rs7094598_ rs7116641_ rs7124681_ rs7132908_ rs72634819_ rs72892910_ rs7332115_ rs73871847_ rs7534271_ rs76102184_ rs76249852_ rs76788735_ rs77162980_ rs7838378_ rs8020365_ rs862320_ rs869400_ rs879620_ rs9260567_ rs9843653_ rs9977825_ 
save "snps_ss\snps_BMI_2.dta", replace
merge 1:1 id_ieu using "snps_ss\outcomes.dta", nogen
keep if sample == 1
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
        local out = subinstr("`out'","_"," ",.)
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
save "snps_ss\results_BMI_2.dta", replace

*Trait = Smoking_initiation_2
use "snp_ipd_ss.dta", clear
 
keep id_ieu rs10191559_ rs10193706_ rs1043450_ rs11101595_ rs174401_ rs2080976_ rs35236974_ rs35534970_ rs364828_ rs59145036_ rs6545765_ rs7171419_ rs78569832_ rs7948789_ rs905739_ 
save "snps_ss\snps_Smoking_initiation_2.dta", replace
merge 1:1 id_ieu using "snps_ss\outcomes.dta", nogen
keep if sample == 1
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
        local out = subinstr("`out'","_"," ",.)
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
save "snps_ss\results_Smoking_initiation_2.dta", replace

*Trait = Asthma_1
use "snp_ipd_ss.dta", clear
 
keep id_ieu rs10197862_ rs10815291_ rs11071559_ rs11178649_ rs115627609_ rs117710327_ rs12123821_ rs12188917_ rs12413578_ rs1394220_ rs1684466_ rs16903574_ rs17293632_ rs17616434_ rs2241099_ rs28383454_ rs301819_ rs3024971_ rs3134935_ rs34290285_ rs34415530_ rs35570272_ rs3785356_ rs4739737_ rs4795399_ rs61813875_ rs71387227_ rs72669153_ rs7728912_ rs77793850_ rs7848215_ rs7936070_ rs8133412_ rs912131_ rs917115_ 
save "snps_ss\snps_Asthma_1.dta", replace
merge 1:1 id_ieu using "snps_ss\outcomes.dta", nogen
keep if sample == 2
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
        local out = subinstr("`out'","_"," ",.)
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
save "snps_ss\results_Asthma_1.dta", replace

*Trait = Migraine_2
use "snp_ipd_ss.dta", clear
 
keep id_ieu rs10218452_ rs4759276_ rs7559088_ rs9349379_ 
save "snps_ss\snps_Migraine_2.dta", replace
merge 1:1 id_ieu using "snps_ss\outcomes.dta", nogen
keep if sample == 1
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
        local out = subinstr("`out'","_"," ",.)
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
save "snps_ss\results_Migraine_2.dta", replace

*Trait = Smoking_initiation_1
use "snp_ipd_ss.dta", clear
 
keep id_ieu rs10459655_ rs112502960_ rs11500197_ rs1246286_ rs13036436_ rs2155290_ rs2337120_ rs28669908_ rs2867113_ rs4856591_ rs55656032_ rs72720396_ rs74651974_ rs77068442_ rs9374262_ 
save "snps_ss\snps_Smoking_initiation_1.dta", replace
merge 1:1 id_ieu using "snps_ss\outcomes.dta", nogen
keep if sample == 2
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
        local out = subinstr("`out'","_"," ",.)
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
save "snps_ss\results_Smoking_initiation_1.dta", replace

*Trait = Type_2_diabetes_1
use "snp_ipd_ss.dta", clear
 
keep id_ieu rs10830963_ rs10950550_ rs10965246_ rs1215470_ rs13266634_ rs140573710_ rs1470579_ rs150015084_ rs1801212_ rs3020789_ rs35198068_ rs4239217_ rs4731702_ rs57292959_ rs7306710_ rs76895963_ rs9274187_ rs9356744_ 
save "snps_ss\snps_Type_2_diabetes_1.dta", replace
merge 1:1 id_ieu using "snps_ss\outcomes.dta", nogen
keep if sample == 2
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
        local out = subinstr("`out'","_"," ",.)
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
save "snps_ss\results_Type_2_diabetes_1.dta", replace

*Trait = Lifetime_smoking_1
use "snp_ipd_ss.dta", clear
 
keep id_ieu rs10851907_ rs10922907_ rs11030102_ rs113382419_ rs11997346_ rs12669911_ rs12901436_ rs151176846_ rs17417989_ rs2867113_ rs3001723_ rs624833_ rs6559505_ 
save "snps_ss\snps_Lifetime_smoking_1.dta", replace
merge 1:1 id_ieu using "snps_ss\outcomes.dta", nogen
keep if sample == 2
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
        local out = subinstr("`out'","_"," ",.)
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
save "snps_ss\results_Lifetime_smoking_1.dta", replace

*Trait = Migraine_1
use "snp_ipd_ss.dta", clear
 
keep id_ieu rs11172113_ rs12134493_ rs2075968_ rs7752277_ rs9349379_ 
save "snps_ss\snps_Migraine_1.dta", replace
merge 1:1 id_ieu using "snps_ss\outcomes.dta", nogen
keep if sample == 2
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
        local out = subinstr("`out'","_"," ",.)
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
save "snps_ss\results_Migraine_1.dta", replace

*Trait = Systolic_BP_2
use "snp_ipd_ss.dta", clear
 
keep id_ieu rs11190709_ rs11191580_ rs115525024_ rs12258967_ rs1250258_ rs12677668_ rs1343040_ rs149453951_ rs1530440_ rs167479_ rs16998073_ rs17033041_ rs17608766_ rs1887320_ rs199696982_ rs2274224_ rs2282978_ rs2392929_ rs2521498_ rs2627316_ rs2681492_ rs35021474_ rs373198871_ rs4766578_ rs56100232_ rs633185_ rs6416904_ rs6442260_ rs6546123_ rs6665016_ rs6923947_ rs726073_ rs72640260_ rs72767010_ rs73029563_ rs7526027_ rs7733331_ rs77870048_ rs7838131_ rs7938342_ 
save "snps_ss\snps_Systolic_BP_2.dta", replace
merge 1:1 id_ieu using "snps_ss\outcomes.dta", nogen
keep if sample == 1
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
        local out = subinstr("`out'","_"," ",.)
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
save "snps_ss\results_Systolic_BP_2.dta", replace

*Trait = Lifetime_smoking_2
use "snp_ipd_ss.dta", clear
 
keep id_ieu rs11210887_ rs12265066_ rs151176846_ rs2080976_ rs2295146_ rs2366428_ rs2890772_ rs35534970_ rs421983_ rs4838264_ rs56116178_ rs7948789_ rs8042849_ 
save "snps_ss\snps_Lifetime_smoking_2.dta", replace
merge 1:1 id_ieu using "snps_ss\outcomes.dta", nogen
keep if sample == 1
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
        local out = subinstr("`out'","_"," ",.)
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
save "snps_ss\results_Lifetime_smoking_2.dta", replace

*Trait = Osteoarthritis_1
use "snp_ipd_ss.dta", clear
 
keep id_ieu rs112733456_ rs13107325_ rs56274763_ 
save "snps_ss\snps_Osteoarthritis_1.dta", replace
merge 1:1 id_ieu using "snps_ss\outcomes.dta", nogen
keep if sample == 2
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
        local out = subinstr("`out'","_"," ",.)
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
save "snps_ss\results_Osteoarthritis_1.dta", replace

*Trait = Eczema_1
use "snp_ipd_ss.dta", clear
 
keep id_ieu rs115288876_ rs11645657_ rs6089970_ rs61815559_ rs62626317_ rs7936070_ 
save "snps_ss\snps_Eczema_1.dta", replace
merge 1:1 id_ieu using "snps_ss\outcomes.dta", nogen
keep if sample == 2
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
        local out = subinstr("`out'","_"," ",.)
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
save "snps_ss\results_Eczema_1.dta", replace

*Trait = Asthma_2
use "snp_ipd_ss.dta", clear
 
keep id_ieu rs115627609_ rs115935870_ rs12123821_ rs12700215_ rs12905602_ rs12949100_ rs150707349_ rs17622656_ rs1837253_ rs2412099_ rs3024664_ rs3024971_ rs34492353_ rs35441874_ rs4421856_ rs45613035_ rs4739737_ rs479844_ rs55646091_ rs56062135_ rs566543580_ rs573943987_ rs5743618_ rs57537848_ rs62192043_ rs66632892_ rs705704_ rs79706217_ rs840012_ rs891058_ rs905670_ rs9273404_ rs962992_ rs992969_ 
save "snps_ss\snps_Asthma_2.dta", replace
merge 1:1 id_ieu using "snps_ss\outcomes.dta", nogen
keep if sample == 1
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
        local out = subinstr("`out'","_"," ",.)
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
save "snps_ss\results_Asthma_2.dta", replace

*Trait = Breast_cancer_1
use "snp_ipd_ss.dta", clear
 
keep id_ieu rs11599804_ rs12637272_ rs12653202_ rs3112578_ rs4442975_ rs61938093_ rs661204_ 
save "snps_ss\snps_Breast_cancer_1.dta", replace
merge 1:1 id_ieu using "snps_ss\outcomes.dta", nogen
keep if sample == 2
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
        local out = subinstr("`out'","_"," ",.)
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
save "snps_ss\results_Breast_cancer_1.dta", replace

*Trait = Alcohol_intake_1
use "snp_ipd_ss.dta", clear
 
keep id_ieu rs11604680_ rs11940694_ rs1229984_ rs1260326_ rs55938136_ rs578102530_ rs62305782_ 
save "snps_ss\snps_Alcohol_intake_1.dta", replace
merge 1:1 id_ieu using "snps_ss\outcomes.dta", nogen
keep if sample == 2
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
        local out = subinstr("`out'","_"," ",.)
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
save "snps_ss\results_Alcohol_intake_1.dta", replace

*Trait = Type_2_diabetes_2
use "snp_ipd_ss.dta", clear
 
keep id_ieu rs11658063_ rs11917625_ rs13262861_ rs1421085_ rs17050272_ rs2237895_ rs2383208_ rs3020789_ rs34872471_ rs35892300_ rs3802177_ rs3810291_ rs4372955_ rs5015480_ rs67131976_ rs76895963_ rs864745_ rs9379084_ 
save "snps_ss\snps_Type_2_diabetes_2.dta", replace
merge 1:1 id_ieu using "snps_ss\outcomes.dta", nogen
keep if sample == 1
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
        local out = subinstr("`out'","_"," ",.)
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
save "snps_ss\results_Type_2_diabetes_2.dta", replace

*Trait = Alcohol_intake_2
use "snp_ipd_ss.dta", clear
 
keep id_ieu rs116956554_ rs1229984_ rs1260326_ rs13135092_ rs17601612_ rs35538052_ rs539447_ rs676165_ rs7107356_ 
save "snps_ss\snps_Alcohol_intake_2.dta", replace
merge 1:1 id_ieu using "snps_ss\outcomes.dta", nogen
keep if sample == 1
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
        local out = subinstr("`out'","_"," ",.)
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
save "snps_ss\results_Alcohol_intake_2.dta", replace

*Trait = Coronary_heart_disease_1
use "snp_ipd_ss.dta", clear
 
keep id_ieu rs117733303_ rs429358_ rs55730499_ rs62501610_ rs7859727_ rs9349379_ 
save "snps_ss\snps_Coronary_heart_disease_1.dta", replace
merge 1:1 id_ieu using "snps_ss\outcomes.dta", nogen
keep if sample == 2
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
        local out = subinstr("`out'","_"," ",.)
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
save "snps_ss\results_Coronary_heart_disease_1.dta", replace

*Trait = Eczema_2
use "snp_ipd_ss.dta", clear
 
keep id_ieu rs12123821_ rs20541_ rs557197053_ rs61815559_ 
save "snps_ss\snps_Eczema_2.dta", replace
merge 1:1 id_ieu using "snps_ss\outcomes.dta", nogen
keep if sample == 1
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
        local out = subinstr("`out'","_"," ",.)
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
save "snps_ss\results_Eczema_2.dta", replace

*Trait = Breast_cancer_2
use "snp_ipd_ss.dta", clear
 
keep id_ieu rs13412666_ rs2936870_ rs4784227_ rs55872725_ rs6001954_ 
save "snps_ss\snps_Breast_cancer_2.dta", replace
merge 1:1 id_ieu using "snps_ss\outcomes.dta", nogen
keep if sample == 1
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
        local out = subinstr("`out'","_"," ",.)
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
save "snps_ss\results_Breast_cancer_2.dta", replace

*Trait = Osteoarthritis_2
use "snp_ipd_ss.dta", clear
 
keep id_ieu rs2473279_ 
save "snps_ss\snps_Osteoarthritis_2.dta", replace
merge 1:1 id_ieu using "snps_ss\outcomes.dta", nogen
keep if sample == 1
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
        local out = subinstr("`out'","_"," ",.)
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
save "snps_ss\results_Osteoarthritis_2.dta", replace

*Trait = Coronary_heart_disease_2
use "snp_ipd_ss.dta", clear
 
keep id_ieu rs55714120_ rs55730499_ rs660240_ rs7859727_ 
save "snps_ss\snps_Coronary_heart_disease_2.dta", replace
merge 1:1 id_ieu using "snps_ss\outcomes.dta", nogen
keep if sample == 1
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
        local out = subinstr("`out'","_"," ",.)
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
save "snps_ss\results_Coronary_heart_disease_2.dta", replace

