*--------------------------------------------------------------------
* SCRIPT: 02_analysis.do
* PURPOSE: replicates most tables and figures and saves the results
*--------------------------------------------------------------------

*--------------------------------------------------
* STRUCTURE OF THE DO-FILE
/*
	Setup
	1) Analysis Main Manuscript
	2) Supporting analyses
	3) Supplementary Datasets S1 to S10
*/
*--------------------------------------------------

*------------

* SETUP
*------------
*LOAD VILLAGE-LEVEL DATASET
use "$working_ANALYSIS/processed/games_clean_final.dta", clear

*define globals
global controls No_HH FES_site n_SHG_before2017 Shar_Lit Shar_SCST n_school_gov
global village No_HH FES_site n_SHG_before2017 d_public_school d_private_school Shar_Lit Shar_SCST



*-----------------------------------------
* 1) ANALYSIS MAIN MANUSCRIPT
*-----------------------------------------

*Figure 1: How women’s participation in games influenced sustainable water management. 
*Panel A: main treatment effect

probit survey_maint_2017_FS treatment_BS survey_maint_12m_BS survey_dam_for_irrigation_FS $controls, vce(robust)
local r2_p= e(r2_p)
eststo maintenance:  margins, dydx(*) post
estadd scalar r2_p= `r2_p'

probit survey_maint_rule_FS treatment_BS survey_maint_12m_BS survey_dam_for_irrigation_FS $controls, vce(robust)
local r2_p= e(r2_p)
eststo rules:  margins, dydx(*) post
estadd scalar r2_p= `r2_p'

coefplot(maintenance), bylabel(Dam maintenance last 12 months) || (rules), bylabel(Rules for dam maintenance) ||,  xla(-0.4 "-40" -0.2 "-20" 0 "0" 0.2 "20" 0.4 "40",labsize(6pt)) byopts(title("{bf:A} Effect of experiental learning games intervention", size(10pt)) compact imargin(*1.6)  rows(1) legend(off))  keep(treatment_BS ) coeflabels(treatment_BS = "Intervention villages", labsize(6pt)) xline(0, lpattern(dash) lcolor(gs3)) xtitle("Regression estimated impact in %-points relative to passive Control ", size(6pt)) grid(none) levels(95 90)mlabel(cond(@pval<.005, "***", cond(@pval<.05, "**", cond(@pval<.1, "*", "")))) msize(3pt) msymbol(D) mlabsize(10pt) mlabposition(12) mlabgap(-1.2)  subtitle(, size(9pt) lstyle(none) margin(medium) nobox justification(center) alignment(top) bmargin(top))  xsize(3.465) ysize(2) ciopts(lwidth(0.8 2) lcolor("140 140 140%80" "140 140 140*0.6")  recast(rcap)) mcolor("140 140 140") norecycle plotregion(margin(0 0 0 0)) aspectratio(0.6)
gr save  "$working_ANALYSIS/results/intermediate/intervention_effect.gph", replace
gr export "$working_ANALYSIS\results\figures\intervention_effect.png", replace width(3800)



*Panel B: Factors associated with outcomes in treatment villages
drop if treatment==0
* created with open-source software (draw.io) based on the SEM analysis below (Supplementary Dataset S5)



*--------------------------------------------------------------
* 2) Supporting analyses
*--------------------------------------------------------------
*difference between FES and non-FES villages in outcome variables
ttest survey_maint_12m_BS, by(FES_site)
ttest survey_maint_2017_, by(FES_site)

ttest survey_maint_rule_BS, by(FES_site)
ttest survey_maint_rule_FS, by(FES_site)


*FES & gender participation
ttest share_female_percent2_BS, by(FES)
ttest female_leader_present_BS, by(FES)


* discussions within community
ttest game_discussed_formally, by(female_leader_present_BS)
* the game was dicussed formally in community and/or village council meetings in 24 out of the 55 intervention villages (46%), but not significantly more often when female leaders were present



*Comparison of sample to 2011 census data: Age & Literacy
preserve
clear all
use "$working_ANALYSIS/data/2022_06_Mandla_Game.dta", clear
sort site_ID round
drop if round!=1 
drop if excluded_villages==1


*do our participants differ from average Madhya Pradesh population?
* averages taken from 2011 census data 
ttest age = 37  if participant_type==1
ttest age = 37 if participant_type==3
ttest age = 38  if participant_type==2
ttest age = 38  if participant_type==4
* sample signficantly older, but we also required participants to be atlest 18 years older
ttest literacy = 23.1 if sex==0
ttest literacy = 32.1 if sex==1
* significantly higher, as 95% of our participants were literate


*Age against average district population
cibar age, over1(participant_type) gap(50) bargap(20) barlabel(on) blfmt(%8.0f) blpos(12) blsize(8pt) blgap(2.5) baropts(fcolor(%70) lcolor(none))  graphopts(yline(27.25, lwidth(medium) lpattern(dash)) title("{bf: A} Age",  size(8pt)) xsize(3) ysize(2)  legend(ring (1) pos(6) rows(2) size(8pt)) yla(0(10)50, nogrid labsize(6pt)) xla(, nogrid)  ytitle("Mean Age in years", size(6pt)))  ciopts(lcolor(gs6) lwidth(medthick))
gr save  "$working_ANALYSIS/results/intermediate/sample_census_comparison_a.gph", replace 

*Literacy against average district population
gen lit100 = literacy*100
cibar lit100, over1(participant_type) gap(50) bargap(20) barlabel(on) blfmt(%8.0f) blpos(6) blsize(8pt) blgap(-4) baropts(fcolor(%70) lcolor(none))  graphopts(yline(23.1 32.1, lwidth(medium) lpattern(dash)) title("{bf: B} Literacy",  size(8pt)) xsize(3) ysize(2)  legend(ring (1) pos(6) rows(2) size(8pt)) yla(0(20)100, nogrid labsize(6pt)) xla(, nogrid)  ytitle("Literacy in %", size(6pt)))  ciopts(lcolor(gs6) lwidth(medthick))
gr save  "$working_ANALYSIS/results/intermediate/sample_census_comparison_b.gph", replace 

grc1leg2 "$working_ANALYSIS\results\intermediate\sample_census_comparison_a" "$working_ANALYSIS\results\intermediate\sample_census_comparison_b", title("Sample vs. Mandal district population", size(10pt)) scale(1.1) graphregion(margin(0 0 0 0)) xsize(3) ysize(2) rows(1) legendfrom("$working_ANALYSIS\results\intermediate\sample_census_comparison_a") 
gr save  "$working_ANALYSIS\results\intermediate\sample_vs_district.gph", replace
gr export "$working_ANALYSIS\results\figures\sample_vs_district.png", replace width(3800)

restore


*Leader composition 
prtest leader_comp1_BS, by(seq_split)
prtest leader_comp2_BS, by(seq_split)
prtest leader_comp3_BS, by(seq_split)
prtest leader_comp4_BS, by(seq_split)
ttest game_no_leader_fem_vill, by(seq_split)

bys seq_split: tab game_sum_leader_SHG if female_leader_present_BS==1 
bys seq_split: tab game_sum_leader_SHG if female_leader_present_BS==1
bys seq_split: tab1 SHG_before2017 if treatment_BS==1


cibar game_share_fem_vill, over1(leader_present_BS)   gap(30) bargap(10) barlabel(on) blpos(10) blsize(6pt) blgap(0.02) graphopts(xsize(4) ysize(2.5)  legend(ring (1) pos(6) rows(1) size(8pt))  yla(0(0.1)0.6, nogrid) xla(, nogrid) ytitle("Share of women in games (in %)", size(8pt))) ciopts(lcolor(black) lpattern(dash))
gr_edit xaxis1.style.editstyle majorstyle(tickstyle(textstyle(size(6-pt)))) editcopy
gr_edit yaxis1.style.editstyle majorstyle(tickstyle(textstyle(size(6-pt)))) editcopy
gr_edit style.editstyle margin(vsmall) editcopy
gr save "$working_ANALYSIS\results\intermediate\Gendered_participation.gph", replace
gr export "$working_ANALYSIS\results\figures\Gendered_participation.png", replace width(4000)

reg game_share_fem_vill i.leader_present_BS $village, vce(robust)
reg game_share_fem_vill leader_comp4_BS $village, vce(robust)





*--------------------------------------------------------------
* 3) Supplementary Datasets
*--------------------------------------------------------------
*Supplementary Dataset S1.	Estimation of return on investment of game intervention
*created in excel.


*Supplementary Dataset S2. Participant Characteristics
preserve
clear
use "$working_ANALYSIS\data\2022_06_Mandla_Game", clear

tab leader_fem leader_type

global balance age literacy edu_primary edu_secondary edu_university total_help  cont_lab cont_money dam_contribution

iebaltab $balance if round ==1 & excluded_villages ==0 & elected_leader ==1, grpvar(sex)  format(%9.2f) tblnonote save("$working_ANALYSIS/results/tables/S2_participant_characteristics_A.xlsx") replace

iebaltab $balance if round ==1 & excluded_villages ==0 & elected_leader ==0, grpvar(sex)  format(%9.2f) tblnonote save("$working_ANALYSIS/results/tables/S2_participant_characteristics_B.xlsx") replace

*Both outputs were manually combined to Supplementary Dataset "S2_participant_characteristics.xlsx"
restore



* Supplementary Dataset S3.	Balancing: First half versus second half villages
global balance survey_maint_12m_BS n_SHG_before2017 survey_dam_for_irrigation_BS No_HH FES_site d_public_school d_private_school Shar_Lit Shar_SCST  
iebaltab $balance, grpvar(seq_split) rowvarlabels ftest balmiss(mean) format(%8.2f) onerow save("$working_ANALYSIS\results\tables\S3_balancing_test.xlsx") replace

 
* Supplementary Dataset S4. Village characteristics
global summary survey_maint_12m_BS survey_maint_2017_FS survey_maint_rule_FS survey_maint_rule_BS survey_maint_rule_FS survey_dam_for_irrigation_BS survey_dam_for_irrigation_FS No_HH  Shar_Lit Shar_SCST FES_site share_female_percent2_BS leader_comp1_BS leader_comp2_BS leader_comp3_BS leader_comp4_BS n_SHG_before2017 n_SHG_after2017

estpost tabstat $summary if treatment==1, statistics(min max count mean sd p50) columns(statistics)
esttab . using "$working_ANALYSIS\results\tables\S4_vilage_characteristics.rtf", cells("min(fmt(0)) max(fmt(0)) count(fmt(0)) mean(fmt(%9.2fc)) sd(fmt(%9.2fc)) p50(fmt(0)) ")  not nostar unstack nomtitle nonumber nonote label replace
 
 
 
* Supplementary Dataset S5. Main SEM output
*define program to export direct, indirect and total effects from SEM
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

sem ($village sequence-> leader_comp1_BS ) ($village  sequence-> leader_comp2_BS ) ($village  sequence-> leader_comp3_BS ) ($village  sequence-> leader_comp4_BS ) (leader_comp2_BS leader_comp3_BS leader_comp4_BS total_leaders $village  sequence -> share_female_percent3_BS , )  (leader_comp2_BS leader_comp3_BS leader_comp4_BS total_leaders share_female_percent3_BS survey_maint_rule_BS $village  survey_dam_for_irrigation_FS sequence -> survey_maint_rule_FS, ) (leader_comp2_BS leader_comp3_BS leader_comp4_BS  total_leaders share_female_percent3_BS survey_maint_12m_BS survey_maint_rule_FS $village  survey_dam_for_irrigation_FS sequence -> survey_maint_2017_FS , ), vce(robust) nocapslatent

eststo SEM
estat teffects
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



esttab direct indirect total using "$working_ANALYSIS\results\tables\S5_main_SEM.rtf", mtitles(direct indirect total) se transform(ln*: exp(@) exp(@))  b(%4.2f) label stats(N, labels("N") fmt(%4.0f %4.2f)) star(* 0.10 ** 0.05 *** 0.01) varlabels(,elist(weight:_cons "{break}{hline @width}"))  nonotes addnotes("Notes: Estimates are from SEM model using linear probability regressions with robust standard errors in brackets. * p<0.10, ** p<0.05, *** p<0.01") replace 


* Supplementary Dataset S6. Generalized SEM comparison
sem ($village sequence-> leader_comp1_BS ) ($village  sequence-> leader_comp2_BS ) ($village  sequence-> leader_comp3_BS ) ($village  sequence-> leader_comp4_BS ) (leader_comp2_BS leader_comp3_BS leader_comp4_BS total_leaders $village  sequence -> share_female_percent3_BS , )  (leader_comp2_BS leader_comp3_BS leader_comp4_BS total_leaders share_female_percent3_BS survey_maint_rule_BS $village  survey_dam_for_irrigation_FS sequence -> survey_maint_rule_FS, ) (leader_comp2_BS leader_comp3_BS leader_comp4_BS  total_leaders share_female_percent3_BS survey_maint_12m_BS survey_maint_rule_FS $village  survey_dam_for_irrigation_FS sequence -> survey_maint_2017_FS , ), vce(robust) nocapslatent

gsem ($village  sequence -> leader_present_BS, mlogit)  (i.leader_present_BS total_leaders $village  sequence -> share_female_percent3_BS , )  (i.leader_present_BS total_leaders share_female_percent3_BS survey_maint_rule_BS $village  survey_dam_for_irrigation_FS sequence -> survey_maint_rule_FS, probit) (i.leader_present_BS  total_leaders share_female_percent3_BS survey_maint_12m_BS survey_maint_rule_FS $village  survey_dam_for_irrigation_FS sequence -> survey_maint_2017_FS , probit), vce(robust) nocapslatent
* explanation how to get indirect effects https://www.statalist.org/forums/forum/general-stata-discussion/general/1551690-mediation-analysis-in-a-multilevel-model-how-to-bootstrap-indirect-effects-after-gsem
eststo SEM2 


esttab SEM2 using "$working_ANALYSIS\results\Tables\S6_GSEM.rtf",  drop(var(*)) unstack  se transform(ln*: exp(@) exp(@))  b(%4.2f) label stats(N, labels("N") fmt(%4.0f)) star(* 0.10 ** 0.05 *** 0.01) varlabels(,elist(weight:_cons "{break}{hline @width}"))  nonotes addnotes("Notes: Estimates are from generalized SEM model using probit link functions for binary outcomes with robust standard errors in brackets. * p<0.10, ** p<0.05, *** p<0.01") replace 


* Supplementary Dataset S7. SEM robustness check
sem ($village sequence-> leader_comp1_BS ) ($village  sequence-> leader_comp2_BS ) ($village  sequence-> leader_comp3_BS ) ($village  sequence-> leader_comp4_BS ) (leader_comp2_BS leader_comp3_BS leader_comp4_BS total_leaders $village  sequence -> share_female_percent3_BS , )  (leader_comp2_BS leader_comp3_BS leader_comp4_BS total_leaders share_female_percent3_BS  $village  survey_dam_for_irrigation_FS sequence -> survey_maint_rule_FS, ) (leader_comp2_BS leader_comp3_BS leader_comp4_BS  total_leaders share_female_percent3_BS survey_maint_12m_BS survey_maint_rule_FS $village  survey_dam_for_irrigation_FS sequence -> survey_maint_2017_FS , ), vce(robust) nocapslatent

eststo SEM3

esttab SEM3 using "$working_ANALYSIS\results\Tables\S7_SEM_robust.rtf",  drop(var(*)) unstack  se transform(ln*: exp(@) exp(@))  b(%4.2f) label stats(N, labels("N") fmt(%4.0f)) star(* 0.10 ** 0.05 *** 0.01) varlabels(,elist(weight:_cons "{break}{hline @width}"))  nonotes addnotes("Notes: Estimates are from generalized SEM model using probit link functions for binary outcomes with robust standard errors in brackets. * p<0.10, ** p<0.05, *** p<0.01") replace 




* Supplementary Dataset S8. Intervention Effect
preserve
*LOAD VILLAGE-LEVEL DATASET
use "$working_ANALYSIS/processed/games_clean_final.dta", clear

probit survey_maint_2017_ treatment_BS survey_maint_12m_, vce(robust)
local r2_p= e(r2_p)
eststo treatment1:  margins, dydx(*) post
estadd scalar r2_p = `r2_p'

probit survey_maint_2017_FS treatment_BS survey_maint_12m_BS survey_dam_for_irrigation_FS $controls, vce(robust)
local r2_p= e(r2_p)
eststo treatment2:  margins, dydx(*) post
estadd scalar r2_p= `r2_p'

probit survey_maint_rule_FS treatment_BS survey_maint_12m_BS, vce(robust)
local r2_p= e(r2_p)
eststo treatment3:  margins, dydx(*) post
estadd scalar r2_p = `r2_p'

probit survey_maint_rule_FS treatment_BS survey_maint_12m_BS survey_dam_for_irrigation_FS $controls, vce(robust)
local r2_p= e(r2_p)
eststo treatment4:  margins, dydx(*) post
estadd scalar r2_p= `r2_p'


esttab treatment1 treatment2 treatment3 treatment4 using "$working_ANALYSIS\results\Tables\S8_intervention_effect.rtf", ci transform(ln*: exp(@) exp(@))mtitles("Dam maintenance (=1)" "" "Dam rule exists (=1)" "") b(%4.2f)label stats(N r2_p, labels("N" "Pseudo R2" ) fmt(%4.0f %4.2f)) star(* 0.10 ** 0.05 *** 0.01) varlabels(,elist(weight:_cons "{break}{hline @width}"))  nonotes addnotes("Notes: Estimates are from OLS regressions with robust standard errors. 95% confidence intervals in brackets. * p<0.10, ** p<0.05, *** p<0.01") replace 
restore


*Supplementary Dataset S9: Type of leaders by gender
preserve
clear
use "$working_ANALYSIS\data\2022_06_Mandla_Game", clear

sort site_ID round
drop if round!=1 
drop if excluded_villages==1

iebaltab leader_2 leader_3 leader_4 leader_5, grpvar(leader_fem) rowvarlabels  format(%8.2f) save("$working_ANALYSIS/results/tables/S9_leader_types.xlsx") replace
restore



*Supplementary Dataset S10: In-game behavior by leader composition
eststo game1: reg game_total_gamerelated leader_comp2_BS leader_comp3_BS leader_comp4_BS total_leaders share_female_percent3_BS sequence $controls, r
eststo game2: reg game_propose_rule leader_comp2_BS leader_comp3_BS leader_comp4_BS total_leaders share_female_percent3_BS sequence $controls, r
eststo game3: reg game_agree_rule leader_comp2_BS leader_comp3_BS leader_comp4_BS total_leaders share_female_percent3_BS sequence $controls, r
eststo game4: reg game_almost_opt_inv_r9_10 leader_comp2_BS leader_comp3_BS leader_comp4_BS total_leaders share_female_percent3_BS sequence $controls, r
eststo game5: reg game_come_back leader_comp2_BS leader_comp3_BS leader_comp4_BS total_leaders share_female_percent3_BS sequence $controls, r
eststo game6: reg game_discussed_formally leader_comp2_BS leader_comp3_BS leader_comp4_BS total_leaders share_female_percent3_BS sequence $controls, r


esttab game1 game2 game3 game4 game5 game6 using "$working_ANALYSIS\results\tables\S10_ingame_behavior_by_leader_composition.rtf",plain mtitles("Game related discussions #" "Proposed rules #" "Agreed rules #" "Cooperative outcome R9/10" "Come back #" "Formal discussions #") se transform(ln*: exp(@) exp(@))  b(%4.2f) label stats(N, labels("N") fmt(%4.0f %4.2f)) star(* 0.10 ** 0.05 *** 0.01) varlabels(,elist(weight:_cons "{break}{hline @width}"))  nonotes addnotes("Notes: Estimates are from OLS regressions using regressions with robust standard errors in brackets. * p<0.10, ** p<0.05, *** p<0.01") replace 



** EOF