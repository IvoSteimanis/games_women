*--------------------------------------------------------------------
* SCRIPT: 02_analysis.do
* PURPOSE: replicates most tables and figures and saves the results
*--------------------------------------------------------------------

*--------------------------------------------------
* STRUCTURE OF THE DO-FILE
/*
	1) Analysis Main Manuscript
	2) Analysis Supplementary Online Materials
*/
*--------------------------------------------------

*LOAD DATASET
use "$working_ANALYSIS/processed/games_clean.dta", clear

*only treated villages
drop if treatment_BS==0

*Sequence of interventions in treatment villages
sort game_date_intervention
gen sequence=[_n]
gen seq_split= 0
replace seq_split=1 if sequence>28
lab var sequence "Sequence of game interventions (1 to 56)"
*-----------------------------------------
* 1) ANALYSIS MAIN MANUSCRIPT
*-----------------------------------------
*Figure 1: How women’s participation in games influenced sustainable water management. 
* created with open-source software (draw.io) based on the SEM analysis below

* Setting globals
global village	No_HH FES_site Shar_Lit Shar_SCST survey_dam_for_irrigation_FS 


*STRUCTURAL EQUATION MODEL
*define program to export direct, indirect and total effects
capture program drop te_direct
program te_direct, eclass
    quietly estat teffects
    mat b = r(direct)
    mat V = r(V_direct)
    local N = e(N)
    ereturn post b V, obs(`N')
    ereturn local cmd te_direct 
end

capture program drop te_indirect
program te_indirect, eclass
    quietly estat teffects
    mat b = r(indirect)
    mat V = r(V_indirect)
    ereturn post b V
    ereturn local cmd te_indirect 
end

capture program drop te_total
program te_total, eclass
    quietly estat teffects
    mat b = r(total)
    mat V = r(V_total)
    ereturn post b V
    ereturn local cmd te_total 
end


*define SEM and store estimates using above programs
sem (leader2_3_BS sequence $village -> share_female_percent3_BS, )(leader2_3_BS share_female_percent3_BS survey_maint_12m_BS survey_maint_rule_FS $village -> survey_maint_2017_FS, ) (leader2_3_BS share_female_percent3_BS survey_maint_rule_BS $village -> survey_maint_rule_FS, ), vce(robust) nocapslatent
eststo SEM
estat gof, stats(all)
estat residuals, format(%4.1f)
est store main
te_direct
est store direct
est restore main
te_indirect
est store indirect
est restore main
te_total
est store total




*--------------------------------------------------------------
* 2) ANALYSIS SUPPLEMENTARY ONLINE MATERIALS
*--------------------------------------------------------------

*Table S3.	Estimation of return on investment of game intervention
*created in excel.


*Table S4.	Game participants’ characteristics
preserve
clear
use "$working_ANALYSIS\data\2022_06_Mandla_Game", clear
egen dam_contribution = rowmax (cont_lab  cont_money)

global balance age literacy edu_primary edu_secondary edu_university total_help  cont_lab cont_money dam_contribution

iebaltab $balance if round ==1 & excluded_villages ==0 & elected_leader ==1, grpvar(sex)  format(%9.2f) stdev ftest fmissok tblnonote save("$working_ANALYSIS/results/tables/tableS4a_balance_gender_leader.xlsx") replace

iebaltab $balance if round ==1 & excluded_villages ==0 & elected_leader ==0, grpvar(sex)  format(%9.2f) stdev ftest fmissok tblnonote save("$working_ANALYSIS/results/tables/tableS4b_balance_gender_villagers.xlsx") replace
restore


*Table S5.	Balancing: First half versus second half villages
global balance  survey_maint_2017_FS survey_maint_12m_BS No_HH FES_site Shar_Lit Shar_SCST survey_dam_for_irrigation_FS 
iebaltab $balance, grpvar(seq_split) ftest fmissok rowvarlabels onerow stdev save("$working_ANALYSIS\results\tables\tableS5_balance_sequence.xlsx") replace


*Table S6.	Village characteristics
global summary survey_maint_12m_BS survey_maint_2017_FS survey_maint_rule_FS survey_maint_rule_BS survey_maint_rule_FS survey_dam_for_irrigation_BS survey_dam_for_irrigation_FS No_HH  Shar_Lit Shar_SCST FES_site share_female_percent2_BS leader2_2_BS leader2_3_BS

estpost tabstat $summary, statistics(min max count mean sd p50) columns(statistics)
esttab . using "$working_ANALYSIS\results\tables\tableS6_village_characteristics.rtf", cells("min(fmt(0)) max(fmt(0)) count(fmt(0)) mean(fmt(%9.2fc)) sd(fmt(%9.2fc)) p50(fmt(0)) ")  not nostar unstack nomtitle nonumber nonote label replace
 
* Table S7.	Direct, indirect, and total effects from SEM
esttab direct indirect total using "$working_ANALYSIS\results\tables\TableS7_SEM_effects.rtf", mtitles(direct indirect total) se transform(ln*: exp(@) exp(@))  b(%4.2f) label stats(N, labels("N") fmt(%4.0f %4.2f)) star(* 0.10 ** 0.05 *** 0.01) varlabels(,elist(weight:_cons "{break}{hline @width}"))  nonotes addnotes("Notes: Estimates are from SEM model using linear probability regressions with robust standard errors in brackets. * p<0.10, ** p<0.05, *** p<0.01") replace 



*Table S8.	Robustness check: Generalized SEM
gsem (leader2_3_BS sequence $village -> share_female_percent3_BS,)(leader2_3_BS share_female_percent3_BS survey_maint_12m_BS survey_maint_rule_FS $village -> survey_maint_2017_FS, probit) (leader2_3_BS share_female_percent3_BS survey_maint_rule_BS $village -> survey_maint_rule_FS, probit), vce(robust) nocapslatent
eststo SEM2 


esttab SEM2 using "$working_ANALYSIS\results\Tables\TableS8_SEM_robustness_check.rtf",  drop(var(*)) unstack  se transform(ln*: exp(@) exp(@))  b(%4.2f) label stats(N, labels("N") fmt(%4.0f)) star(* 0.10 ** 0.05 *** 0.01) varlabels(,elist(weight:_cons "{break}{hline @width}"))  nonotes addnotes("Notes: Estimates are from generalized SEM model using probit link functions for binary outcomes with robust standard errors in brackets. * p<0.10, ** p<0.05, *** p<0.01") replace 



* Table S9.	Maintenance treatment effect
preserve
clear 
use "$working_ANALYSIS/processed/games_clean.dta", clear
*----------------------------------------------------------------------
*drop variables with all missings and generate some additional variabels and labels
global village	No_HH FES_site Shar_Lit Shar_SCST survey_dam_for_irrigation_FS 

probit survey_maint_2017_ treatment survey_maint_12m_, vce(robust)
local r2_p= e(r2_p)
eststo treatment1:  margins, dydx(*) post
estadd scalar r2_p = `r2_p'

probit survey_maint_2017_FS treatment_BS survey_maint_12m_BS $village, vce(robust)
local r2_p= e(r2_p)
eststo treatment2:  margins, dydx(*) post
estadd scalar r2_p= `r2_p'


esttab treatment1 treatment2 using "$working_ANALYSIS\results\Tables\tableS9_treatment_effects.rtf", ci transform(ln*: exp(@) exp(@))mtitles("Dam maintenance (=1)" "" "Dam rule exists (=1)" "") b(%4.2f)label stats(N r2_p, labels("N" "Pseudo R2" ) fmt(%4.0f %4.2f)) star(* 0.10 ** 0.05 *** 0.01) varlabels(,elist(weight:_cons "{break}{hline @width}"))  nonotes addnotes("Notes: Estimates are from OLS regressions with robust standard errors. Omitted category is ‘village villages’. 95% confidence intervals in brackets. * p<0.05, ** p<0.01, *** p<0.001") replace 
restore





** EOF