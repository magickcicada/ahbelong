capture log close
cd "C:\Users\delamb\data\ahabuse"
use data_stata\DS0022\21600-0022-Data.dta, clear

local cdt = subinstr(trim("`cdt'"), " ", ".", .)
local cdt: display %td_CCYY_NN_DD date(c(current_date), "DMY")
local cdt = subinstr(trim("`cdt'"), " ", ".", .)
local cti = c(current_time)
local cti = subinstr("`cti'", ":", ".", .)
local logname = "log_"+"`cdt'"+"_"+"`cti'"+".txt"
cd logs
log using "`logname'", text
cd ..

qui do data_stata\DS0022\21600-0022-Supplemental_syntax_DL.do
merge 1:1 AID using "C:\Users\delamb\data\ahabuse\data_stata\DS0001\21600-0001-PS.dta", ///
    keepusing(S4 S5 S6A S6B S6C S6D S6E S7 S12 S18 AH_PVT AH_RAW PA55 PA1 PA2 PA12 PB2 PB8)
merge 1:1 AID using "C:\Users\delamb\data\ahabuse\data_stata\DS0031\21600-0031-Data.dta", ///
    keepusing(GSWGT4_2) gen(_merge_weights)

rename *, lower

****************************************
*** RECODING, RENAMING, & LABELLING  ***
****************************************

rename gswgt4_2  weight

gen lnincome = ln(h4ec2)
label var lnincome "Log of Personal Income, 2008"

gen female = bio_sex4
recode female (1=0) (2=1)
label define sex 0 "(0) Male" 1 "(1) Female"
label values female sex
label var female "Sex, Self-Reported"

gen educlvl = h4ed2
recode educlvl (1/2=1) (3=2) (4/6=3) (7/8=4) (9=5) (10=5) (11=6) (12=4) (13=5)
label define educlvl 1 "(1) Less than H.S." 2 "(2) HS Grad/GED" 3 "(3) Some College/Trade/Voc School" 4 "(4) Bachelor's Degree" ///
	5 "(5) Master's/Professional Degree" 6 "(6) Doctoral Degree"
label values educlvl educlvl
label var educlvl "Highest Education Attained, 2008"

gen physabuse = h4ma3
recode physabuse (1/5=1) (6=0)
label define yesno 0 "(0) No" 1 "(1) Yes"
label values physabuse yesno
label var physabuse "Physically Abused by Adult Caregiver Before Age 18"

gen sexabuse = h4ma5
recode sexabuse (1/5=1) (6=0)
label values sexabuse yesno
label var sexabuse "Sexually Abused by Adult Caregiver Before Age 18"

gen sexassault = h4se34
recode sexassault (1/5=1) (6=0)
label values sexassault yesno
label var sexassault "Has Ever Been Forced to Have Sex Against Will"

recode pa1 (1=0) (2=1) // sex of responding parent/guardian
recode pb2 (1=0) (2=1) // sex of responding p/g's spouse or partner
recode pa12 (1/3=1) (10=1) (4/5=2) (6/7=3) (8=4) (9=5) // education level of pa1, labeled in "edmother"/"edfather" 
recode pb8 (1/3=1) (10/11=1) (4/5=2) (6/7=3) (8=4) (9=5) (12=.) // ditto for pb2

gen edmother = pa12 if pa1==1 // Mother's Ed. if pa1 is female
replace edmother = pb8 if pa1==0 & pb2==1 // Mother's Ed. if pb2 is female
label define edparent 1 "(1) Less than HS" 2 "(2) HS Grad/GED" 3 "(3) Some Coll/Trade/Voc" 4 "(4) Bachelor's Degree" 5 " (5) > Bachelor's"
label values edmother edparent
label var edmother "Mother's Education"

gen edfather = pa12 if pa1==0 // Father's Ed. if pa1 is male
replace edfather = pb8 if pa1==1 & pb2==0 // Father's Ed. if pb2 is male
label values edfather edparent
label var edfather "Father's Education"

gen hhinc94 = pa55/10 // Wave I household income in units of $10,000
label var hhinc94 "1994 Childhood Household Income, Parent-Reported, 1=$10K"

* Recoding for self-reported race & ethnicity variables from Wave I (1994/95)
gen ethrace = 1 if s6a==1 & s6b==0 & s6c==0 & s6d==0 & s6e==0 & s4==0      // white only
replace ethrace = 2 if s6a==0 & s6b==1 & s6c==0 & s6d==0 & s6e==0 & s4==0  // black only
replace ethrace = 3 if s6a==0 & s6b==0 & s6c==1 & s6d==0 & s6e==0 & s4==0  // asian only
replace ethrace = 4 if s6a==0 & s6b==0 & s6c==0 & s6d==1 & s6e==0 & s4==0  // native american only
replace ethrace = 5 if s6a==0 & s6b==0 & s6c==0 & s6d==0 & s6e==0 & s4==1  // hispanic ethnicity only
replace ethrace = 5 if s6a==0 & s6b==0 & s6c==0 & s6d==0 & s6e==1 & s4==1  // other+hispanic, coded as hispanic
replace ethrace = 7 if s6a==0 & s6b==0 & s6c==0 & s6d==0 & s6e==1 & s4==0  // other only
* next two lines code any multiples as "Two or More"
replace ethrace = 6 if (s6a==1 & (s6b==1 | s6c==1 | s6d==1 | s6e==1 | s4==1)) | ///
    (s6b==1 & (s6c==1 | s6d==1 | s6e==1 |s4==1)) | (s6c==1 & (s6d==1 | s6e==1 | s4==1)) | (s6d==1 & (s6e==1 | s4==1))
label define ethrace 1 "(1) White" 2 "(2) Black" 3 "(3) Asian" 4 "(4) Native American" 5 "(5) Hispanic" 6 "(6) Two or More" 7 "(7) Other"
label values ethrace ethrace
label var ethrace "Race or Ethnicity, Self-Reported"

gen testscore = ah_pvt
label var testscore "Abbreviated Peabody Picture Vocabulary Test, Standardized"

* Mental health matrix
gen depression = h4id5h
label var depression "Ever Been Diagnosed w/ a Depressive Disorder"
gen ptsd = h4id5i
label var ptsd "Ever Been Diagnosed w/ PTSD"
gen anxiety = h4id5j
label var anxiety "Ever Been Diagnosed w/ an Anxiety Disorder"
gen mhdx = (h4id5h==1 | h4id5j==1 | h4id5j==1)
label var mhdx "Ever Been Diagnosed w/ Depression, Anxiety, and/or PTSD"

* modelling
reg lnincome sexabuse physabuse i.educlvl i.female##i.ethrace hhinc94 testscore, baselevels 
eststo main_unweighted
reg lnincome sexabuse physabuse i.educlvl i.female##i.ethrace hhinc94 testscore [pweight=weight], baselevels 
eststo main_weighted

* estout main using ../textest.tex, replace cells("b(star fmt(3)) se(fmt(2) par)") noomitted ///
*	legend label collabels(none) varlabels(_cons Constant) style(tex) ///
*	prehead(\begin{tabular}{l*{@M}{r}}) postfoot(\end{tabular})


