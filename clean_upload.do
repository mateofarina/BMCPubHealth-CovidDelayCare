
** Delayed a Doctor's Visit (Telemedicine counted as having a doctor's visit)
gen doc_delay = . 
replace doc_delay = 1 if delay_care ==1 & delay_doctor == 1
replace doc_delay = 0 if delay_care ==1 & delay_doctor == 0
replace doc_delay = 0 if delay_care ==0
 
** Delayed Dental Care
gen dental_delay = . 
replace dental_delay = 1 if delay_care ==1 & delay_dental == 1
replace dental_delay = 0 if delay_care ==1 & delay_dental == 0
replace dental_delay = 0 if delay_care ==0

** Delayed Surgery
gen surgery_delay = . 
replace surgery_delay = 1 if delay_care ==1 & delay_surgery == 1
replace surgery_delay = 0 if delay_care ==1 & delay_surgery == 0
replace surgery_delay = 0 if delay_care ==0

** Delayed RX
gen rx_delay = . 
replace rx_delay = 1 if delay_care ==1 & delay_rx == 1
replace rx_delay = 0 if delay_care ==1 & delay_rx == 0
replace rx_delay = 0 if delay_care ==0



set cformat %4.2f

****************************** Analysis*****************************************


**** Table 1: Descriptive Statistics

svy: sum age55
svy: tab gender
svy: tab race2 
svy: tab educ_cat 
svy: tab srh
svy: tab has_adl

sum age55 if delay_care==1
tab gender if delay_care==1
tab race2 if delay_care==1
tab raeduc if delay_care==1
tab srh if delay_care==1

**** Figure 2

svyset [pweight=covid_weight] // svyset

global reason_delay delay_afraid delay_afford delay_closed delay_postpone delay_other delay_appoint

foreach x in $reason_delay {

svy: prop `x'

}


global care_type delay_care dental_delay doc_delay surgery_delay rx_delay

foreach x in $care_type {

svy: prop `x'

}

global reason 


*** Table 2: Unadjusted Odds
global care delay_care dental_delay doc_delay 


foreach x in $care{
eststo clear
eststo: svy: logit `x' c.age_cat  
eststo: svy: logit `x' i.gender, or
eststo: svy: logit `x' i.race2 
eststo: svy: logit `x' i.educ_cat
eststo: svy: logit `x' i.srh 
eststo: svy: logit `x' i.has_adl

esttab using /Users/mfarina/Projects/COVID_DELAY_MED/Tables/unadjusted_table_`x'.csv, b(%9.2f) not nocon eform ci ///
	starlevels(* .05 ** .01 *** .001) nodepvars nomtitles wide nopa  replace // use plain to get CIs
}

*** Table Adjusted Odds
 
foreach x in $care {

eststo clear
eststo: svy: logit `x' c.age_cat i.gender i.race2 i.educ_cat i.srh i.has_adl, or

esttab using /Users/mfarina/Projects/COVID_DELAY_MED/Tables/table_`x'.csv, b(%9.2f) not nocon eform ci ///
	starlevels(* .05 ** .01 *** .001) nodepvars nomtitles wide nopa replace

}



exit 

