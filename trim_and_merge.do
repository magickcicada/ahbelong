// Change the below to wherever you unzipped the big file from ICPSR
// cd "C:\Users\delamb\data\ahbelong\data"

**********************
** MAIN WAVE I DATA **
**********************
use DS0001/21600-0001-Data.dta, clear
keep AID-H1DA11 H1GH18-H1GH21 H1ED1-H1ED24 H1FS1-H1FS19 H1NM1-H1RF14 H1SU1-H1SU8 H1PR1-H1PR8 ///
     H1EE1-H1EE15 S1-S62R PA1-PA39 PA55 PB2 PB8 AH_PVT AH_RAW
/*  The above drops:
    Section 3: General Health  except for some mental health variables
    Section 4: Taught in School (health info received at school)
    Section 6: Physical Limitations
    Section 7: Access to Health Services
    Section 8: Pregnancy, AIDS, STD Risk Perceptions
    Section 9: Self-Efficacy
    Section 11: Household Roster (May need for siblings)
    Section 16: Relations with Parents
    Section 17: Motivations to Engage in Risky Behaviors
    Section 18: Personality & Family  (Maybe some intersting variables, but probably covered elsewhere)
    Section 19: Knowledge Quiz  (Health & sex questions)
    Sections 20-23: Individual friends & romances
    Sections 24-32B: All self-administered sections, except Section 33: Suicide
    Section 34: Parents' Attitudes
    Section 36: Neighborhood
    Section 37: Religion
    Section 39: Relationship w/ siblings
    Section 40: Interviewer remarks
    Section 41: Cards
    Parent Questionnaire: Parent A relationship section,
                          all Parent B except sex/gender & education level
                          parent's assessment of child
            
*/

// Merge in variables from Waves III-IV
merge 1:1 AID using DS0008/21600-0008-Data.dta, gen(_mergeW3InHome) ///
          keepusing(H3ED1-H3ED49YO H3SP1-H3SP27 H3EC1A-H3EC63) // WIII In-Home questionnaire
       /* keeping only:
            Section 7: Education
            Section 12: Social Psychology & Mental Health
            Section 15: Economics & Personal Future
       */
merge 1:1 AID using DS0016/21600-0016-Data.dta, gen(_mergeW3Ed) // WIII Education variables
merge 1:1 AID using DS0017/21600-0017-Data.dta, gen(_mergeW3Grad) // WIII School varabiales
merge 1:1 AID using DS0020/21600-0020-Data.dta, gen(_mergeW3Pvt) // WIII Peabody PVT scores
merge 1:1 AID using DS0022/21600-0022-Data.dta, gen(_mergeW4) ///
          keepusing(H4ID5H-H4ID5J H4ED1-H4ED9 H4EC1-H4EC19 H4MH2-H4MH29 H4PE1-H4PE41) // WIV In-home survey
        /* keeping:
            Section 6: Illness, Medications, and Physical Disabilities **Anxiety, Depression, PTSD variables only
            Section 9: Education
            Section 12: Economics
            Section 14: Social Psychology & Mental Health, excluding memory task battery (MH1 & followups)
            Section 26: Personality (self-perception)
        */

// Merge in weights
merge 1:1 AID using DS0004/21600-0004-Data.dta, gen(_mergeW1wgt) keepusing(GSWGT1)
merge 1:1 AID using DS0021/21600-0021-Data.dta, gen(_mergeW3wgt) keepusing(GSWGT3 GSWGT3_2)
merge 1:1 AID using DS0018/21600-0018-Data.dta, gen(_mergeW3wgtEd) keepusing(PTWGT3 PTWGT3_2)
merge 1:1 AID using DS0031/21600-0031-Data.dta, gen(_mergeW4wgt) keepusing(GSWGT4 GSWGT4_2 GSWGT134)

// Run recoding scripts provided in ICPSR files
do DS0001/21600-0001-Supplemental_syntax.do
do DS0008/21600-0008-Supplemental_syntax.do
do DS0016/21600-0016-Supplemental_syntax.do
do DS0017/21600-0017-Supplemental_syntax.do
do DS0020/21600-0020-Supplemental_syntax.do
do DS0022/21600-0022-Supplemental_syntax.do


rename *, lower // lowercase variable names
order _merge*, last // move merge categoricals to end for prettiness.
