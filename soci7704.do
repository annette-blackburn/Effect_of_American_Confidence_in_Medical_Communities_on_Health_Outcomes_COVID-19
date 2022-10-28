/*2018*/
use "L:\STATS_SOCY_7704_FA_2021\GSS2018.dta"

* Keeping Data for 2018
keep year18 health conmedic consci sex sexornt age coninc partyid educ fatigue ratepain physacts hlthmntl 

tab exchealth
tab conmedic
tab consci
tab sex
tab sexornt
sum age
sum coninc
tab politparty
sum educ
sum ratepain
tab physacts
tab exchealth


*Generating Year18, Excellent Health, and Political Party Variables
gen year18 = 1
table year18 sexnow // confirmation of correctly generated dummy variable for 2018/2021
table year18 race // confirmation of correctly generated dummy variable for 2018/2021
table race year18 //confirmation of correctly generated dummy variable for 2018/2021
save "L:\STATS_SOCY_7704_FA_2021\GSS2018.dta", replace

replace exchealth = 0 if (health==1) //0==excellent health //used replace command because I already generated exchealth and needed to recode it
replace exchealth = 1 if (health==2) //1==good health
replace exchealth = 2 if (health==3 | health==4) //2==fair or poor health
label define exchealthla 0 "Excellent Health" 1 "Good Health" 2 "Fair or Poor Health"
label values exchealth exchealthla
codebook exchealth
save "L:\STATS_SOCY_7704_FA_2021\GSS2018.dta", replace
sum exchealth, detail //data skewed (-0.07) barely to the right, some kurtosis (1.97)so tails are a little thicker than those of a normal distribution

gen politparty = 1 if (partyid<=1) //1=Democrat
replace politparty = 0 if (partyid==5 | partyid==6) //0=Republican
replace politparty = 2 if (partyid==2 | partyid==3 | partyid==4 | partyid==7) //2=Other
label define politpartylab 1 "Democrat" 0 "Republican" 2 "Other"
label values politparty politpartylab
codebook politparty
save "L:\STATS_SOCY_7704_FA_2021\GSS2018.dta", replace
//politparty reference group is 0 (Republican), so the results generated show Democrat compared to Republican and Other compared to Republican

/*omitting fatigue because it is redundant and less descriptive than physacts*/

*Avoiding Perfect Prediction for OGLM
tab exchealth conmed //DV varies within all categories of conmed(IV), so no perfect prediction
tab exchealth consci //DV varies within all categories of consci(IV), so no perfect prediction
tab exchealth sex //DV varies within all categories of educ(control), so no perfect prediction
tab exchealth sexornt // no perf pred
replace sexornt = 1 if (sexornt<=2)
replace sexornt = 0 if (sexornt==3)
tab exchealth age //DV does not vary within all categories of age(control), so YES perfect prediction
replace age = 85 if (age>=85) //no more perfect prediction 
tab exchealth politparty // no perf pred
tab exchealth educ //DV varies within all categories of educ(control), so no perfect prediction
tab exchealth ratepain // yes perf pred
replace ratepain = 8 if (ratepain>=8) //no more perf pred
replace ratepain = 3 if (ratepain<=3)
tab exchealth physacts // no perf pred
tab exchealth coninc // no perf pred
tab exchealth hlthmntl 
gen exchlthmntl = 1 if (hlthmntl==1)
replace exchlthmntl = 0 if (hlthmntl==2 | hlthmntl==3 | hlthmntl==4 | hlthmntl==5)
label define exchlthmntllab 1 "Excellent Mental Health" 0 "Very Good, Good, Fair, or Poor Mental Health"
label values exchlthmntl exchlthmntllab
codebook exchlthmntl
tab exchealth exchlthmntl // no perf pred

* Install OR Graph/Plot Command
ssc install coefplot, replace
help coefplot

ologit exchealth conmedic consci i.sex i.sexornt c.age c.educ coninc i.politparty i.ratepain i.physacts i.exchlthmntl, or 
estimates store M2018
coefplot M2018, coeflabels(conmedic="Conf. Medicine" consci="Conf. Science" age="Age (years)" 1.sex="Male" 2.sex="Female" 1.sexornt="Gay, Lesbian, Bisexual" coninc="Family Income (dollars)" 0.politparty="Republican" 1.politparty="Democrat" 2.politparty="Other" educ="Education (years)"4.ratepain="Mild Pain" 5.ratepain="Mild-Moderate Pain" 6.ratepain="Moderate Pain" 7.ratepain="Moderate-Severe Pain" 8.ratepain="Severe Pain" exchlthmntl="Excellent Mental Health" 2.physacts="Mostly Able" 3.physacts="Moderately Able" 4.physacts="A Little Able" 5.physacts="Not Able") eform  xscale(log) xlabel(.25 "0.25" .5 "0.50" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 10 "10") drop(_cons)  xline(1) omitted title("Odds of Reporting Excellent" "Health in 2018 Model", size(*0.95)) subtitle("Ordered Logisitic Regression Model of Confidence in Medicine" "and the Scientific Community on Reporting Excellent Health", size(*0.8)) xtitle("Odds Ratio") text(2.5 2.6 "n=691", box fcolor(white) lcolor(black)) graphregion(fcolor(white))
listcoef, help percent
fistat
brant, detail 
// omitting estat ic because not comparing two models, just 2018 here
ssc install coefplot, replace
help coefplot

save "L:\STATS_SOCY_7704_FA_2021\GSS2018.dta", replace


/*2021*/
use "\\appsstorage.bc.edu\donaldan\STATS_SOCY_7704_FA_2021\gss2021.dta", clear

* Keeping Data for 2021
keep year18 health conmedic consci sex age partyid educ fatigue ratepain physacts coninc  hlthmntl sexornt

tab exchealth
tab conmedic
tab consci
tab sex
tab sexornt
sum age
sum coninc
tab politparty
sum educ
sum painrate
tab physacts
tab exchlthmntl

*Generating Year18, Excellent Health, and Political Party Variables
gen year18 = 0
table year18 sexnow // confirmation of correctly generated dummy variable for 2018/2021
table sexnow year18 // confirmation of correctly generated dummy variable for 2018/2021

gen exchealth = 0 if (health==1) //0==excellent health
replace exchealth = 1 if (health==2) //1==good health
replace exchealth = 2 if (health==3 | health==4) //2==fair or poor health
label define exchealthla 0 "Excellent Health" 1 "Good Health" 2 "Fair or Poor Health"
label values exchealth exchealthla
codebook exchealth
sum exchealth, detail
replace age = 85 if (age>=85)

save "\\appsstorage.bc.edu\donaldan\STATS_SOCY_7704_FA_2021\gss2021.dta", replace

// DV: health (2018/2021: excellent, good, fair, poor, no missing values)
// IV: conmedic (18/2021), consci (18/2021)
// Controls/covariates: sex (18/2021), age (18/2021), partyid (18/2021), educ (18/2021), fatigue (18/2021), ratepain (18/21), physacts (18/21), coninc (18/21), arthrtis (18),  hlthmntl (18/21), sexornt (18/21)
/*partyid==political party affiliation*/
/*fatigue==in the past 7 days, respondent's average fatigue*/
/*ratepain1==in the past 7 days, respondent's average pain*/
/*physacts==to what extent respondent can accomplish everyday physical activities*/
/*coninc==family income in constant dollars*/
/*hyperten==respondent was told they have hypertension or high blood pressure*/ - only in 2018 data
/*backpain==respondent had back pain in the last 12 months*/ - only in 2018 data
/*arthrtis==told have arthritis or rheumatism*/ - only in 2018
/*physhlth==days of poor physical health pat 30 days*/ - only in 2018
/*hlthmntl==respondent's mental health, mood, and ability to think (excellent, very good, good, fair, poor, don't know, no answer*/

gen politparty = 1 if (partyid<=1) //1=Democrat
replace politparty = 0 if (partyid==5 | partyid==6) //0=Republican
replace politparty = 2 if (partyid==2 | partyid==3 | partyid==4 | partyid==7) //2=Other
label define politpartylab 1 "Democrat" 0 "Republican" 2 "Other"
label values politparty politpartylab
codebook politparty
save "\\appsstorage.bc.edu\donaldan\STATS_SOCY_7704_FA_2021\gss2021.dta", replace
//politparty reference group is 0 (Republican), so the results generated show Democrat compared to Republican and Other compared to Republican

*Avoiding Perfect Prediction for OGLM
tab exchealth conmed // no perf pred
tab exchealth consci // no perf pred
tab exchealth sex // no perf pred
tab exchealth sexornt // no perf pred
replace sexornt = 1 if (sexornt<=2)
replace sexornt = 0 if (sexornt==3)
tab exchealth age
replace age = 85 if (age>=85) //no more perfect prediction 
tab exchealth politparty // no perf pred
tab exchealth educ // no perf pred
tab exchealth ratepain // no perf pred but needs to be similar to 2018
replace ratepain = 8 if (ratepain>=8) 
replace ratepain = 3 if (ratepain<=3)
tab exchealth physacts // no perf pred
tab exchealth coninc // no perf pred
tab exchealth hlthmntl // no perf pred but needs to be similar to 2018
gen exchlthmntl = 1 if (hlthmntl==1)
replace exchlthmntl = 0 if (hlthmntl==2 | hlthmntl==3 | hlthmntl==4 | hlthmntl==5)
label define exchlthmntllab 1 "Excellent Mental Health" 0 "Very Good, Good, Fair, or Poor Mental Health"
label values exchlthmntl exchlthmntllab
codebook exchlthmntl
tab exchealth exchlthmntl
save "\\appsstorage.bc.edu\donaldan\STATS_SOCY_7704_FA_2021\gss2021.dta", replace

ologit exchealth conmedic consci i.sex i.sexornt c.age c.educ coninc i.politparty i.ratepain i.physacts i.exchlthmntl, or 
estimates store M2021
coefplot M2021, coeflabels(conmedic="Conf. Medicine" consci="Conf. Science" age="Age (years)" 1.sex="Male" 2.sex="Female" 1.sexornt="Gay, Lesbian, Bisexual" coninc="Family Income (dollars)" 0.politparty="Republican" 1.politparty="Democrat" 2.politparty="Other" educ="Education (years)" 4.ratepain1="Mild Pain" 5.ratepain1="Mild-Moderate Pain" 6.ratepain1="Moderate Pain" 7.ratepain1="Moderate-Severe Pain" 8.ratepain1="Severe Pain" exchlthmntl="Excellent Mental Health" 2.physacts="Mostly Able" 3.physacts="Moderately Able" 4.physacts="A Little Able" 5.physacts="Not Able") eform  xscale(log) xlabel(.25 "0.25" .5 "0.50" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 10 "10") drop(_cons)  xline(1) omitted title("Odds of Reporting Excellent" "Health in 2021 Model", size(*0.95)) subtitle("Ordered Logisitic Regression Model of Confidence in Medicine" "and the Scientific Community on Reporting Excellent Health", size(*0.8)) xtitle("Odds Ratio") text(2.5 2.6 "n=691", box fcolor(white) lcolor(black)) graphregion(fcolor(white))
listcoef, help percent
fitstat
brant, detail
// omitting estat ic because not comparing two models, just the 2021 model here
save "\\appsstorage.bc.edu\donaldan\STATS_SOCY_7704_FA_2021\gss2021_edited.dta"
file \\appsstorage.bc.edu\donaldan\STATS_SOCY_7704_FA_2021\gss2021_edited.dta saved


/*2018 + 2021 Dataset*/
use "\\appsstorage.bc.edu\donaldan\STATS_SOCY_7704_FA_2021\GSS2018.dta"
append using "\\appsstorage.bc.edu\donaldan\STATS_SOCY_7704_FA_2021\gss2021.dta"

save "\\appsstorage.bc.edu\donaldan\STATS_SOCY_7704_FA_2021\GSS1821.dta", replace
file \\appsstorage.bc.edu\donaldan\STATS_SOCY_7704_FA_2021\GSS1821.dta saved

use "\\appsstorage.bc.edu\donaldan\STATS_SOCY_7704_FA_2021\GSS1821.dta"
tab year18 conmed
gen year18conmed = year18*conmedic
oglm exchealth year18conmed, or

tab year18 consci
gen year18consci = year18*consci
oglm exchealth year18consci, or

quietly ologit exchealth conmedic  i.sex i.sexornt c.age i.politparty c.educ i.ratepain i.physacts coninc i.exchlthmntl, or
estat ic
quietly ologit exchealth consci i.sex i.sexornt c.age i.politparty c.educ i.ratepain i.physacts coninc i.exchlthmntl, or
estat ic 
save "\\appsstorage.bc.edu\donaldan\STATS_SOCY_7704_FA_2021\GSS1821.dta", replace
