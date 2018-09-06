********************************************
** BOILERPLATE & AUTOMATIC LOG GENERATION **
********************************************

capture log close
cd "C:\Users\delamb\data\ahbelong"
use data/addhealth_narrow.dta, clear

local cdt: display %td_CCYY_NN_DD date(c(current_date), "DMY")
local cdt = subinstr(trim("`cdt'"), " ", ".", .)
local cti = c(current_time)
local cti = subinstr("`cti'", ":", ".", .)
local logname = "log_"+"`cdt'"+"_"+"`cti'"+".txt"
cd logs
log using "`logname'", text
cd ..




***********************
** RENAMES & RECODES **
***********************

// Does NOT feel a part of school
recode s62e (4/5=1) (1/3=0), gen(notPart)
label define noyes 0 "(0) No" 1 "(1) Yes"
label values notPart noyes
label var notPart "Does NOT feel a part of school"


// Does NOT feel close to others at school
recode s62b (4/5=1) (1/3=0), gen(notClose)
label values notClose noyes
label var notClose "Does NOT feel close to others at school"

// Any post-high school credential
recode h4ed3a (1=0) (2/8=1), gen(credential)
label values credential noyes
label var credential "Any Post-High School Credential"

// Highest degree attained
recode h4ed2 (1/2=1) (3=2) (4/6=3) (7/8=4) (9=5) (10=5) (11=6) (12=4) (13=5), gen(degree)
label define degree 1 "(1) Less than H.S." 2 "(2) HS Grad/GED" 3 "(3) Some College/Trade/Voc School" 4 "(4) Bachelor's Degree" ///
	5 "(5) Master's/Professional Degree" 6 "(6) Doctoral Degree"
label values degree degree
label var degree "Highest Degree Attained, 2008"

// Dummy for sex
recode bio_sex (1=0) (2=1), gen(female)
label define sex 0 "(0) Male" 1 "(1) Female"
label values female sex
label var female "Sex, Self-Reported"

// Race/Ethnicity
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
label var ethrace "Race/Ethnicity"

// Childhood household income
gen hhinc94 = pa55/10 // Wave I household income in units of $10,000
label var hhinc94 "Childhood Household Income, 1=$10K"

