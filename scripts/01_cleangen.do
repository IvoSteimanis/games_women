*--------------------------------------------------------------------------
* SCRIPT: 01_cleangen.do
* PURPOSE: importa excel files and cleans data from the surveys
*--------------------------------------------------------------------------

*----------------------------
* 1) Import data
*----------------------------
/*-------------------------------------------------------------------
*
Step 1: Get Info on villages (control & game, excluded etc). Saved as "2022_09_identifier_included_excluded"
Step 2: Get Census 2011 data. Saved as "2022_06_Mandla_Census"
Step 3: Import game excel data. Saved as "2022_06_Mandla_Game_raw"
Step 4: Merge "2022_09_identifier_included_excluded" with  "2022_06_Mandla_Census" and "2022_06_Mandla_Game_raw" and clean data. Saved as "2022_06_Mandla_Game". Includes all relevant information on the play within the game at individual player level.
Step 5: import data on the Facilitator Teams and the Intervention dates. Saved as "Data_Facilitators"
Step 6. Merge "2022_06_Mandla_Game" and "Data_Facilitators"
Step 7: Convert Individual Game data to game data at the village level which we can then merge with the baseline and endline survey data. Saved as "2022_06_Mandla_Game_village_long"
Step 8: import excel sheet with Baseline survey data. Saved as "2022_09_Survey_Baseline"
Step 9: import excel sheet with Endline survey data. Saved as "2022_09_Survey_Endline"
Step 10: Merge "2022_09_Survey_Baseline" and "2022_09_Survey_Endline" --> data has wide format. Saved as "2022_09_Survey_Wide"
Step 11. Merge "2022_09_Survey_Wide" with census data (TO DO)
Step 12: Change wide format into long format. Saved as "2022_09_Survey_Long"
Step 13: Merge "2022_09_Survey_Long" with "2022_06_Mandla_Game_village_long". Saved as "2022_09_Survey&Game_Long"
Step 14: Tranform "2022_09_Survey&Game_Long" again into wide format for robustness checks "2022_09_Survey&Game_Wide"
*/
*-------------------------------------------------------------------
clear
import excel "$working_ANALYSIS/data/Overview_games_intervention_control.xls", sheet ("Sheet1") firstrow

rename Site_ID site_ID

rename original_sample original_sample_old
gen original_sample =.
replace original_sample =1 if original_sample_old == "game was played"
replace original_sample =2 if original_sample_old == "in control list"
replace original_sample =3 if original_sample_old == "FES sample only"
replace original_sample = . if original_sample_old == "not in list"
replace original_sample =. if original_sample_old == "4"
label define samp 1 "game was played" 2 "in control sample" 3 "only FES sample", replace
label values original_sample samp
drop original_sample_old

rename Sample_variable Sample_variable_old
gen Sample_variable =.
replace Sample_variable = 1 if Sample_variable_old == "treated sample"
replace Sample_variable = 2 if Sample_variable_old == "control sample"
replace Sample_variable = 3 if Sample_variable_old == "not in sample"
label define  sample 1 "Treated Sample" 2 "Control Sample" 3 "Not in Sample", replace
label values Sample_variable sample
drop Sample_variable_old

rename game_played game_played_old
gen game_played =.
replace game_played = 1 if game_played_old == "yes"
replace game_played = 0 if game_played_old == "no"
label define played 1 "Game played" 0 "Game not played"
label values game_played played
drop game_played_old

rename FES_site FES_site_old
gen FES_site =.
replace FES_site = 1 if FES_site_old == "yes"
replace FES_site = 0 if FES_site_old == "no"
label define fes 1 "NGO active in village" 0 "NGO not active in village"
label values FES_site fes
drop FES_site_old
label var FES_site "Indicates if NGO is active in village or not"

rename payment_form payment_form_old
gen payment_form =.
replace payment_form = 1 if payment_form_old == "Individual payment"
replace payment_form = 0 if payment_form_old == "Community payment"
label define pay 1 "Individual performance pay" 0 "Community lump-sum pay"
label values payment_form pay 
drop payment_form_old
label var payment_form "Payment form used in game villages"

label var No_HH "Number of households in village"
label var Shar_SCST "Share of tribal population in village"
label var Shar_Lit "Share of literate population in village"

drop game_played_ip game_played_cp
drop if Sample_variable ==  3  // check again Kanskheda  Khuksar_RF

save "$working_ANALYSIS/data/2022_09_identifier_included_excluded", replace


*##############################
* GET Census Data
*##############################
insheet using "$working_ANALYSIS/data/Zensus_Mandla.csv", delimiter (";") clear
drop if statecode ==.
rename villagename site
tostring (site), replace

generate site_ID = .
* Game Villages
replace site_ID = 1  if site == "Deori"
replace site_ID = 2   if site == "Atarchuha"
replace site_ID = 3   if site == "Atariya"
replace site_ID = 4   if site == "Baghraudi_FV" // in survey file "Baghraudi F.V". Is the same village
replace site_ID = 5   if site == "Banijagoan" // in survey file  "Baniyagaon". Is the same village
replace site_ID = 6   if site == "Bariha"
replace site_ID = 7   if site == "Batwar"
replace site_ID = 8   if site == "Bhapsa"
replace site_ID = 9   if site == "Budhanwara"
replace site_ID = 10   if site == "Chandiya_Ryt" // in survey file"Chandiya Ryt.". Is the same village
replace site_ID = 11  if site == "Changariya"
replace site_ID = 12  if site == "Chatuwakhar"
replace site_ID = 13  if site == "Dhamangaon"
replace site_ID = 14  if site == "Dharampuri_Mal" //  in survey file "Dharampuri Mal.".  Is the same village
replace site_ID = 15  if site == "Dilwara"
replace site_ID = 16  if site == "Dudka"
replace site_ID = 17  if site == "Dungaria" 
replace site_ID = 18  if site == "Dungariya_Ramnagar"
replace site_ID = 19  if site == "Dungravt" //  in survey file "Dungra Ryt". Is the same village.
replace site_ID = 20  if site == "Fonk"
replace site_ID = 21  if site == "Ghont"
replace site_ID = 22  if site == "Gubri"
replace site_ID = 23  if site == "Gunegaon"
replace site_ID = 24  if site == "Gunehara"
replace site_ID = 25  if site == "Jhagul"
replace site_ID = 26  if site == "Jhulup"
replace site_ID = 27  if site == "Kanhari_Kalan" //  in survey file "Kanhari Kala". Is the same village.
replace site_ID = 28  if site == "Kanhari_Khurd" //  in survey file "Kanhari Khurd". Is the same village.
replace site_ID = 29  if site == "Kanskheda"
replace site_ID = 30  if site == "Kata_Mal" // in survey file "Kata Mal.". Is the same village.
replace site_ID = 31  if site == "Katanga_Ryt" // in survey file "Katanga Ryt.". Is the same village.
replace site_ID = 32  if site == "Khalaudi_FV" // in survey file "Khalodi". Is the same village.
replace site_ID = 33  if site == "Khamrauti" // in survey file "Khamaroti". Is the same village.
replace site_ID = 34  if site == "Kharpariya"
replace site_ID = 35  if site == "Khatiya_Narangi" // in survey file "Khatiya Narangi". Is the same village.
replace site_ID = 36  if site == "Khirahani" // in survey file "Khirhani". Is the same village.
replace site_ID = 37  if site == "Khuksar_RF"  // No sample village. I think game was played during facilitators training program 
drop if site_ID == 37
replace site_ID = 38  if site == "Kosampani"
replace site_ID = 39  if site == "Magdha"
replace site_ID = 40  if site == "Manegaon"
replace site_ID = 41  if site == "Mangaveli_Mal" //  in survey file "Mangaveli Mal.". Is the same village.
replace site_ID = 42  if site == "Mangaveli_Ryt" //  in survey file "Mangaveli Rayat". Is the same village.
replace site_ID = 43  if site == "Manikpur_Mal" //  in survey file "Manikpur Mal.". Is the same village.
replace site_ID = 44  if site == "Manoharpur"
replace site_ID = 45  if site == "Medhatal"
replace site_ID = 46  if site == "Mubala_Mal" //  in survey file "Mubala Mal.". Is the same village.
replace site_ID = 47  if site == "Mulwalasani_Ryt" //  in survey file "Muwalasani Ryt.". Is the same village.
replace site_ID = 48  if site == "Nakawal"
replace site_ID = 49  if site == "Padariya" // in survey file "Pasriya gatapancha". Is the same village.
replace site_ID = 50  if site == "Rata"
replace site_ID = 51  if site == "Saradoli_Mal" // in survey file "Sarasdoli Mal.". Is the same village.
replace site_ID = 52  if site == "Sarasdoli" // in survey file  "Sarasdoli Ryt.". Is the same village.
replace site_ID = 53  if site == "Sarhi"
replace site_ID = 54  if site == "Sautia"
replace site_ID = 55  if site == "Shahapur" // in survey file "Shahpur". Is the same village.
replace site_ID = 56  if site == "Samaiya_Bhagpur_FV" // ihn survey file "Simaiya Bhagpur F.V.". Is the same village.
replace site_ID = 57  if site == "Taktuwa" // in survey file "Taktauwa". Is the same village.
replace site_ID = 58  if site == "Thonda" // in survey file  "Thoda". Is the same village.
replace site_ID = 59  if site == "Tilari"
replace site_ID = 60  if site == "Umariya_FV" //  in survey file "Umariya F.V.". Is the same village.

*Control Villages
replace site_ID = 201 	if site == "Bhawartal"
replace site_ID = 202 	if site == "Malara"
replace site_ID = 203 	if site == "Harrabhat Jar"
replace site_ID = 204 	if site == "Patpara"
replace site_ID = 205 	if site == "Aurai Mal.(Ourai Mal.)"
replace site_ID = 206 	if site == "Mohgaon Ryt" // no change made. 2x Mohgaon --> which one is the correct one? 
replace site_ID = 207 	if site == "Bamhani Ryt."
replace site_ID = 209 	if site == "Mohgaon Mal"  // no change made. 2x Mohgaon --> which one is the correct one? 
replace site_ID = 210 	if site == "Saamp"  // no change made
replace site_ID = 211 	if site == "Kariwah"
replace site_ID = 212 	if site == "Harrabhat Mal."
replace site_ID = 213 	if site == "Bhawan"
replace site_ID = 214  if site == "Ratanpur Ryt."
replace site_ID = 215 	if site == "Vishanpura Ryt."
replace site_ID = 216 	if site == "Chaunranga Mal."
replace site_ID = 217 	if site == "Mohad" //  in survey file  "Muhad". Is the same village.
replace site_ID = 218 	if site == "Navgawan (Naigawan)Ryt."
replace site_ID = 219 	if site == "Barkheda Ryt."
replace site_ID = 220  if site == "Barkheda"
replace site_ID = 221	if site == "Bhimpuri Ryt." 
replace site_ID = 222	if site == "Bhundelakhoh" // no village called Bhundelakhoh in data but a village called Bundela
replace site_ID = 223	if site ==  "Chauranga (Chakiya Tola)" // no change made 
replace site_ID = 224	if site == "Dudhari"
replace site_ID = 225	if site == "Indra F.V."
replace site_ID = 226	if site == "Karanjia Mal."
replace site_ID = 227	if site == "Katanga Mal." 
replace site_ID = 228	if site == "Katangi"
replace site_ID = 229 	if site == "Khatola" // no change made
replace site_ID = 230 	if site == "Khuluwa" 
replace site_ID = 231	if site == "Lohta F.V."
replace site_ID = 232	if site == "Rajo Mal."
replace site_ID = 233	if site == "Surehala"
replace site_ID = 234	if site == "Umariya Mal."
replace site_ID = 235	if site == "Umarwada"
replace site_ID = 236	if site == "Urdali Ryt." // in survey  file "Urdali". is the same village
replace site = "Urdali" if site_ID == 236
replace site_ID = 238	if site == "Umardih" // in survey file "Umardoh". is the same village
replace site_ID = 239 if site == "Umariya (Zariya Puliyawala Nala)" // no change made
replace site_ID = 240 if site == "Umariya (Zariya Nala)" // no change made
replace site_ID = 241	if site == "Dungariya (Bhedo nala)" // no change made
replace site_ID = 244 if site == "Umariya" //  no changes made
replace site_ID = 242 	if site == "Urdali Mal." 
replace site_ID = 243 	if site == "Ramhepur" 
replace site_ID = 245 	if site ==  "Aurai Ryt.(Ourai Ryt.)" // in other file "Aouri Rayat"
replace site_ID = 247 	if site == "Birsa Mal." // in other file only Birsa 
replace site_ID = 248  if site == "Danitola" // no change made
replace site_ID = 249 if site == "Kata Jar"
replace site_ID = 250	if site == "Matawal Alias Danitola" // in survey file "Mataval". same village.
replace site_ID = 251	if site ==  "Niwsa" // in survey file "Newsa". same village
replace site_ID = 252	if site == "Ramnagar"

sort site_ID site
tab site if site_ID ==.

*----------------------
drop if site_ID ==.

keep site  site_ID total_hh total_population total_male total_female totalscheduledcastespopulationof totalscheduledcastesmalepopulati totalscheduledcastesfemalepopula totalscheduledtribespopulationof totalscheduledtribesmalepopulati totalscheduledtribesfemalepopula   govtprimaryschoolnumbers  privateprimaryschoolnumbers govtmiddleschoolnumbers privatemiddleschoolnumbers govtsecondaryschoolnumbers privatesecondaryschoolnumbers payment_lump_individ payment_announcement type
drop if type ==.

label var payment_lump_individ "Random allocation for payment method"
gen payment_form = .
replace payment_form = 1 if payment_lump_individ ==1
replace payment_form = 0 if payment_lump_individ ==0
label define payment_form_l 1 "IP" 0 "CP", replace
label values payment_form payment_form_l
label var payment_form "Form of payment"

rename payment_announcement payment_announcement_str
gen payment_announcement = .
replace payment_announcement = 1 if payment_announcement_str ==1
replace payment_announcement = 0 if payment_announcement_str ==0
label define announcement_form_l 1 "Payment announced" 0 "Payment not announced", replace
label values payment_announcement announcement_form_l
label var payment_announcement "Form of announcement"
drop payment_announcement_str

rename total_hh census_no_hh
rename total_population census_population_total
rename total_male census_population_males
rename total_female census_population_females
rename totalscheduledcastespopulationof census_caste_total
rename totalscheduledcastesmalepopulati census_caste_males
rename totalscheduledcastesfemalepopula census_caste_females
rename totalscheduledtribespopulationof census_tribes_total
rename totalscheduledtribesmalepopulati census_tribes_males
rename totalscheduledtribesfemalepopula census_tribes_females

rename govtprimaryschoolnumbers census_gov_school_prim
rename privateprimaryschoolnumbers census_priv_school_prim
rename govtmiddleschoolnumbers census_gov_school_middle
rename privatemiddleschoolnumbers census_priv_school_middle
rename govtsecondaryschoolnumbers census_gov_school_sec
rename privatesecondaryschoolnumbers census_priv_school_sec

label var census_no_hh "Census: Total households in village"
label var census_population_total "Census: Total population in village"
label var census_population_males   "Census: Total male in village"
label var census_population_females "Census: Total female in village"
label var census_caste_total  "Census: Total scheduled castes population of village"
label var census_caste_males "Census: Total male scheduled castes population of village"
label var census_caste_females "Census: Total female scheduled castes population of village"
label var census_tribes_total "Census: Total scheduled tribes population of village"
label var census_tribes_males  "Census: Total male scheduled tribes population of village"
label var census_tribes_females  "Census: Total female scheduled tribes population of village"
label var census_gov_school_prim  "Census: Number of govt primary schools"
label var census_priv_school_prim "Census: Number of private primary schools"
label var census_gov_school_middle "Census: Number of govt middle schools"
label var census_priv_school_middle "Census: Number of private middle schools"
label var census_gov_school_sec "Census: Number of govt secondary schools"
label var census_priv_school_sec "Census: Number of private secondary schools"

rename site site_census

rename payment_form paymentform
rename *_females *_fem
save "$working_ANALYSIS/data/2022_06_Mandla_Census", replace



*##############################
* GET GAME DATA
*##############################
global sites "Atarchuha Atariya Baghraudi_FV Banijagoan Bariha Batwar Bhapsa Budhanwara Chandiya_Ryt Changariya Chatuwakhar Deori Dhamangaon Dharampuri_Mal Dilwara Dudka Dungaria Dungariya_Ramnagar Dungravt Fonk Ghont Gubri Gunegaon Gunehara Jhagul Jhulup Kanhari_Kalan Kanhari_Khurd Kanskheda Kata_Mal Katanga_Ryt Khalaudi_FV Khamrauti Kharpariya Khatiya_Narangi Khirahani Khuksar_RF Kosampani Magdha Manegaon Mangaveli_Mal Mangaveli_Ryt Manikpur_Mal Manoharpur Medhatal Mubala_Mal Mulwalasani_Ryt Nakawal Padariya Rata Saradoli_Mal Sarasdoli Sarhi Sautia Shahapur Samaiya_Bhagpur_FV Taktuwa Thonda Tilari Umariya_FV"

foreach v of global sites {
	insheet using "$working_ANALYSIS/data/`v'_soec.csv", delimiter(";") clear 
	sort play_no
	save "$working_ANALYSIS/data/`v'_soec", replace
	
	insheet using "$working_ANALYSIS/data/`v'_com.csv", delimiter(";") clear 
	sort play_no
	drop if round >10
	save "$working_ANALYSIS/data/`v'_com", replace
	
	insheet using "$working_ANALYSIS/data/`v'_game.csv", delimiter(";") clear 
	sort player_id
	rename player_id play_no
	save "$working_ANALYSIS/data/`v'_game", replace
		
	merge m:1 play_no using "$working_ANALYSIS/data/`v'_soec.dta"
	drop if round == . | round == 0
	drop _merge
	save "$working_ANALYSIS/data/`v'", replace

	merge 1:1 play_no round using "$working_ANALYSIS/data/`v'_com.dta"
	drop _merge
	sort play_no round
	
	sort play_no round
	tostring (sex), replace
	tostring (edu), replace
	tostring (role_yn), replace
	tostring (role), replace
	tostring (cont_lab), replace
	tostring (cont_money), replace
	tostring (reci_wat), replace
	tostring (hyp_crop), replace
	tostring (size), replace
	tostring (facil), replace
	tostring (coll_money), replace
	tostring (dist_field), replace

	save "$working_ANALYSIS/data/`v'", replace	
}
******************************************************************

append using "$working_ANALYSIS/data/Atarchuha"
 append using "$working_ANALYSIS/data/Atariya"
 append using "$working_ANALYSIS/data/Baghraudi_FV"
 append using "$working_ANALYSIS/data/Banijagoan"
 append using "$working_ANALYSIS/data/Bariha"
 append using "$working_ANALYSIS/data/Batwar"
 append using "$working_ANALYSIS/data/Bhapsa"
 append using "$working_ANALYSIS/data/Budhanwara"
 append using "$working_ANALYSIS/data/Chandiya_Ryt"
 append using "$working_ANALYSIS/data/Changariya"
 append using "$working_ANALYSIS/data/Chatuwakhar"
 append using "$working_ANALYSIS/data/Deori"
 append using "$working_ANALYSIS/data/Dhamangaon"
 append using "$working_ANALYSIS/data/Dharampuri_Mal"
 append using "$working_ANALYSIS/data/Dilwara"
 append using "$working_ANALYSIS/data/Dudka"
 append using "$working_ANALYSIS/data/Dungaria"
 append using "$working_ANALYSIS/data/Dungariya_Ramnagar"
 append using "$working_ANALYSIS/data/Dungravt"
 append using "$working_ANALYSIS/data/Fonk"
 append using "$working_ANALYSIS/data/Ghont"
 append using "$working_ANALYSIS/data/Gubri"
 append using "$working_ANALYSIS/data/Gunegaon"
 append using "$working_ANALYSIS/data/Gunehara"
 append using "$working_ANALYSIS/data/Jhagul"
 append using "$working_ANALYSIS/data/Jhulup"
 append using "$working_ANALYSIS/data/Kanhari_Kalan"
 append using "$working_ANALYSIS/data/Kanhari_Khurd"
 append using "$working_ANALYSIS/data/Kanskheda"
 append using "$working_ANALYSIS/data/Kata_Mal"
 append using "$working_ANALYSIS/data/Katanga_Ryt"
 append using "$working_ANALYSIS/data/Khalaudi_FV"
 append using "$working_ANALYSIS/data/Khamrauti"
 append using "$working_ANALYSIS/data/Kharpariya"
 append using "$working_ANALYSIS/data/Khatiya_Narangi"
 append using "$working_ANALYSIS/data/Khirahani"
 append using "$working_ANALYSIS/data/Khuksar_RF"
 append using "$working_ANALYSIS/data/Kosampani"
 append using "$working_ANALYSIS/data/Magdha"
 append using "$working_ANALYSIS/data/Manegaon"
 append using "$working_ANALYSIS/data/Mangaveli_Mal"
 append using "$working_ANALYSIS/data/Mangaveli_Ryt"
 append using "$working_ANALYSIS/data/Manikpur_Mal"
 append using "$working_ANALYSIS/data/Manoharpur"
 append using "$working_ANALYSIS/data/Medhatal"
 append using "$working_ANALYSIS/data/Mubala_Mal"
 append using "$working_ANALYSIS/data/Mulwalasani_Ryt"
 append using "$working_ANALYSIS/data/Nakawal"
 append using "$working_ANALYSIS/data/Padariya"
 append using "$working_ANALYSIS/data/Rata"
 append using "$working_ANALYSIS/data/Saradoli_Mal"
 append using "$working_ANALYSIS/data/Sarasdoli"
 append using "$working_ANALYSIS/data/Sarhi"
 append using "$working_ANALYSIS/data/Sautia"
 append using "$working_ANALYSIS/data/Shahapur"
 append using "$working_ANALYSIS/data/Samaiya_Bhagpur_FV"
 append using "$working_ANALYSIS/data/Taktuwa"
 append using "$working_ANALYSIS/data/Thonda"
 append using "$working_ANALYSIS/data/Tilari"
drop if round == . | round == 0

******************************************************************
*CREATE INDIVIDUAL SITE_ID
******************************************************************
generate site_ID = .
 replace site_ID = 1   if site == "Deori"
 replace site_ID = 2   if site == "Atarchuha"
 replace site_ID = 3   if site == "Atariya"
 replace site_ID = 4   if site == "Baghraudi_FV"
 replace site_ID = 5   if site == "Banijagoan"
 replace site_ID = 6   if site == "Bariha"
 replace site_ID = 7   if site == "Batwar"
 replace site_ID = 8   if site == "Bhapsa"
 replace site_ID = 9   if site == "Budhanwara"
 replace site_ID = 10  if site == "Chandiya_Ryt"
 replace site_ID = 11  if site == "Changariya"
 replace site_ID = 12  if site == "Chatuwakhar"
 replace site_ID = 13  if site == "Dhamangaon"
 replace site_ID = 14  if site == "Dharampuri_Mal"
 replace site_ID = 15  if site == "Dilwara"
 replace site_ID = 16  if site == "Dudka"
 replace site_ID = 17  if site == "Dungaria"
 replace site_ID = 18  if site == "Dungariya_Ramnagar"
 replace site_ID = 19  if site == "Dungravt"
 replace site_ID = 20  if site == "Fonk"
 replace site_ID = 21  if site == "Ghont"
 replace site_ID = 22  if site == "Gubri"
 replace site_ID = 23  if site == "Gunegaon"
 replace site_ID = 24  if site == "Gunehara"
 replace site_ID = 25  if site == "Jhagul"
 replace site_ID = 26  if site == "Jhulup"
 replace site_ID = 27  if site == "Kanhari_Kalan"
 replace site_ID = 28  if site == "Kanhari_Khurd"
 replace site_ID = 29  if site == "Kanskheda"
 replace site_ID = 30  if site == "Kata_Mal"
 replace site_ID = 31  if site == "Katanga_Ryt"
 replace site_ID = 32  if site == "Khalaudi_FV"
 replace site_ID = 33  if site == "Khamrauti"
 replace site_ID = 34  if site == "Kharpariya"
 replace site_ID = 35  if site == "Khatiya_Narangi"
 replace site_ID = 36  if site == "Khirahani"
 replace site_ID = 37  if site == "Khuksar_RF"
 replace site_ID = 38  if site == "Kosampani"
 replace site_ID = 39  if site == "Magdha"
 replace site_ID = 40  if site == "Manegaon"
 replace site_ID = 41  if site == "Mangaveli_Mal"
 replace site_ID = 42  if site == "Mangaveli_Ryt"
 replace site_ID = 43  if site == "Manikpur_Mal"
 replace site_ID = 44  if site == "Manoharpur"
 replace site_ID = 45  if site == "Medhatal"
 replace site_ID = 46  if site == "Mubala_Mal"
 replace site_ID = 47  if site == "Mulwalasani_Ryt"
 replace site_ID = 48  if site == "Nakawal"
 replace site_ID = 49  if site == "Padariya"
 replace site_ID = 50  if site == "Rata"
 replace site_ID = 51  if site == "Saradoli_Mal"
 replace site_ID = 52  if site == "Sarasdoli"
 replace site_ID = 53  if site == "Sarhi"
 replace site_ID = 54  if site == "Sautia"
 replace site_ID = 55  if site == "Shahapur"
 replace site_ID = 56  if site == "Samaiya_Bhagpur_FV"
 replace site_ID = 57  if site == "Taktuwa"
 replace site_ID = 58  if site == "Thonda"
 replace site_ID = 59  if site == "Tilari"
 replace site_ID = 60  if site == "Umariya_FV"
 
 
******************************************************************
*Save Data Set
******************************************************************
save "$working_ANALYSIS/data/2022_06_Mandla_Game_raw", replace

******************************************************************
* Match with info on excluded sites etc
******************************************************************
use  "$working_ANALYSIS/data/2022_09_identifier_included_excluded", clear 
merge m:m site_ID using "$working_ANALYSIS/data/2022_06_Mandla_Game_raw" // Kanskheda & Khuksar_RF
drop if play_no ==.


drop _merge

******************************************************************
*Match with  census 2011 data to get village payment allocation and other basic village infos
******************************************************************

rename payment_form payment_form_2
merge m:1 site_ID using "$working_ANALYSIS/data/2022_06_Mandla_Census"

*keep for now only the game village observations of the census and not the observations of the control villages 
tab site if _merge ==1 // For  Khuksar_RF, we do not have census data observations?
tab site_census if _merge ==2 // For  Khuksar_RF, we do not have census data observations?
drop if _merge ==2
drop _merge


******************************************************************
*CLEAN AND CLARIFY DATA SET
******************************************************************
drop nrega_used dev_pro_yes table_path table_next threshold_path excluded drop_1 drop_2
rename total_earning round_earning

******************************************************************
*Correct wring player number allocation in raw data
******************************************************************
gen play_no2 = .
replace play_no2 =	7	if play_no == 	1
replace play_no2 =	6	if play_no == 	2
replace play_no2 =	5	if play_no == 	3
replace play_no2 =	4	if play_no == 	4
replace play_no2 =	10	if play_no == 	5
replace play_no2 =	9	if play_no == 	6
replace play_no2 =	8	if play_no == 	7
replace play_no2 =	14	if play_no == 	8
replace play_no2 =	13	if play_no == 	9
replace play_no2 =	12	if play_no == 	10
replace play_no2 =	11	if play_no == 	11
replace play_no2 =	3	if play_no == 	12
replace play_no2 =	2	if play_no == 	13
replace play_no2 =	1	if play_no == 	14
replace play_no = play_no2
drop play_no2

replace group_b = 	2	if play_no ==	1
replace group_b = 	2	if play_no ==	2
replace group_b = 	2	if play_no ==	3
replace group_b = 	1	if play_no ==	4
replace group_b = 	1	if play_no ==	5
replace group_b = 	1	if play_no ==	6
replace group_b = 	1	if play_no ==	7
replace group_b = 	1	if play_no ==	8
replace group_b = 	1	if play_no ==	9
replace group_b = 	1	if play_no ==	10
replace group_b = 	2	if play_no ==	11
replace group_b = 	2	if play_no ==	12
replace group_b = 	2	if play_no ==	13
replace group_b = 	2	if play_no ==	14

replace pos_b = 	7	if play_no ==	1
replace pos_b = 	6	if play_no ==	2
replace pos_b = 	5	if play_no ==	3
replace pos_b = 	4	if play_no ==	4
replace pos_b = 	3	if play_no ==	5
replace pos_b = 	2	if play_no ==	6
replace pos_b = 	1	if play_no ==	7
replace pos_b = 	7	if play_no ==	8
replace pos_b = 	6	if play_no ==	9
replace pos_b = 	5	if play_no ==	10
replace pos_b = 	4	if play_no ==	11
replace pos_b = 	3	if play_no ==	12
replace pos_b = 	2	if play_no ==	13
replace pos_b = 	1	if play_no ==	14

********************************************************************************
*******************************************************************************
* Dummy für Nicht-Sample Dörfer
global samples "Atarchuha Atariya Baghraudi_FV Banijagoan Bariha Batwar Bhapsa Budhanwara Chandiya_Ryt Changariya Chatuwakhar Deori Dhamangaon Dharampuri_Mal Dilwara Dudka Dungaria Dungariya_Ramnagar Dungravt Fonk Ghont Gubri Gunegaon Gunehara Jhagul Jhulup Kanhari_Kalan Kanhari_Khurd Kata_Mal Khalaudi_FV Khamrauti Kharpariya Khatiya_Narangi Khirahani Kosampani Magdha Manegaon Mangaveli_Mal Mangaveli_Ryt Manikpur_Mal Manoharpur Medhatal Mubala_Mal Mulwalasani_Ryt Padariya Rata Saradoli_Mal Sarasdoli Sarhi Sautia Shahapur Samaiya_Bhagpur_FV Taktuwa Thonda Tilari Umariya_FV"
global not_sample "Kanskheda Katanga_Ryt Khuksar_RF Nakawal"

gen sample_vill =.
replace sample_vill  = 1 if site == "Atarchuha"
 replace sample_vill = 1 if site == "Atariya"
 replace sample_vill = 1 if site == "Baghraudi_FV"
 replace sample_vill = 1 if site == "Banijagoan"
 replace sample_vill = 1 if site == "Bariha"
 replace sample_vill = 1 if site == "Batwar"
 replace sample_vill = 1 if site == "Bhapsa"
 replace sample_vill = 1 if site == "Budhanwara"
 replace sample_vill = 1 if site == "Chandiya_Ryt"
 replace sample_vill = 1 if site == "Changariya"
 replace sample_vill = 1 if site == "Chatuwakhar"
 replace sample_vill = 1 if site == "Deori"
 replace sample_vill = 1 if site == "Dhamangaon"
 replace sample_vill = 1 if site == "Dharampuri_Mal"
 replace sample_vill = 1 if site == "Dilwara"
 replace sample_vill = 1 if site == "Dudka"
 replace sample_vill = 1 if site == "Dungaria"
 replace sample_vill = 1 if site == "Dungariya_Ramnagar"
 replace sample_vill = 1 if site == "Dungravt"
 replace sample_vill = 1 if site == "Fonk"
 replace sample_vill = 1 if site == "Ghont"
 replace sample_vill = 1 if site == "Gubri"
 replace sample_vill = 1 if site == "Gunegaon"
 replace sample_vill = 1 if site == "Gunehara"
 replace sample_vill = 1 if site == "Jhagul"
 replace sample_vill = 1 if site == "Jhulup"
 replace sample_vill = 1 if site == "Kanhari_Kalan"
 replace sample_vill = 1 if site == "Kanhari_Khurd"
 replace sample_vill = 0 if site == "Kanskheda"
 replace sample_vill = 1 if site == "Kata_Mal"
 replace sample_vill = 1 if site == "Katanga_Ryt"
 replace sample_vill = 1 if site == "Khalaudi_FV"
 replace sample_vill = 1 if site == "Khamrauti"
 replace sample_vill = 1 if site == "Kharpariya"
 replace sample_vill = 1 if site == "Khatiya_Narangi"
 replace sample_vill = 1 if site == "Khirahani"
 replace sample_vill = 0 if site == "Khuksar_RF"
 replace sample_vill = 1 if site == "Kosampani"
 replace sample_vill = 1 if site == "Magdha"
 replace sample_vill = 1 if site == "Manegaon"
 replace sample_vill = 1 if site == "Mangaveli_Mal"
 replace sample_vill = 1 if site == "Mangaveli_Ryt"
 replace sample_vill = 1 if site == "Manikpur_Mal"
 replace sample_vill = 1 if site == "Manoharpur"
 replace sample_vill = 1 if site == "Medhatal"
 replace sample_vill = 1 if site == "Mubala_Mal"
 replace sample_vill = 1 if site == "Mulwalasani_Ryt"
 replace sample_vill = 0 if site == "Nakawal"
 replace sample_vill = 1 if site == "Padariya"
 replace sample_vill = 1 if site == "Rata"
 replace sample_vill = 1 if site == "Saradoli_Mal"
 replace sample_vill = 1 if site == "Sarasdoli"
 replace sample_vill = 1 if site == "Sarhi"
 replace sample_vill = 1 if site == "Sautia"
 replace sample_vill = 1 if site == "Shahapur"
 replace sample_vill = 1 if site == "Samaiya_Bhagpur_FV"
 replace sample_vill = 1 if site == "Taktuwa"
 replace sample_vill = 1 if site == "Thonda"
 replace sample_vill = 1 if site == "Tilari"
 replace sample_vill = 1 if site == "Umariya_FV"
label var sample_vill "Village of Sample List (y=1;n=0)"

******************************************************************
******************************************************************
rename size size_str
gen size =.
replace size = 0 	if size_str=="0"
replace size = 0.25 if size_str=="0,25"
replace size = 0.5 	if size_str=="0,5"
replace size = 1 	if size_str=="1"
replace size = 1.25 if size_str=="1,25"
replace size = 1.5 	if size_str=="1,5"
replace size = 10 	if size_str=="10"
replace size = 11 	if size_str=="11"
replace size = 12 	if size_str=="12"
replace size = 13 	if size_str=="13"
replace size = 17	if size_str=="17"
replace size = 18	if size_str=="18"
replace size = 2 	if size_str=="2"
replace size = 2.25 if size_str=="2,25"
replace size = 2.5 	if size_str=="2,5"
replace size = 3 	if size_str=="3"
replace size = 3.5 	if size_str=="3,5"
replace size = 4 	if size_str=="4"
replace size = 4.5 	if size_str=="4,5"
replace size = 5 	if size_str=="5"
replace size = 5.5 	if size_str=="5,5"
replace size = 6 	if size_str=="6"
replace size = 6.5 	if size_str=="6,5"
replace size = 7 	if size_str=="7"
replace size = 7.5 	if size_str=="7,5"
replace size = 8 	if size_str=="8"
replace size = 8.5 	if size_str=="8,5"
replace size = 9 	if size_str=="9"
label var size "Size of fields"


 ******************************************************************
*Create Player ID
******************************************************************
tab site
gen playerid = .
replace playerid = .
 replace playerid = 1000 + play_no if site == "Atarchuha"
 replace playerid = 1100 + play_no if site == "Atariya"
 replace playerid = 1200 + play_no if site == "Baghraudi_FV"
 replace playerid = 1300 + play_no if site == "Banijagoan"
 replace playerid = 1400 + play_no if site == "Bariha"
 replace playerid = 1500 + play_no if site == "Batwar"
 replace playerid = 1600 + play_no if site == "Bhapsa"
 replace playerid = 1700 + play_no if site == "Budhanwara"
 replace playerid = 1800 + play_no if site == "Chandiya_Ryt"
 replace playerid = 1900 + play_no if site == "Changariya"
 replace playerid = 2000 + play_no if site == "Chatuwakhar"
 replace playerid = 2100 + play_no if site == "Deori"
 replace playerid = 2200 + play_no if site == "Dhamangaon"
 replace playerid = 2300 + play_no if site == "Dharampuri_Mal"
 replace playerid = 2400 + play_no if site == "Dilwara"
 replace playerid = 2500 + play_no if site == "Dudka"
 replace playerid = 2600 + play_no if site == "Dungaria"
 replace playerid = 2700 + play_no if site == "Dungariya_Ramnagar"
 replace playerid = 2800 + play_no if site == "Dungravt"
 replace playerid = 2900 + play_no if site == "Fonk"
 replace playerid = 3000 + play_no if site == "Ghont"
 replace playerid = 3100 + play_no if site == "Gubri"
 replace playerid = 3200 + play_no if site == "Gunegaon"
 replace playerid = 3300 + play_no if site == "Gunehara"
 replace playerid = 3400 + play_no if site == "Jhagul"
 replace playerid = 3500 + play_no if site == "Jhulup"
 replace playerid = 3600 + play_no if site == "Kanhari_Kalan"
 replace playerid = 3700 + play_no if site == "Kanhari_Khurd"
 replace playerid = 3800 + play_no if site == "Kanskheda"
 replace playerid = 3900 + play_no if site == "Kata_Mal"
 replace playerid = 4000 + play_no if site == "Katanga_Ryt"
 replace playerid = 4100 + play_no if site == "Khalaudi_FV"
 replace playerid = 4200 + play_no if site == "Khamrauti"
 replace playerid = 4300 + play_no if site == "Kharpariya"
 replace playerid = 4400 + play_no if site == "Khatiya_Narangi"
 replace playerid = 4500 + play_no if site == "Khirahani"
 replace playerid = 4600 + play_no if site == "Khuksar_RF"
 replace playerid = 4700 + play_no if site == "Kosampani"
 replace playerid = 4800 + play_no if site == "Magdha"
 replace playerid = 4900 + play_no if site == "Manegaon"
 replace playerid = 5000 + play_no if site == "Mangaveli_Mal"
 replace playerid = 5100 + play_no if site == "Mangaveli_Ryt"
 replace playerid = 5200 + play_no if site == "Manikpur_Mal"
 replace playerid = 5300 + play_no if site == "Manoharpur"
 replace playerid = 5400 + play_no if site == "Medhatal"
 replace playerid = 5500 + play_no if site == "Mubala_Mal"
 replace playerid = 5600 + play_no if site == "Mulwalasani_Ryt"
 replace playerid = 5700 + play_no if site == "Nakawal"
 replace playerid = 5800 + play_no if site == "Padariya"
 replace playerid = 5900 + play_no if site == "Rata"
 replace playerid = 6000 + play_no if site == "Saradoli_Mal"
 replace playerid = 6100 + play_no if site == "Sarasdoli"
 replace playerid = 6200 + play_no if site == "Sarhi"
 replace playerid = 6300 + play_no if site == "Sautia"
 replace playerid = 6400 + play_no if site == "Shahapur"
 replace playerid = 6500 + play_no if site == "Samaiya_Bhagpur_FV"
 replace playerid = 6600 + play_no if site == "Taktuwa"
 replace playerid = 6700 + play_no if site == "Thonda"
 replace playerid = 6800 + play_no if site == "Tilari"
 replace playerid = 6900 + play_no if site == "Umariya_FV"

******************************************************************
******************************************************************
rename edu edu_str
gen edu = .
replace edu = 1 if edu_str =="0"
replace edu = 1 if edu_str =="n"
replace edu = 1 if edu_str =="NO"
replace edu = 2 if edu_str =="1"
replace edu = 2 if edu_str =="2"
replace edu = 2 if edu_str =="3"
replace edu = 2 if edu_str =="4"
replace edu = 2 if edu_str =="5"
replace edu = 2 if edu_str =="5th"
replace edu = 2 if edu_str =="6"
replace edu = 2 if edu_str =="7"
replace edu = 2 if edu_str =="8"
replace edu = 2 if edu_str =="8th"
replace edu = 2 if edu_str =="8 CLASS"
replace edu = 3 if edu_str =="9"
replace edu = 3 if edu_str =="10"
replace edu = 3 if edu_str =="10th"
replace edu = 3 if edu_str =="11"
replace edu = 3 if edu_str =="12"
replace edu = 3 if edu_str =="12th"
replace edu = 4 if edu_str =="13"
replace edu = 4 if edu_str =="14"
replace edu = 4 if edu_str =="15"
replace edu = 4 if edu_str =="B A"
replace edu = 4 if edu_str =="B.A."
replace edu = 4 if edu_str =="BSc"
replace edu = 4 if edu_str =="15"
replace edu = 4 if edu_str =="B COM"
replace edu = 4 if edu_str =="B SC"
replace edu = 4 if edu_str =="BA"
replace edu = 5 if edu_str =="M.A"
replace edu = 5 if edu_str =="17"
replace edu = . if edu_str =="."
label define edu_1 1 "Iliterate" 2 "Primary" 3 "Secondary" 4 "Bachelor" 5 "Master" 
label values edu edu_1
label var edu "Education of participants"

******************************************************************
*Generate dummy to indicate if participants have a uni degree
gen uni_degree = .
replace uni_degree = 1 if edu >=4
replace uni_degree = 0 if edu <4
label var uni_degree "Participant has a uni degree"

*Generate variable on the share of participants that have a uni degree in the village
bysort site_ID  round: egen sum_uni_degree_village = total(uni_degree)
label var sum_uni_degree_village   "Sum of participant that have a uni degree"

tab sum_uni_degree_village if round ==1 & play_no==1
gen share_uni_degree_village =  sum_uni_degree_village/14
label var share_uni_degree_village "Share of participant that have a uni degree"

******************************************************************
*Generate dummy to indicate if participants are illiterate
gen illiterate =.
replace illiterate = 1 if edu ==1
replace illiterate = 0 if edu >1
label var illiterate "Participant is illiterate"

*Generate variable on the share of participants that are illiterate
bysort site_ID  round: egen sum_illiterate_village = total(illiterate)
label var sum_illiterate_village "Sum of participant that are illiterate"
gen share_illiterate_village =  sum_illiterate_village/14
tab share_illiterate_village if round ==1 & play_no==1
label var share_illiterate_village "Share of participant that are illiterate"

******************************************************************
*Correcting age variable & generate missing value for the ages of players 2706 & 2710
******************************************************************
replace age =. if age ==0
replace age=. if playerid ==2706
replace age=. if playerid ==2710

******************************************************************
rename sex sexstr
gen sex = .
replace sex = 1 if sexstr == "m"
replace sex = 1 if sexstr == "M"
replace sex = 1 if sexstr == "^M"
replace sex = 1 if sexstr == "n"
replace sex = 0 if sexstr == "f"
replace sex = 0 if sexstr == "F"
replace sex = . if sexstr == "0"
replace sex = . if sexstr == ""
replace sex = 1 if name == "Ganesh Durve"
replace sex = 1 if name == "Prallhad"
replace sex = 1 if playerid ==2710 
replace sex = 0 if playerid ==2101
replace sex = 1 if playerid ==2102
replace sex = 1 if playerid ==2103
replace sex = 1 if playerid ==2104
replace sex = 1 if playerid ==2105
replace sex = 0 if playerid ==2106
replace sex = 1 if playerid ==2107
replace sex = 1 if playerid ==2108
replace sex = 1 if playerid ==2109
replace sex = 1 if playerid ==2110
replace sex = 1 if playerid ==2111
replace sex = 1 if playerid ==2112
replace sex = 1 if playerid ==2113
replace sex = 0 if playerid ==2114
replace sex = 0 if playerid ==2706
label define sexl 1	"Male" 0 "Female"
label values sex sexl
label var sex "Sex of participants [1=Male,0=Female]"

******************************************************************
gen females =.
replace females = 1 if sex ==0
replace females = 0 if sex ==1

gen males =.
replace males = 1 if sex ==1
replace males = 0 if sex ==0

bysort site round : egen vill_males=sum(males) 
bysort site round : egen vill_females=sum(females) 
gen  share_female_village = vill_females/14

label var vill_males "Sum of males in village"
label var vill_females "Sum of females in village"
label var share_female_village "Share of females in village"

******************************************************************
tab role_yn
rename role_yn role_yn_str
gen role_yn = .
replace role_yn = 0 if role_yn_str== "0"
replace role_yn = 0 if role_yn_str== "N"
replace role_yn = 0 if role_yn_str== "N="
replace role_yn = 0 if role_yn_str== "n"
replace role_yn = 0 if role_yn_str== "No"
replace role_yn = 0 if role_yn_str== "NO"
replace role_yn = 0 if role_yn_str== "N0"
replace role_yn = 0 if role_yn_str== "NOI"
replace role_yn = 1 if role_yn_str== "Y"
replace role_yn = 1 if role_yn_str== "YES"
replace role_yn = 1 if role_yn_str== "Yes"
replace role_yn = 1 if role_yn_str== "y"
replace role_yn = 1 if role_yn_str== "yes"
replace role_yn = . if role_yn_str== ""

label define role_yn_l 1 "No" 0 "Yes" 
label values role_yn role_yn_1
label var role_yn "Role in community"

******************************************************************
gen elected_leader =.
replace elected_leader = 	0	if role ==	"AGANWADI TEACHER"
replace elected_leader = 	0	if role ==	"ANGANWADI TEACHER"
replace elected_leader = 	0	if role ==	"ASHA WORKER"
replace elected_leader = 	0	if role ==	"Aganwadi Teacher"
replace elected_leader = 	0	if role ==	"COMMUNITY SECRETARY"
replace elected_leader = 	0	if role ==	"Gram Panchayat servant"
replace elected_leader = 	0	if role ==	"PANCHAYAT SECRETARY"
replace elected_leader = 	0	if role ==	"PANCHAYAT SERVENT"
replace elected_leader = 	0	if role ==	"PANCHYAT OFFICE SERVENT"
replace elected_leader = 	0	if role ==	"VILLAGE SECRETARY"
replace elected_leader = 	0	if role ==	"anganwadi worker"
replace elected_leader = 	0	if role ==	"anganwasi worker"
replace elected_leader = 	0	if role ==	"secretary"
replace elected_leader = 	0	if role ==	"society secretary"
replace elected_leader = 	0	if role ==	"CRP"
replace elected_leader = 	0	if role ==	"FES CRP"
replace elected_leader = 	0	if role ==	"VILLAGE FRIEND"
replace elected_leader = 	0	if role ==	"VILLAGE RESOURSE PERSON"
replace elected_leader = 	0	if role ==	"village friend"
replace elected_leader = 	0	if role ==	"HG MEMBER"
replace elected_leader = 	0	if role ==	"SHG CRP"
replace elected_leader = 	0	if role ==	"SHG GROUP SECREATRY"
replace elected_leader = 	0	if role ==	"SHG GROUP SECRETARY"
replace elected_leader = 	0	if role ==	"SHG PRESODENT"
replace elected_leader = 	0	if role ==	"SHG RECORD KEEPER"
replace elected_leader = 	0	if role ==	"SHG SECRETARY"
replace elected_leader = 	0	if role ==	"COMMUNITY MEMBER"
replace elected_leader = 	0	if role ==	"Community Sasatasy"
replace elected_leader = 	0	if role ==	"FES MEMBER"
replace elected_leader = 	0	if role ==	"FES Member"
replace elected_leader = 	0	if role ==	"MEMBER"
replace elected_leader = 	0	if role ==	"Member"
replace elected_leader = 	0	if role ==	"N"
replace elected_leader = 	0	if role ==	"0"
replace elected_leader = 	0	if role ==	"N0"
replace elected_leader = 	0	if role ==	"NO"
replace elected_leader = 	0	if role ==	"No"
replace elected_leader = 	0	if role ==	"PRERAK"
replace elected_leader = 	0	if role ==	"Prerak"
replace elected_leader = 	0	if role ==	"SHG MEMBER"
replace elected_leader = 	0	if role ==	"community member"
replace elected_leader = 	0	if role ==	"member"
replace elected_leader = 	0	if role ==	"member of agriculture"
replace elected_leader = 	0	if role ==	"n"
replace elected_leader = 	1	if role ==	"SECRETARY"
replace elected_leader = 	1	if role ==	"COMMUNITY LEADER"
replace elected_leader = 	1	if role ==	"COMMUNITY PRESIDENT"
replace elected_leader = 	1	if role ==	"COOPERATIVE COMMITTE PRESIDENT"
replace elected_leader = 	1	if role ==	"DEPUTY SARPANCH"
replace elected_leader = 	1	if role ==	"G.P. MEMBER"
replace elected_leader = 	1	if role ==	"Mukhiya"
replace elected_leader = 	1	if role ==	"PANCHAYAT MEMBER"
replace elected_leader = 	1	if role ==	"PANCHYAT MEMBER"
replace elected_leader = 	1	if role ==	"Panchayat Member"
replace elected_leader = 	1	if role ==	"VILLAGE PERSIDENT"
replace elected_leader = 	1	if role ==	"WARD MEMBER"
replace elected_leader = 	1	if role ==	"community leader"
replace elected_leader = 	1	if role ==	"gram panchayat member"
replace elected_leader = 	1	if role ==	"sarpanch"
replace elected_leader = 	1	if role ==	"ward member"
replace elected_leader = 	1	if role ==	"APS Mem"
replace elected_leader = 	1	if role ==	"ASSISTANT SECRETARY OF FOREST BUFFER ZONE"
replace elected_leader = 	1	if role ==	"Commu.mem samiti"
replace elected_leader = 	1	if role ==	"FES COMM.Secra"
replace elected_leader = 	1	if role ==	"FES COMMITTEE"
replace elected_leader = 	1	if role ==	"FES COMMITTEE SECRETARY"
replace elected_leader = 	1	if role ==	"FES Coomm.Pre"
replace elected_leader = 	1	if role ==	"FES committe secretary"
replace elected_leader = 	1	if role ==	"FOREST BUFFER ZONE MEMBER"
replace elected_leader = 	1	if role ==	"FOREST SAMIITTEE PRESIDENT"
replace elected_leader = 	1	if role ==	"FOREST SECURITY MEMBER"
replace elected_leader = 	1	if role ==	"FOREST SECURITY SAMITTEE MEMBER"
replace elected_leader = 	1	if role ==	"Forest Commiittee member"
replace elected_leader = 	1	if role ==	"Forrest Comittee Member"
replace elected_leader = 	1	if role ==	"GRAM MITRA MEMBER"
replace elected_leader = 	1	if role ==	"GRAM PARYAVARAN SAMITTEE SECRETARY"
replace elected_leader = 	1	if role ==	"GRAM PARYVARAN SAMITTEE MEMBER"
replace elected_leader = 	1	if role ==	"Geram Saniti Member"
replace elected_leader = 	1	if role ==	"Gram Paryavaran President"
replace elected_leader = 	1	if role ==	"Gram Paryavaran Secretary"
replace elected_leader = 	1	if role ==	"MEMBER OF GRAM PARYAVARAN SAMITTEE"
replace elected_leader = 	1	if role ==	"PRESIDENT OF COOPERATIVE SAMITTE"
replace elected_leader = 	1	if role ==	"PRESIDENT OF GRAM PARYAVARAN SAMITTE"
replace elected_leader = 	1	if role ==	"PRESIDENT OF GRAM PARYAVARAN SAMITTEE"
replace elected_leader = 	1	if role ==	"PRESIDENT OF LIVELIHOOD GROUP"
replace elected_leader = 	1	if role ==	"PSPS MEMBER"
replace elected_leader = 	1	if role ==	"Paryavaran samiti Secretary"
replace elected_leader = 	1	if role ==	"President"
replace elected_leader = 	1	if role ==	"SAMITTE SECRETARY"
replace elected_leader = 	1	if role ==	"SAMITTEE MEMBER"
replace elected_leader = 	1	if role ==	"SCHOOL MEMBER"
replace elected_leader = 	1	if role ==	"SECRETARY OF GRAM PARYAVARAN SAMITTEE"
replace elected_leader = 	1	if role ==	"SECRETARY OF LIVELIHOOD GROUP"
replace elected_leader = 	1	if role ==	"SECRETARY OF PSPS"
replace elected_leader = 	1	if role ==	"Samiti  Presiedent"
replace elected_leader = 	1	if role ==	"Secretary, Gram panchayat smithi"
replace elected_leader = 	1	if role ==	"Smithi secretary"
replace elected_leader = 	1	if role ==	"VAN SURAKSHA PRESIDENT"
replace elected_leader = 	1	if role ==	"VILLAGE SAMITTEE MEMBER"
replace elected_leader = 	1	if role ==	"Van Suraksha Comittee Member"
replace elected_leader = 	1	if role ==	"Villase Panchayat Management Comittee"
replace elected_leader = 	1	if role ==	"member of PSPS"
replace elected_leader = 	1	if role ==	"member of forest committee"
replace elected_leader = 	1	if role ==	"SHG GROUP PRESIDENT"
replace elected_leader = 	1	if role ==	"SHG GROUP PRESIDNET"
replace elected_leader = 	1	if role ==	"SHG PRESDIENT"
replace elected_leader = 	1	if role ==	"SHG PRESIDENT"
replace elected_leader = 	1	if role ==	"BAJIRANG DAL MEMBER"
replace elected_leader = 	1	if role ==	"NAV YUVAK SAMMITTE MEMBER"
replace elected_leader = 	1	if role ==	"VOLLEYBALL SAMITTEE MEMBER"

******************************************************************
gen leader_type = .
replace leader_type = 1 if elected_leader == 0
replace leader_type = 	2	if role == "SECRETARY"
replace leader_type = 	2	if role == "COMMUNITY LEADER"
replace leader_type = 	2	if role == "COMMUNITY PRESIDENT"
replace leader_type = 	2	if role == "COOPERATIVE COMMITTE PRESIDENT"
replace leader_type = 	2	if role == "DEPUTY SARPANCH"
replace leader_type = 	2	if role == "G.P. MEMBER"
replace leader_type = 	2	if role == "Mukhiya"
replace leader_type = 	2	if role == "PANCHAYAT MEMBER"
replace leader_type = 	2	if role == "PANCHYAT MEMBER"
replace leader_type = 	2	if role == "Panchayat Member"
replace leader_type = 	2	if role == "VILLAGE PERSIDENT"
replace leader_type = 	2	if role == "WARD MEMBER"
replace leader_type = 	2	if role == "community leader"
replace leader_type = 	2	if role == "gram panchayat member"
replace leader_type = 	2	if role == "sarpanch"
replace leader_type = 	2	if role == "ward member"
replace leader_type = 	3	if role == "APS Mem"
replace leader_type = 	3	if role == "ASSISTANT SECRETARY OF FOREST BUFFER ZONE"
replace leader_type = 	3	if role == "Commu.mem samiti"
replace leader_type = 	3	if role == "FES COMM.Secra"
replace leader_type = 	3	if role == "FES COMMITTEE"
replace leader_type = 	3	if role == "FES COMMITTEE SECRETARY"
replace leader_type = 	3	if role == "FES Coomm.Pre"
replace leader_type = 	3	if role == "FES committe secretary"
replace leader_type = 	3	if role == "FOREST BUFFER ZONE MEMBER"
replace leader_type = 	3	if role == "FOREST SAMIITTEE PRESIDENT"
replace leader_type = 	3	if role == "FOREST SECURITY MEMBER"
replace leader_type = 	3	if role == "FOREST SECURITY SAMITTEE MEMBER"
replace leader_type = 	3	if role == "Forest Commiittee member"
replace leader_type = 	3	if role == "Forrest Comittee Member"
replace leader_type = 	3	if role == "GRAM MITRA MEMBER"
replace leader_type = 	3	if role == "GRAM PARYAVARAN SAMITTEE SECRETARY"
replace leader_type = 	3	if role == "GRAM PARYVARAN SAMITTEE MEMBER"
replace leader_type = 	3	if role == "Geram Saniti Member"
replace leader_type = 	3	if role == "Gram Paryavaran President"
replace leader_type = 	3	if role == "Gram Paryavaran Secretary"
replace leader_type = 	3	if role == "MEMBER OF GRAM PARYAVARAN SAMITTEE"
replace leader_type = 	3	if role == "PRESIDENT OF COOPERATIVE SAMITTE"
replace leader_type = 	3	if role == "PRESIDENT OF GRAM PARYAVARAN SAMITTE"
replace leader_type = 	3	if role == "PRESIDENT OF GRAM PARYAVARAN SAMITTEE"
replace leader_type = 	3	if role == "PRESIDENT OF LIVELIHOOD GROUP"
replace leader_type = 	3	if role == "PSPS MEMBER"
replace leader_type = 	3	if role == "Paryavaran samiti Secretary"
replace leader_type = 	3	if role == "President"
replace leader_type = 	3	if role == "SAMITTE SECRETARY"
replace leader_type = 	3	if role == "SAMITTEE MEMBER"
replace leader_type = 	3	if role == "SCHOOL MEMBER"
replace leader_type = 	3	if role == "SECRETARY OF GRAM PARYAVARAN SAMITTEE"
replace leader_type = 	3	if role == "SECRETARY OF LIVELIHOOD GROUP"
replace leader_type = 	3	if role == "SECRETARY OF PSPS"
replace leader_type = 	3	if role == "Samiti  Presiedent"
replace leader_type = 	3	if role == "Secretary, Gram panchayat smithi"
replace leader_type = 	3	if role == "Smithi secretary"
replace leader_type = 	3	if role == "VAN SURAKSHA PRESIDENT"
replace leader_type = 	3	if role == "VILLAGE SAMITTEE MEMBER"
replace leader_type = 	3	if role == "Van Suraksha Comittee Member"
replace leader_type = 	3	if role == "Villase Panchayat Management Comittee"
replace leader_type = 	3	if role == "member of PSPS"
replace leader_type = 	3	if role == "member of forest committee"
replace leader_type = 	4	if role == "SHG GROUP PRESIDENT"
replace leader_type = 	4	if role == "SHG GROUP PRESIDNET"
replace leader_type = 	4	if role == "SHG PRESDIENT"
replace leader_type = 	4	if role == "SHG PRESIDENT"
replace leader_type = 	5	if role == "BAJIRANG DAL MEMBER"
replace leader_type = 	5	if role == "NAV YUVAK SAMMITTE MEMBER"
replace leader_type = 	5	if role == "VOLLEYBALL SAMITTEE MEMBER"
label define leadertype   1 "no leader" 2 "Political office" 3 "CBNRM" 4 "Self-help group" 5 "Cultural group",replace 
label values leader_type leadertype

******************************************************************
* Categorize leader types
gen leader_no =.
replace leader_no = 1 if leader_type ==1
replace leader_no = 0 if leader_type != 1
replace leader_no = . if leader_type == .

gen leader_state =.
replace leader_state = 1 if leader_type ==2
replace leader_state = 0 if leader_type != 2
replace leader_state = . if leader_type == .

gen leader_CR =.
replace leader_CR = 1 if leader_type ==3
replace leader_CR = 0 if leader_type != 3
replace leader_CR = . if leader_type == .

gen leader_SHG =.
replace leader_SHG = 1 if leader_type ==4
replace leader_SHG = 0 if leader_type != 4
replace leader_SHG = . if leader_type == .

gen leader_culture =.
replace leader_culture = 1 if leader_type ==5
replace leader_culture = 0 if leader_type != 5
replace leader_culture = . if leader_type == .

label var leader_no "No leader"
label var leader_state "Leader in state or political position"
label var leader_CR "Leader in common resources"
label var leader_SHG  "Leader in self help group"
label var leader_culture  "Leader in social or cultural groups"

******************************************************************
* Aggregate individual leader variables at village level
*bysort site_ID round: egen vill_elected_leader_sum=total(elected_leader)  if round==1 
bysort site_ID round: egen vill_elected_leader_sum=total(elected_leader) 

label var vill_elected_leader_sum "sum of leaders present during game"

gen leader_present_vill =.
replace leader_present_vill = 1 if vill_elected_leader_sum >= 1
replace leader_present_vill = 0 if vill_elected_leader_sum ==0
label var leader_present_vill "leader was present during game"

/*bysort site_ID round: egen sum_leader_no = sum (leader_no) if round ==1 
bysort site_ID round: egen sum_leader_state = sum (leader_state) if round ==1 
bysort site_ID round: egen sum_leader_CR = sum (leader_CR) if round ==1 
bysort site_ID round: egen sum_leader_SHG = sum (leader_SHG) if round ==1 
bysort site_ID round: egen sum_leader_culturestate = sum (leader_culture) if round ==1 
*/
bysort site_ID round: egen sum_leader_no = sum (leader_no) 
bysort site_ID round: egen sum_leader_state = sum (leader_state) 
bysort site_ID round: egen sum_leader_CR = sum (leader_CR) 
bysort site_ID round: egen sum_leader_SHG = sum (leader_SHG) 
bysort site_ID round: egen sum_leader_culturestate = sum (leader_culture) 

label var sum_leader_no "Sum of no leaders in village"
label var sum_leader_state "Sum of leaders in state or political position in village"
label var sum_leader_CR "Sum of leaders in common resources in village"
label var sum_leader_SHG  "Sum of leaders in self help group in village"
label var sum_leader_culture  "Sum of leaders in social or cultural groupsin village"

gen share_leader_vill =  vill_elected_leader_sum/14
gen share_leader_state_vill =  sum_leader_state/14
gen share_leader_CR_vill =  sum_leader_CR/14
gen share_leader_SHG_vill =  sum_leader_SHG/14
gen share_leader_culture_vill =  sum_leader_culture/14

label var share_leader_vill "Share of no leaders in village"
label var share_leader_state_vill "Share of leaders in state or political position in village"
label var share_leader_CR_vill "Share of leaders in common resources in village"
label var share_leader_SHG_vill  "Share of leaders in self help group in village"
label var share_leader_culture_vill  "Share of leaders in social or cultural groupsin village"

******************************************************************
tab cont_lab
rename cont_lab cont_lab_str
gen cont_lab = .
replace cont_lab = 0 if cont_lab_str== "0"
replace cont_lab = 1 if cont_lab_str== "1"
replace cont_lab = 1 if cont_lab_str== "1 day"
replace cont_lab = 1 if cont_lab_str== "15"
replace cont_lab = 1 if cont_lab_str== "2"
replace cont_lab = 1 if cont_lab_str== "2 days"
replace cont_lab = 1 if cont_lab_str== "20"
replace cont_lab = 1 if cont_lab_str== "3"
replace cont_lab = 1 if cont_lab_str== "3 days"
replace cont_lab = 1 if cont_lab_str== "4 days"
replace cont_lab = 1 if cont_lab_str== "4days"
replace cont_lab = 1 if cont_lab_str== "6 days"
replace cont_lab = 1 if cont_lab_str== "7 days"
replace cont_lab = 0 if cont_lab_str== "N"
replace cont_lab = 0 if cont_lab_str== "NO"
replace cont_lab = 0 if cont_lab_str== "N0"
replace cont_lab = 0 if cont_lab_str== "No"
replace cont_lab = 0 if cont_lab_str== "O"
replace cont_lab = 1 if cont_lab_str== "Y"
replace cont_lab = 1 if cont_lab_str== "YES"
replace cont_lab = 1 if cont_lab_str== "YES, 1 DAY"
replace cont_lab = 1 if cont_lab_str== "YES, 15 DAYS"
replace cont_lab = 1 if cont_lab_str== "YES, 1DAY"
replace cont_lab = 1 if cont_lab_str== "YES, 2DAYS"
replace cont_lab = 1 if cont_lab_str== "YES, 3 DAYS"
replace cont_lab = 1 if cont_lab_str== "YES, 30 DAYS"
replace cont_lab = 0 if cont_lab_str== "n"
replace cont_lab = 1 if cont_lab_str== "y"
replace cont_lab = . if cont_lab_str== ""
label define contribute_l 1 "Contribution" 0 "No contribution", replace
label values cont_lab contribute_l
label var cont_lab "Labor contribution to maintain dam"
tab cont_lab 

******************************************************************
tab cont_money
rename cont_money cont_money_str
gen cont_money = .
replace cont_money = 0 if cont_money_str== "N"
replace cont_money = 0 if cont_money_str== "No"
replace cont_money = 0 if cont_money_str== "NO"
replace cont_money = 0 if cont_money_str== "n"
replace cont_money = 0 if cont_money_str== "0"
replace cont_money = 1 if cont_money_str== "100"
replace cont_money = 1 if cont_money_str== "16"
replace cont_money = 1 if cont_money_str== "1000"
replace cont_money = 1 if cont_money_str== "200"
replace cont_money = 1 if cont_money_str== "300"
replace cont_money = 1 if cont_money_str== "318"
replace cont_money = 1 if cont_money_str== "500"
replace cont_money = 1 if cont_money_str== "600"
replace cont_money = 1 if cont_money_str== "636"
replace cont_money = 1 if cont_money_str== "700"
replace cont_money = 1 if cont_money_str== "795"
replace cont_money = 1 if cont_money_str== "800"
replace cont_money = 1 if cont_money_str== "8000"
replace cont_money = . if cont_money_str== "."
label define cont_money_l 1 "Contribution" 0 "No contribution", replace
label values cont_money contribute_l
label var cont_money "Money contribution to maintain dam"
tab cont_money

******************************************************************
tab reci_wat
rename reci_wat reci_wat_str
gen reci_wat = .
replace reci_wat = 0 if reci_wat_str== "0"
replace reci_wat = 0 if reci_wat_str== "O"
replace reci_wat = 0 if reci_wat_str== "N"
replace reci_wat = 0 if reci_wat_str== "N0"
replace reci_wat = 0 if reci_wat_str== "BO"
replace reci_wat = 0 if reci_wat_str== "NO"
replace reci_wat = 0 if reci_wat_str== "No"
replace reci_wat = 0 if reci_wat_str== "n"
replace reci_wat = 1 if reci_wat_str== "Y"
replace reci_wat = 1 if reci_wat_str== "YES"
replace reci_wat = 1 if reci_wat_str== "Yes"
replace reci_wat = 1 if reci_wat_str== "yes"
replace reci_wat = 1 if reci_wat_str== "y"
replace reci_wat = 1 if reci_wat_str== "y (1)"
replace reci_wat = 1 if reci_wat_str== "1"
replace reci_wat = . if reci_wat_str== ""
replace reci_wat = . if reci_wat_str== "."
label define reci_wat_l 1 "Received water" 0 "Not received water", replace
label values reci_wat reci_wat_l
label var reci_wat "Received water from village dam"
tab reci_wat

******************************************************************
tab hyp_crop
rename hyp_crop hyp_crop_str
gen hyp_crop = .
replace hyp_crop = 1 if hyp_crop_str == "g"
replace hyp_crop = 1 if hyp_crop_str == "G"
replace hyp_crop = 0 if hyp_crop_str == "W"
replace hyp_crop = 0 if hyp_crop_str == "w"
replace hyp_crop = . if hyp_crop_str == "0"
replace hyp_crop = . if hyp_crop_str == ""
label define hyp_crop_l 1 "Gram" 0 "Wheat" 2 "N/A"
label values hyp_crop hyp_crop_l
label var hyp_crop "Hypothetical crop choice during test round"
tab hyp_crop

******************************************************************
* Make crop_choice a numeric value
******************************************************************
rename crop_choice crop_choice_str
gen crop_choice = .
replace crop_choice = 1 if crop_choice_str =="g"
replace crop_choice = 1 if crop_choice_str =="G"
replace crop_choice = 0 if crop_choice_str =="w"
replace crop_choice = 0 if crop_choice_str =="W"
label define crop_choice_1 1 "Sustainable Crop" 0 "Unsustainable Crop"
label values crop_choice crop_choice_1
label var crop_choice "Crop choice [1=gram;0=wheat]
tab crop_choice

******************************************************************
* Make dist_field a numeric value
******************************************************************
tab dist_field
rename dist_field dist_field_old
generate dist_field = .
replace dist_field = 0 	if dist_field_old == "n"
replace dist_field = 0 	if dist_field_old == "0"
replace dist_field = 1 	if dist_field_old == "1"
replace dist_field = 10 if dist_field_old == "10"
replace dist_field = 11 if dist_field_old == "11"
replace dist_field = 12 if dist_field_old == "12"
replace dist_field = 13 if dist_field_old == "13"
replace dist_field = 15 if dist_field_old == "15"
replace dist_field = 16 if dist_field_old == "16"
replace dist_field = 17 if dist_field_old == "17"
replace dist_field = 18 if dist_field_old == "18"
replace dist_field = 2 	if dist_field_old == "2"
replace dist_field = 20 if dist_field_old == "20"
replace dist_field = 25 if dist_field_old == "25"
replace dist_field = 27 if dist_field_old == "27"
replace dist_field = 3 	if dist_field_old == "3"
replace dist_field = 35 if dist_field_old == "35"
replace dist_field = 37 if dist_field_old == "37"
replace dist_field = 4 	if dist_field_old == "4"
replace dist_field = 5 	if dist_field_old == "5"
replace dist_field = 50 if dist_field_old == "50"
replace dist_field = 6 	if dist_field_old == "6"
replace dist_field = 7 	if dist_field_old == "7"
replace dist_field = 8 	if dist_field_old == "8"
replace dist_field = 9 	if dist_field_old == "9"
replace dist_field = 0 	if dist_field_old == "connected"
replace dist_field = 0 	if dist_field_old == "n"
label var dist_field "Distance between village dam and field"

******************************************************************
*CREATE VARIABLE TO DISTINGUISH GROUP 1 AND 2 IN BOTH BASIC AND COMMUNICATION ROUNDS
******************************************************************
gen group_no_basic = .
replace group_no_basic = 1 if group_b == 1
replace group_no_basic = 2 if group_b == 2
label define group_no_basic_1 1 "Basic Group 1" 2 "Basic Group 2"
label values group_no_basic group_no_basic_1
label var group_no_basic "Participants group in baseline rounds"

gen group_no_com = .
replace group_no_com = 3 if group_c == 1
replace group_no_com = 4 if group_c == 2
label define group_no_com_1 3 "Communication Group 1" 4 "Communication Group 2"
label values group_no_com group_no_com_1
label var group_no_com "Participants group in communication treatment"
 
******************************************************************
*CREATE GROUP_ID FOR BASIC ROUNDS
******************************************************************
generate group_ID_basic = .
replace group_ID_basic = 1000 + group_no_basic if site == "Atarchuha"
 replace group_ID_basic = 1100 + group_no_basic if site == "Atariya"
 replace group_ID_basic = 1200 + group_no_basic if site == "Baghraudi_FV"
 replace group_ID_basic = 1300 + group_no_basic if site == "Banijagoan"
 replace group_ID_basic = 1400 + group_no_basic if site == "Bariha"
 replace group_ID_basic = 1500 + group_no_basic if site == "Batwar"
 replace group_ID_basic = 1600 + group_no_basic if site == "Bhapsa"
 replace group_ID_basic = 1700 + group_no_basic if site == "Budhanwara"
 replace group_ID_basic = 1800 + group_no_basic if site == "Chandiya_Ryt"
 replace group_ID_basic = 1900 + group_no_basic if site == "Changariya"
 replace group_ID_basic = 2000 + group_no_basic if site == "Chatuwakhar"
 replace group_ID_basic = 2100 + group_no_basic if site == "Deori"
 replace group_ID_basic = 2200 + group_no_basic if site == "Dhamangaon"
 replace group_ID_basic = 2300 + group_no_basic if site == "Dharampuri_Mal"
 replace group_ID_basic = 2400 + group_no_basic if site == "Dilwara"
 replace group_ID_basic = 2500 + group_no_basic if site == "Dudka"
 replace group_ID_basic = 2600 + group_no_basic if site == "Dungaria"
 replace group_ID_basic = 2700 + group_no_basic if site == "Dungariya_Ramnagar"
 replace group_ID_basic = 2800 + group_no_basic if site == "Dungravt"
 replace group_ID_basic = 2900 + group_no_basic if site == "Fonk"
 replace group_ID_basic = 3000 + group_no_basic if site == "Ghont"
 replace group_ID_basic = 3100 + group_no_basic if site == "Gubri"
 replace group_ID_basic = 3200 + group_no_basic if site == "Gunegaon"
 replace group_ID_basic = 3300 + group_no_basic if site == "Gunehara"
 replace group_ID_basic = 3400 + group_no_basic if site == "Jhagul"
 replace group_ID_basic = 3500 + group_no_basic if site == "Jhulup"
 replace group_ID_basic = 3600 + group_no_basic if site == "Kanhari_Kalan"
 replace group_ID_basic = 3700 + group_no_basic if site == "Kanhari_Khurd"
 replace group_ID_basic = 3800 + group_no_basic if site == "Kanskheda"
 replace group_ID_basic = 3900 + group_no_basic if site == "Kata_Mal"
 replace group_ID_basic = 4000 + group_no_basic if site == "Katanga_Ryt"
 replace group_ID_basic = 4100 + group_no_basic if site == "Khalaudi_FV"
 replace group_ID_basic = 4200 + group_no_basic if site == "Khamrauti"
 replace group_ID_basic = 4300 + group_no_basic if site == "Kharpariya"
 replace group_ID_basic = 4400 + group_no_basic if site == "Khatiya_Narangi"
 replace group_ID_basic = 4500 + group_no_basic if site == "Khirahani"
 replace group_ID_basic = 4600 + group_no_basic if site == "Khuksar_RF"
 replace group_ID_basic = 4700 + group_no_basic if site == "Kosampani"
 replace group_ID_basic = 4800 + group_no_basic if site == "Magdha"
 replace group_ID_basic = 4900 + group_no_basic if site == "Manegaon"
 replace group_ID_basic = 5000 + group_no_basic if site == "Mangaveli_Mal"
 replace group_ID_basic = 5100 + group_no_basic if site == "Mangaveli_Ryt"
 replace group_ID_basic = 5200 + group_no_basic if site == "Manikpur_Mal"
 replace group_ID_basic = 5300 + group_no_basic if site == "Manoharpur"
 replace group_ID_basic = 5400 + group_no_basic if site == "Medhatal"
 replace group_ID_basic = 5500 + group_no_basic if site == "Mubala_Mal"
 replace group_ID_basic = 5600 + group_no_basic if site == "Mulwalasani_Ryt"
 replace group_ID_basic = 5700 + group_no_basic if site == "Nakawal"
 replace group_ID_basic = 5800 + group_no_basic if site == "Padariya"
 replace group_ID_basic = 5900 + group_no_basic if site == "Rata"
 replace group_ID_basic = 6000 + group_no_basic if site == "Saradoli_Mal"
 replace group_ID_basic = 6100 + group_no_basic if site == "Sarasdoli"
 replace group_ID_basic = 6200 + group_no_basic if site == "Sarhi"
 replace group_ID_basic = 6300 + group_no_basic if site == "Sautia"
 replace group_ID_basic = 6400 + group_no_basic if site == "Shahapur"
 replace group_ID_basic = 6500 + group_no_basic if site == "Samaiya_Bhagpur_FV"
 replace group_ID_basic = 6600 + group_no_basic if site == "Taktuwa"
 replace group_ID_basic = 6700 + group_no_basic if site == "Thonda"
 replace group_ID_basic = 6800 + group_no_basic if site == "Tilari"
 replace group_ID_basic = 6900 + group_no_basic if site == "Umariya_FV"
 
******************************************************************
*CREATE GROUP_ID FOR COMMUNICATION ROUNDS
******************************************************************
generate group_ID_com = .
 replace group_ID_com = 1000 + group_no_com if site == "Atarchuha"
 replace group_ID_com = 1100 + group_no_com if site == "Atariya"
 replace group_ID_com = 1200 + group_no_com if site == "Baghraudi_FV"
 replace group_ID_com = 1300 + group_no_com if site == "Banijagoan"
 replace group_ID_com = 1400 + group_no_com if site == "Bariha"
 replace group_ID_com = 1500 + group_no_com if site == "Batwar"
 replace group_ID_com = 1600 + group_no_com if site == "Bhapsa"
 replace group_ID_com = 1700 + group_no_com if site == "Budhanwara"
 replace group_ID_com = 1800 + group_no_com if site == "Chandiya_Ryt"
 replace group_ID_com = 1900 + group_no_com if site == "Changariya"
 replace group_ID_com = 2000 + group_no_com if site == "Chatuwakhar"
 replace group_ID_com = 2100 + group_no_com if site == "Deori"
 replace group_ID_com = 2200 + group_no_com if site == "Dhamangaon"
 replace group_ID_com = 2300 + group_no_com if site == "Dharampuri_Mal"
 replace group_ID_com = 2400 + group_no_com if site == "Dilwara"
 replace group_ID_com = 2500 + group_no_com if site == "Dudka"
 replace group_ID_com = 2600 + group_no_com if site == "Dungaria"
 replace group_ID_com = 2700 + group_no_com if site == "Dungariya_Ramnagar"
 replace group_ID_com = 2800 + group_no_com if site == "Dungravt"
 replace group_ID_com = 2900 + group_no_com if site == "Fonk"
 replace group_ID_com = 3000 + group_no_com if site == "Ghont"
 replace group_ID_com = 3100 + group_no_com if site == "Gubri"
 replace group_ID_com = 3200 + group_no_com if site == "Gunegaon"
 replace group_ID_com = 3300 + group_no_com if site == "Gunehara"
 replace group_ID_com = 3400 + group_no_com if site == "Jhagul"
 replace group_ID_com = 3500 + group_no_com if site == "Jhulup"
 replace group_ID_com = 3600 + group_no_com if site == "Kanhari_Kalan"
 replace group_ID_com = 3700 + group_no_com if site == "Kanhari_Khurd"
 replace group_ID_com = 3800 + group_no_com if site == "Kanskheda"
 replace group_ID_com = 3900 + group_no_com if site == "Kata_Mal"
 replace group_ID_com = 4000 + group_no_com if site == "Katanga_Ryt"
 replace group_ID_com = 4100 + group_no_com if site == "Khalaudi_FV"
 replace group_ID_com = 4200 + group_no_com if site == "Khamrauti"
 replace group_ID_com = 4300 + group_no_com if site == "Kharpariya"
 replace group_ID_com = 4400 + group_no_com if site == "Khatiya_Narangi"
 replace group_ID_com = 4500 + group_no_com if site == "Khirahani"
 replace group_ID_com = 4600 + group_no_com if site == "Khuksar_RF"
 replace group_ID_com = 4700 + group_no_com if site == "Kosampani"
 replace group_ID_com = 4800 + group_no_com if site == "Magdha"
 replace group_ID_com = 4900 + group_no_com if site == "Manegaon"
 replace group_ID_com = 5000 + group_no_com if site == "Mangaveli_Mal"
 replace group_ID_com = 5100 + group_no_com if site == "Mangaveli_Ryt"
 replace group_ID_com = 5200 + group_no_com if site == "Manikpur_Mal"
 replace group_ID_com = 5300 + group_no_com if site == "Manoharpur"
 replace group_ID_com = 5400 + group_no_com if site == "Medhatal"
 replace group_ID_com = 5500 + group_no_com if site == "Mubala_Mal"
 replace group_ID_com = 5600 + group_no_com if site == "Mulwalasani_Ryt"
 replace group_ID_com = 5700 + group_no_com if site == "Nakawal"
 replace group_ID_com = 5800 + group_no_com if site == "Padariya"
 replace group_ID_com = 5900 + group_no_com if site == "Rata"
 replace group_ID_com = 6000 + group_no_com if site == "Saradoli_Mal"
 replace group_ID_com = 6100 + group_no_com if site == "Sarasdoli"
 replace group_ID_com = 6200 + group_no_com if site == "Sarhi"
 replace group_ID_com = 6300 + group_no_com if site == "Sautia"
 replace group_ID_com = 6400 + group_no_com if site == "Shahapur"
 replace group_ID_com = 6500 + group_no_com if site == "Samaiya_Bhagpur_FV"
 replace group_ID_com = 6600 + group_no_com if site == "Taktuwa"
 replace group_ID_com = 6700 + group_no_com if site == "Thonda"
 replace group_ID_com = 6800 + group_no_com if site == "Tilari"
 replace group_ID_com = 6900 + group_no_com if site == "Umariya_FV"

 ******************************************************************
*GENERATE SUM OF TIMES A PLAYER WAS ASKED FOR HELP
******************************************************************
gen total_help = .
foreach num of numlist 1/60 {  
			foreach p of numlist 1/14 {
				summarize help_p`p' if site_ID == `num' & round == 1
				scalar m1 = r(sum)
				replace total_help = m1 if site_ID == `num' &  play_no == `p'
			}
		}
label var total_help "Help Index"

******************************************************************
* TREATMENT
******************************************************************
tab treat
gen game_phase = .
replace game_phase =0 if treat =="basic"
replace game_phase = 1 if treat =="com"

label define treatm 0	"Phase I" 1	"Phase II" , replace
label values game_phase treatm
label var game_phase "Game phase"
drop treat

******************************************************************
*POSITIONS
******************************************************************
gen position_game = pos_b if round < 6
replace position_game = pos_c if round >5
label var position_game "Position of Participants"

**********************************************
*GENERATE DISCLOSURE VARIABLE
**********************************************
gen disclosure =.
replace disclosure = 0 if round < 6
replace disclosure = 1 if round >= 6 
label define disclosure_1 1 "Disclosure" 0 "No disclosure"
label values disclosure disclosure_1 

**********************************************
*GENERATE COMMUNICATION VARIABLE
**********************************************
gen communication =.
replace communication = 0 if round <7
replace communication = 1 if round >=7
label define communication_1 1 "Communication allowed" 0 "Communication not allowed"
label values communication communication_1 
label var communication "Communication allowed (y/n)"

******************************************************************
*GENERATE DUMMY VARIABLE FOR COME BACK
******************************************************************
tab come_back
gen come_back_dummy =.
replace come_back_dummy = 0 if come_back ==0
replace come_back_dummy = 1 if come_back >0
label define come_back_dummy_l 0 "Do not come back" 1 "Come back", replace
label values come_back_dummy come_back_dummy_l
label var come_back_dummy "Indicates whether community wants us to come back to perform another experiment"
replace come_back_dummy = . if Sample_variable==2

******************************************************************
*GENERATE VARIABLE WHETHER PLAYER RECEIVED WATER IN PREVIOUS GAME ROUND
******************************************************************
gen reci_wat_game =.
replace reci_wat_game = 1 if round_earning >= 13000
replace reci_wat_game = 0 if round_earning < 13000
label define reci_wat_game_l 1 "Received water" 0 "Not received water", replace
label values reci_wat_game reci_wat_l_game
label var reci_wat_game "Player received water in round"

sort playerid round
xtset playerid round
gen L1_reci_wat_game = .
replace L1_reci_wat_game = L1.reci_wat_game
label var L1_reci_wat_game "Individual received water in last round"

******************************************************************
*GENERATE TOTAL INTERACTIONS OF INDIVIDUALS
******************************************************************
replace propose_rule 	= 0 if propose_rule		==.
replace agree_rule 		= 0 if agree_rule		==.
replace reject_rule 	= 0 if reject_rule		==.
replace praises 		= 0 if praises			==.
replace argue 			= 0 if argue			==.
replace complains 		= 0 if complains		==.
replace propose_punish 	= 0 if propose_punish	==.
replace propose_reward 	= 0 if propose_reward	==.
replace unconected 		= 0 if unconected		==.
rename unconected unconnected

label var propose_rule "Number of times player proposed rule during communication slot"
label var agree_rule "Number of times player proposed rule during communication slot"
label var reject_rule "Number of times player rejected a rule during communication slot"
label var praises "Number of times player praised during communication slot"
label var argue "Number of times player argued during communication slot"
label var complains "Number of times player complained during communication slot"
label var propose_punish "Number of times player proposed punishment during communication slot"
label var propose_reward "Number of times player proposed a reward during communication slot"
label var unconnected "Number of times player made an statement unconntected to game during communication slot"

sort playerid round
xtset playerid round
gen L1_propose_rule = L1.propose_rule
gen L1_agree_rule = L1.agree_rule
gen L1_reject_rule = L1.reject_rule
gen L1_praises = L1.praises
gen L1_argue = L1.argue
gen L1_complains = L1.complains
gen L1_propose_punish = L1.propose_punish 
gen L1_propose_reward = L1.propose_reward
gen L1_unconnected = L1.unconnected
label var L1_propose_rule "Player proposed rule"
label var L1_agree_rule "Player agreed to rule"
label var L1_reject_rule "Player rejected rule"
label var L1_argue "Player argued"
label var L1_praises "Player praised"
label var L1_propose_punish "Player proposed punishment"
label var L1_propose_reward "Player proposed reward"

gen total_com = propose_rule + agree_rule + reject_rule + praises + argue + complains + propose_punish + propose_reward + unconnected
label var total_com "Total interactions of individual in communication slot in round"

****************************************************************
****************************************************************
* Generate Variables to break down communication behavior
****************************************************************
****************************************************************
rename site_ID site_ID_str
destring site_ID_str, generate(site_ID) float
rename site_ID_str site_ID

gen propose_rule_others =.
foreach num of numlist	2/60	{
	foreach r of numlist	6/10	{
		foreach g of numlist	1/7		{
			foreach p of numlist	1/2		{
				summarize propose_rule if site_ID == `num' & round == `r' & pos_c != `g' & group_c == `p'
				scalar m1 = r(sum)
				replace propose_rule_others = m1 if site_ID == `num' & round == `r' & pos_c != `g' & group_c == `p'
							}		
						}		
					}		
				}
				
foreach num of numlist	1/1	{
	foreach r of numlist	6/7	{
		foreach g of numlist	1/7		{
			foreach p of numlist	1/2		{
				summarize propose_rule if site_ID == `num' & round == `r' & pos_c != `g' & group_c == `p'
				scalar m1 = r(sum)
				replace propose_rule_others = m1 if site_ID == `num' & round == `r' & pos_c != `g' & group_c == `p'
							}		
						}		
					}		
				}
label var propose_rule_others "Number of times group members -i proposed rule"

gen agree_rule_others =.
foreach num of numlist	2/60	{
	foreach r of numlist	6/10	{
		foreach g of numlist	1/7		{
			foreach p of numlist	1/2		{
				summarize agree_rule if site_ID == `num' & round == `r' & pos_c != `g' & group_c == `p'
				scalar m1 = r(sum)
				replace agree_rule_others = m1 if site_ID == `num' & round == `r' & pos_c != `g' & group_c == `p'
							}		
						}		
					}		
				}
foreach num of numlist	1/1	{
	foreach r of numlist	6/7	{
		foreach g of numlist	1/7		{
			foreach p of numlist	1/2		{
				summarize agree_rule if site_ID == `num' & round == `r' & pos_c != `g' & group_c == `p'
				scalar m1 = r(sum)
				replace agree_rule_others = m1 if site_ID == `num' & round == `r' & pos_c != `g' & group_c == `p'
							}		
						}		
					}		
				}
label var agree_rule_others "Number of times group members -i agreed to rule"

gen reject_rule_others =.
foreach num of numlist	2/60	{
	foreach r of numlist	6/10	{
		foreach g of numlist	1/7		{
			foreach p of numlist	1/2		{
				summarize reject_rule if site_ID == `num' & round == `r' & pos_c != `g' & group_c == `p'
				scalar m1 = r(sum)
				replace reject_rule_others = m1 if site_ID == `num' & round == `r' & pos_c != `g' & group_c == `p'
							}		
						}		
					}		
				}
				
foreach num of numlist	1/1	{
	foreach r of numlist	6/7	{
		foreach g of numlist	1/7		{
			foreach p of numlist	1/2		{
				summarize reject_rule if site_ID == `num' & round == `r' & pos_c != `g' & group_c == `p'
				scalar m1 = r(sum)
				replace reject_rule_others = m1 if site_ID == `num' & round == `r' & pos_c != `g' & group_c == `p'
							}		
						}		
					}		
				}
label var reject_rule_others "Number of times group members -i rejected rule"

gen propose_punish_others =.
foreach num of numlist	2/60	{
	foreach r of numlist	6/10	{
		foreach g of numlist	1/7		{
			foreach p of numlist	1/2		{
				summarize propose_punish if site_ID == `num' & round == `r' & pos_c != `g' & group_c == `p'
				scalar m1 = r(sum)
				replace propose_punish_others = m1 if site_ID == `num' & round == `r' & pos_c != `g' & group_c == `p'
							}		
						}		
					}		
				}
	foreach num of numlist	1/1	{
	foreach r of numlist	6/7	{
		foreach g of numlist	1/7		{
			foreach p of numlist	1/2		{
				summarize propose_punish if site_ID == `num' & round == `r' & pos_c != `g' & group_c == `p'
				scalar m1 = r(sum)
				replace propose_punish_others = m1 if site_ID == `num' & round == `r' & pos_c != `g' & group_c == `p'
							}		
						}		
					}		
				}
label var propose_punish_others "Number of times group members -i rejectd rule"

gen propose_reward_others =.
foreach num of numlist	2/60	{
	foreach r of numlist	6/10	{
		foreach g of numlist	1/7		{
			foreach p of numlist	1/2		{
				summarize propose_reward if site_ID == `num' & round == `r' & pos_c != `g' & group_c == `p'
				scalar m1 = r(sum)
				replace propose_reward_others = m1 if site_ID == `num' & round == `r' & pos_c != `g' & group_c == `p'
							}		
						}		
					}		
				}
foreach num of numlist	1/1	{
	foreach r of numlist	6/7	{
		foreach g of numlist	1/7		{
			foreach p of numlist	1/2		{
				summarize propose_reward if site_ID == `num' & round == `r' & pos_c != `g' & group_c == `p'
				scalar m1 = r(sum)
				replace propose_reward_others = m1 if site_ID == `num' & round == `r' & pos_c != `g' & group_c == `p'
							}		
						}		
					}		
				}
label var propose_reward_others "Number of times group members -i rejectd rule"

gen argue_others =.
foreach num of numlist	2/60	{
	foreach r of numlist	6/10	{
		foreach g of numlist	1/7		{
			foreach p of numlist	1/2		{
				summarize argue if site_ID == `num' & round == `r' & pos_c != `g' & group_c == `p'
				scalar m1 = r(sum)
				replace argue_others = m1 if site_ID == `num' & round == `r' & pos_c != `g' & group_c == `p'
							}		
						}		
					}		
				}
foreach num of numlist	1/1	{
	foreach r of numlist	6/7	{
		foreach g of numlist	1/7		{
			foreach p of numlist	1/2		{
				summarize argue if site_ID == `num' & round == `r' & pos_c != `g' & group_c == `p'
				scalar m1 = r(sum)
				replace argue_others = m1 if site_ID == `num' & round == `r' & pos_c != `g' & group_c == `p'
							}		
						}		
					}		
				}
label var argue_others "Number of times group members -i argued"

gen praises_others =.
foreach num of numlist	2/60	{
	foreach r of numlist	6/10	{
		foreach g of numlist	1/7		{
			foreach p of numlist	1/2		{
				summarize praises if site_ID == `num' & round == `r' & pos_c != `g' & group_c == `p'
				scalar m1 = r(sum)
				replace praises_others = m1 if site_ID == `num' & round == `r' & pos_c != `g' & group_c == `p'
							}		
						}		
					}		
				}
foreach num of numlist	1/1	{
	foreach r of numlist	6/7	{
		foreach g of numlist	1/7		{
			foreach p of numlist	1/2		{
				summarize praises if site_ID == `num' & round == `r' & pos_c != `g' & group_c == `p'
				scalar m1 = r(sum)
				replace praises_others = m1 if site_ID == `num' & round == `r' & pos_c != `g' & group_c == `p'
							}		
						}		
					}		
				}
label var praises_others "Number of times group members -i praises"

gen L1_propose_reward_others = L1.propose_reward_others
gen L1_reject_rule_others = L1.reject_rule_others
gen L1_agree_rule_others = L1.agree_rule_others
gen L1_propose_rule_others = L1.propose_rule_others
gen L1_propose_punish_others = L1.propose_punish_others
gen L1_argue_others = L1.argue_others
gen L1_praises_others = L1.praises_others

label var L1_propose_rule_others "Other players proposed rule"
label var L1_agree_rule_others "Other players agreed to rule"
label var L1_reject_rule_others "Other players rejected rule"
label var L1_argue_others "Other players argued"
label var L1_praises_others "Other players praised"
label var L1_propose_punish_others "Other players proposed punishment"
label var L1_propose_reward_others "Other players proposed reward"

****************************************************************
* INVESTMENT VARIABLES
****************************************************************
*Average individual investment in previous round
gen L1_investment =.
replace L1_investment = L1.investment
label var L1_investment "Individual investment in round r-1"

******************************************************************
*Create new variable to capture investments of all w/o i
******************************************************************
gen aver_inv_other = .
* Baseline
foreach num of numlist 1/60 {  
	foreach r of numlist 1/5 {
		foreach g of numlist 1, 2 {
			foreach p of numlist 1/7 {
				summarize investment if site_ID == `num' & round == `r' & group_no_basic == `g' & pos_b != `p'
				scalar m1 = r(mean)
				replace aver_inv_other = m1 if site_ID == `num' & round == `r' & group_no_basic == `g' & pos_b != `p'
							}		
						}		
					}		
				}
*Communication
foreach num of numlist 2/60 {  
	foreach r of numlist 6/10 {
		foreach g of numlist 3, 4 {
			foreach p of numlist 1/7 {
				summarize investment if site_ID == `num' & round == `r' & group_no_com == `g' & pos_c != `p'
				scalar m1 = r(mean)
				replace aver_inv_other = m1 if site_ID == `num' & round == `r' & group_no_com == `g' & pos_c != `p'
							}		
						}		
					}		
				}
*Deori
foreach num of numlist 1/1 {  
	foreach r of numlist 6/7 {
		foreach g of numlist 3, 4 {
			foreach p of numlist 1/7 {
				summarize investment if site_ID == `num' & round == `r' & group_no_com == `g' & pos_c != `p'
				scalar m1 = r(mean)
				replace aver_inv_other = m1 if site_ID == `num' & round == `r' & group_no_com == `g' & pos_c != `p'
							}		
						}		
					}		
				}
				
tab aver_inv_other
xtset playerid round
label var aver_inv_other "Average investment of players except i in round"

*Average investment of others in previous round
gen L1_aver_inv_other = .
replace L1_aver_inv_other = L1.aver_inv_other
label var L1_aver_inv_other "Av. investment of others r-1"

******************************************************************
* CALCULATING GROUP AVERAGE INVESTMENT
******************************************************************
gen group_inv = .
*Baseline
foreach num of numlist 1/60 { 
 foreach g of numlist 1, 2 {
	foreach r of numlist 1/5 {
			display as text "#########################################"
			display as text "round `r' site_ID `num' group_no_basic `g' "
			summarize investment if site_ID == `num' & round == `r' & group_no_basic == `g' 
			scalar m1 = r(sum)
			replace group_inv = m1 if site_ID == `num' & round == `r' & group_no_basic == `g' 
							}		
						}		
					}		

*Communication
foreach num of numlist 2/60 { 
 foreach g of numlist 3, 4 {
	foreach r of numlist 6/10 {
			display as text "#########################################"
			display as text "round `r' site `num' group_no_com `g' "
			summarize investment if site_ID == `num' & round == `r' & group_no_com == `g' 
			scalar m1 = r(sum)
			replace group_inv = m1 if site_ID == `num' & round == `r' & group_no_com == `g' 
							}		
						}		
					}		
*Deori
foreach num of numlist 1/1 { 
 foreach g of numlist 1, 2 {
	foreach r of numlist 6/7 {
			display as text "#########################################"
			display as text "round `r' site `num' group_no_com `g' "
			summarize investment if site_ID == `num' & round == `r' & group_no_com == `g' 
			scalar m1 = r(sum)
			replace group_inv = m1 if site_ID == `num' & round == `r' & group_no_com == `g' 
							}		
						}		
					}		
label var group_inv "Group's average investment in round i"

*Group Investment in previous round
sort playerid round
gen L1_group_inv = .
replace L1_group_inv = L1.group_inv 
label var L1_group_inv "Group investment in round r-1"

**********************************************
*Other Group Investment Variable
**********************************************
gen other_group_inv = .
label var other_group_inv "Group investment of other group"
destring site_ID, replace

*Calculate group average investments per COMMUNICATION round (w/o Deori)
foreach num of numlist 2/60 { 
 	foreach r of numlist 6/10 {
			display as text "#########################################"
			display as text "round `r' site `num'  "
			summarize investment if site_ID == `num' & round == `r' & group_c == 1 
			scalar m1 = r(sum)
			replace other_group_inv = m1 if site_ID == `num' & round == `r' & group_c == 2 			
			}	
			}
foreach num of numlist 2/60 { 
 	foreach r of numlist 6/10 {
			display as text "#########################################"
			display as text "round `r' site `num'  "
			summarize investment if site_ID == `num' & round == `r' & group_c == 2 
			scalar m1 = r(sum)
			replace other_group_inv = m1 if site_ID == `num' & round == `r' & group_c == 1 			
			}	
			}
*Calculate group average investments per baseline round (w Deori)
foreach num of numlist 1/60 { 
 	foreach r of numlist 1/5 {
			display as text "#########################################"
			display as text "round `r' site `num'  "
			summarize investment if site_ID == `num' & round == `r' & group_b == 1 
			scalar m1 = r(sum)
			replace other_group_inv = m1 if site_ID == `num' & round == `r' & group_b == 2 			
			}	
			}
foreach num of numlist 1/60 { 
 	foreach r of numlist 1/5 {
			display as text "#########################################"
			display as text "round `r' site `num'  "
			summarize investment if site_ID == `num' & round == `r' & group_b == 2 
			scalar m1 = r(sum)
			replace other_group_inv = m1 if site_ID == `num' & round == `r' & group_b == 1 			
			}	
			}
*calculate group average investments for Deori round 6&7
foreach num of numlist 1/1 { 
 	foreach r of numlist 6/7 {
			display as text "#########################################"
			display as text "round `r' site `num'  "
			summarize investment if site_ID == `num' & round == `r' & group_c == 2 
			scalar m1 = r(sum)
			replace other_group_inv = m1 if site_ID == `num' & round == `r' & group_c == 1 			
			}	
			}
foreach num of numlist 1/1 { 
 	foreach r of numlist 6/7 {
			display as text "#########################################"
			display as text "round `r' site `num'  "
			summarize investment if site_ID == `num' & round == `r' & group_c == 1 
			scalar m1 = r(sum)
			replace other_group_inv = m1 if site_ID == `num' & round == `r' & group_c == 2 
			}	
			}
***
gen L1_other_group_inv = .
replace L1_other_group_inv = L1.other_group_inv 
label var L1_other_group_inv "Group investment of other group in previous round"

****************************************************************
* Group Earnning Variables
****************************************************************
gen group_earning=.
label var group_earning "Earning of group in round"
*Baseline
foreach num of numlist 1/60 {
                foreach r of numlist 1/5 {
                                       foreach p of numlist 1/2 {
										display as text "#########################################"
                                                display as text "round `r' site `num' group `p'"
                                                summarize round_earning if site_ID == `num' & round == `r' & group_b == `p'
                                                scalar m1 = r(sum)
                                                replace group_earning = m1 if site_ID == `num' & round == `r' & group_b == `p'
							}		
						}		
					}		
*Communication
foreach num of numlist 2/60 {
                foreach r of numlist 6/10 {
                                       foreach p of numlist 1/2 {
                                                display as text "#######################################"
                                                display as text "round `r' site `num' group `p'"
                                                summarize round_earning if site_ID == `num' & round == `r' & group_c == `p'
                                                scalar m1 = r(sum)
                                                replace group_earning = m1 if site_ID == `num' & round == `r' & group_c == `p'
							}		
						}		
					}		
*Deori
foreach num of numlist 1/1 {
                foreach r of numlist 6/7 {
                                       foreach p of numlist 1/2 {
                                                display as text "#######################################"
                                                display as text "round `r' site `num' group `p'"
                                                summarize round_earning if site_ID == `num' & round == `r' & group_c == `p'
                                                scalar m1 = r(sum)
                                                replace group_earning = m1 if site_ID == `num' & round == `r' & group_c == `p'
							}		
						}		
					}		
									
label var group_earning "Round earning of group"
sort playerid round 
gen L1_group_earning= .
replace L1_group_earning = L1.group_earning
label var L1_group_earning "Group earning in previous round"

******************************************************************
* Calculate total real earning of playeres
******************************************************************
gen total_real_earning = .
replace total_real_earning = .
foreach num of numlist 1/60 { 
		foreach p of numlist 1/14 {
				summarize round_earning if site_ID == `num' & play_no == `p'
				scalar m1 = r(sum)
				replace total_real_earning = (m1/1000)+100 if site_ID == `num' & play_no == `p'
			}  
			}
label var total_real_earning "Total real money earning of player i"

* Generate variable that shows how much players shared at the end of the game of their earnings when we asked them to contribute a bit of the money for actual dam maintenance (only in groups with individual payment)
gen share_donated =.
replace share_donated = donate/total_real_earning*100 if round == 1
label var share_donated "Under ind. payment share of real money earning donated"

******************************************************************
* Generate round earning of player in previous round
******************************************************************
gen L1_round_earning =.
replace L1_round_earning = L1.round_earning
label var L1_round_earning "Individual earning in round r-1"

******************************************************************
* Generate total earnings of village over all players and rounds
******************************************************************
sort site_ID
by site_ID : egen overall_earning_village=sum(round_earning)
label var overall_earning "Overall earning of village in whole game"

****************************************************************
* CROP VARIABLES
****************************************************************
***** Generate Wheat Choice of Round in Group w/o Player i
*Baseline
gen wheat_choice_others =.
foreach num of numlist 1/60	{
	foreach r of numlist 1/5	{
		foreach g of numlist 1/7	{
			foreach p of numlist 1/2	{
				summarize wheat if site_ID == `num' & round == `r' & group_b == `p' & pos_b != `g'
				scalar m1 = r(sum)
				replace wheat_choice_others = m1 if site_ID == `num' & round == `r' & group_b == `p' & pos_b != `g' 
							}		
						}		
					}		
				}
*Baseline
foreach num of numlist	2/60	{
	foreach r of numlist	6/10	{
		foreach g of numlist	1/7		{
			foreach p of numlist	1/2		{
				summarize wheat if site_ID == `num' & round == `r' & pos_c != `g' & group_c == `p'
				scalar m1 = r(sum)
				replace wheat_choice_others = m1 if site_ID == `num' & round == `r' & pos_c != `g' & group_c == `p'
							}		
						}		
					}		
				}
*Deori
foreach num of numlist	1/1	{
	foreach r of numlist	6/7	{
		foreach g of numlist	1/7		{
			foreach p of numlist	1/2		{
				summarize wheat if site_ID == `num' & round == `r' & pos_c != `g' & group_c == `p'
				scalar m1 = r(sum)
				replace wheat_choice_others = m1 if site_ID == `num' & round == `r' & pos_c != `g' & group_c == `p'
							}		
						}		
					}		
				}
label var wheat_choice_others "Number of times group members w/o player i chose wheat"

*************************
gen wheat_choice_group =.
foreach num of numlist 1/60	{
	foreach r of numlist 1/5	{
				foreach p of numlist 1/2	{
				summarize wheat if site_ID == `num' & round == `r' & group_b == `p' 
				scalar m1 = r(sum)
				replace wheat_choice_group = m1 if site_ID == `num' & round == `r' & group_b == `p'  
							}		
						}		
					}		
*Baseline
foreach num of numlist	2/60	{
	foreach r of numlist	6/10	{
			foreach p of numlist	1/2		{
				summarize wheat if site_ID == `num' & round == `r' & group_c == `p'
				scalar m1 = r(sum)
				replace wheat_choice_group = m1 if site_ID == `num' & round == `r' & group_c == `p'
							}		
						}		
					}		
							
*Deori
foreach num of numlist	1/1	{
	foreach r of numlist	6/7	{
			foreach p of numlist	1/2		{
				summarize wheat if site_ID == `num' & round == `r'  & group_c == `p'
				scalar m1 = r(sum)
				replace wheat_choice_group = m1 if site_ID == `num' & round == `r' & group_c == `p'
							}		
						}		
					}		
								
label var wheat_choice_group "Number of times group chose wheat"

*** Generate respective Lag var
sort playerid round 
gen L1_wheat_choice_others = .
replace L1_wheat_choice_others = L1.wheat_choice_others
label var L1_wheat_choice_others "Frequency of wheat in own group in r-1"

gen L1_crop_choice = .
replace L1_crop_choice = L1.crop_choice 
label var L1_crop_choice "Crop choice in r-1"

* Generate Wheat Choice of Round in Whole Group
gen wheat_choice_whole_group=.
*Baseline
foreach num of numlist 1/60	{
	foreach r of numlist 1/5	{
		foreach p of numlist 1/2	{
				summarize wheat if site_ID == `num' & round == `r' & group_b == `p'
				scalar m1 = r(sum)
				replace wheat_choice_whole_group = m1 if site_ID == `num' & round == `r' & group_b == `p'
							}		
						}		
					}		
* Communication                                                                                            
foreach num of numlist	2/60	{
	foreach r of numlist	6/10	{
			foreach p of numlist	1/2		{
				summarize wheat if site_ID == `num' & round == `r' & group_c == `p'
				scalar m1 = r(sum)
				replace wheat_choice_whole_group = m1 if site_ID == `num' & round == `r' & group_c == `p'
							}		
						}		
					}		
*For Deori
foreach num of numlist	1/1	{
	foreach r of numlist	6/7	{
			foreach p of numlist	1/2		{
				summarize wheat if site_ID == `num' & round == `r' & group_c == `p'
				scalar m1 = r(sum)
				replace wheat_choice_whole_group = m1 if site_ID == `num' & round == `r' & group_c == `p'
							}		
						}		
					}		
label var wheat_choice_whole_group "Number of times whole group choses wheat"

*Generate lagged variable
sort playerid round 
gen L1_wheat_choice_whole_group = .
replace L1_wheat_choice_whole_group = L1.wheat_choice_whole_group 
label var L1_wheat_choice_whole_group  "Wheat choice of whole group in previous round"

***** Generate Wheat Choice of Round in other Group
*Baseline
gen wheat_choice_other_group =.

foreach num of numlist 1/60   {
	foreach r of numlist 1/5           {
		foreach p of numlist 1/2          {
			summarize wheat if site_ID == `num' & round == `r' & group_b == `p'
			scalar m1 = r(sum)
			replace wheat_choice_other_group = m1 if site_ID == `num' & round == `r' & group_b != `p' 
							}		
						}		
					}		

*phase II
foreach num of numlist           2/60     {
	foreach r of numlist     6/10     {
		foreach p of numlist    1/2                   {
			summarize wheat if site_ID == `num' & round == `r' & group_c == `p'
			scalar m1 = r(sum)
			replace wheat_choice_other_group = m1 if site_ID == `num' & round == `r' & group_c != `p'
							}		
						}		
					}		

*Deori
foreach num of numlist           1/1       {
	foreach r of numlist     6/7       {
		foreach p of numlist    1/2                   {
			summarize wheat if site_ID == `num' & round == `r' & group_c == `p'
			scalar m1 = r(sum)
			replace wheat_choice_other_group = m1 if site_ID == `num' & round == `r' & group_c != `p'
							}		
						}		
					}		
        
label var wheat_choice_other_group "Frequency of wheat in other group"
gen L1_wheat_choice_other_group = L1.wheat_choice_other_group
label var L1_wheat_choice_other_group "Frequency of wheat in other group r-1"

******************************************************************
*Create Dummy for villages that use dam for farming 
global nofarming  "Baghraudi_FV Batwar Bhapsa Budhanwara Chandiya_Ryt Deori Dharampuri_Mal Dilwara Dudka Dungaria Dungariya_Ramnagar Dungravt Fonk Ghont Gunehara Jhagul Kanhari_Kalan Kanhari_Khurd Kanskheda Kata_Mal Khalaudi_FV Kharpariya Khatiya_Narangi Khuksar_RF Magdha Manegaon Mangaveli_Mal Manikpur_Mal Manoharpur Mubala_Mal Mulwalasani_Ryt Nakawal Sarasdoli Sarhi Sautia Samaiya_Bhagpur_FV Thonda Umariya_FV"
global forfarming "Atarchuha Atariya Banijagoan Bariha Changariya Chatuwakhar Dhamangaon Gunegaon Gubri Jhulup Katanga_Ryt Khamrauti Khirahani Kosampani Mangaveli_Ryt Medhatal Padariya Rata Saradoli_Mal Shahapur Taktuwa Tilari"

gen damforfarming =.
foreach a of global forfarming { 
	foreach b of global nofarming { 
		replace damforfarming = 1 if site=="`a'" 
			replace damforfarming = 0 if site=="`b'" 
		}
	}
label var damforfarming "Dam used for farming"

* Create Dummy "Other Group invested more"
gen group1b =.
replace group1b=group_inv		 	if group_b==1 & round <6
replace group1b=other_group_inv 	if group_b==2 & round <6

gen group2b =.
replace group2b=group_inv		 	if group_b==2 & round <6
replace group2b=other_group_inv 	if group_b==1 & round <6

gen group1c =.
replace group1c=group_inv		 	if group_c==1 & round >5
replace group1c=other_group_inv 	if group_c==2 & round >5

gen group2c =.
replace group2c=group_inv		 	if group_c==2 & round >5
replace group2c=other_group_inv 	if group_c==1 & round >5

gen other_inv_more=.
replace other_inv_more = 1  if group_b==1 & group1b < group2b
replace other_inv_more = 0 if group_b==1 & group1b > group2b
replace other_inv_more = 1  if group_b==2 & group2b < group1b
replace other_inv_more = 0  if group_b==2 & group2b > group1b

replace other_inv_more = 1  if group_c==1 & group1c < group2c
replace other_inv_more = 0  if group_c==1 & group1c > group2c
replace other_inv_more = 1  if group_c==2 & group2c < group1c
replace other_inv_more = 0  if group_c==2 & group2c > group1c

gen L1_other_inv_more = .
replace L1_other_inv_more = L1.other_inv_more
label var L1_other_inv_more "Other group invested more r-1"

**********************************************
* Generate average investment and wheat choices at the individual level 
*For phase I (r1-5), phase II (r6-10), and over the entire game 
* FOR CORRELATIONS INDIVIDUAL LEVEL
**********************************************
sort site_ID playerid round
gen av_invest_ind_R1_5 =.
foreach num of numlist 1/60 {
        foreach p of numlist 1/14 {
              summarize investment if site_ID == `num' & play_no == `p' & round < 6
              scalar m1 = r(mean)
              replace av_invest_ind_R1_5 = m1 if site_ID == `num' & play_no == `p' & round < 6
                                   }                          
								   } 
gen av_invest_ind_R6_10 =.
foreach num of numlist 1/60 {
        foreach p of numlist 1/14 {
              summarize investment if site_ID == `num' & play_no == `p' & round > 5
              scalar m1 = r(mean)
              replace av_invest_ind_R6_10 = m1 if site_ID == `num' & play_no == `p' & round > 5
                                   }                       
								   } 			
gen av_invest_ind_R1_10 =.
foreach num of numlist 1/60 {
        foreach p of numlist 1/14 {
              summarize investment if site_ID == `num' & play_no == `p'
              scalar m1 = r(mean)
              replace av_invest_ind_R1_10 = m1 if site_ID == `num' & play_no == `p'
                                   }                    
								   } 			


sort site_ID playerid round

**********************************************
* Generate average investment and wheat choices at the village level 
*For phase I (r1-5), phase II (r6-10), and over the entire game 
**********************************************
gen av_invest_vill_R1_5 =.
foreach num of numlist 1/60 {
              summarize investment if site_ID == `num' & round < 6
              scalar m1 = r(mean)
              replace av_invest_vill_R1_5 = m1 if site_ID == `num' & round < 6
                            } 
gen av_invest_vill_R6_10 =.
foreach num of numlist 1/60 {
              summarize investment if site_ID == `num' & round > 5
              scalar m1 = r(mean)
              replace av_invest_vill_R6_10 = m1 if site_ID == `num' & round >5
                            } 
gen av_invest_vill_R1_10 =.							
foreach num of numlist 1/60 {
              summarize investment if site_ID == `num'               
			  scalar m1 = r(mean)
              replace av_invest_vill_R1_10 = m1 if site_ID == `num' 
                            } 
******
gen sum_wheat_vill_R1_5 =.
foreach num of numlist 1/60 {
              summarize wheat if site_ID == `num' & round < 6
              scalar m1 = r(sum)
              replace sum_wheat_vill_R1_5 = m1 if site_ID == `num' & round < 6
                            } 

gen sum_wheat_vill_R6_10 =.
foreach num of numlist 1/60 {
              summarize wheat if site_ID == `num' & round > 5
              scalar m1 = r(sum)
              replace sum_wheat_vill_R6_10 = m1 if site_ID == `num' & round >5
                            } 
gen sum_wheat_vill_R1_10 =.				
foreach num of numlist 1/60 {
              summarize wheat if site_ID == `num' 
              scalar m1 = r(sum)
              replace sum_wheat_vill_R1_10 = m1 if site_ID == `num' 
                            }
							
sort site_ID round
by site_ID round : egen av_inv_vill_total = mean(investment)
by site_ID round : egen wheat_choice_vill = mean(wheat)
by site_ID round : egen gram_choice_vill = mean(gram)

label var av_inv_vill_total "Mean investment in village over all rounds"
label var wheat_choice_vill "Mean share of wheat in village over all rounds"
label var gram_choice_vill  "Mean share of gram in village over all rounds"

by site_ID  round: egen cont_money_vill = total(cont_money) if round ==1
label var cont_money_vill "Total of participants that contributed money to dam maintenance"
by site_ID round : egen cont_lab_vill = total(cont_lab) if round ==1
label var cont_lab_vill "Total of participants that contributed labor to dam maintenance"

by site_ID round: egen reci_wat_vill = total(reci_wat) if round ==1
label var reci_wat_vill "Total of participants that received water from village dam"

by site_ID round : egen dist_field_vill = mean(dist_field) if round ==1
label var dist_field_vill "Average distance between participants fields and dam in village"

**********************************************
* Generate variables on communication  in village specified by gender 
**********************************************
*---------------------------total communication  in village
bysort site: egen vill_argue=total(argue) 
bysort site: egen vill_reject_rule=total(reject_rule) 
bysort site: egen vill_agree_rule=total(agree_rule) 
bysort site: egen vill_propose_rule=total(propose_rule) 
bysort site: egen vill_praises=total(praises) 
bysort site: egen vill_complains=total(complains) 
bysort site: egen vill_punish=total(propose_punish) 
bysort site: egen vill_reward=total(propose_reward) 
bysort site: egen vill_unconnected=total(unconnected) 

* Total 
gen vill_total_gamerelated = vill_argue + vill_reject_rule + vill_agree_rule + vill_propose_rule + vill_praises + vill_complains + vill_punish +  vill_reward
gen vill_total_all = vill_argue + vill_reject_rule + vill_agree_rule + vill_propose_rule + vill_praises + vill_complains + vill_punish + vill_reward + vill_unconnected

**********************************************
* Generate variables on leaders  in village specified by gender 
**********************************************
gen leader_female =.
replace leader_female = 1 if elected_leader ==1 & females ==1
replace leader_female = 0 if elected_leader ==1 & females ==0
label var leader_female "leader is female (=1); leader is male (=0)"
label define leader_female_1 1 "Leader is female" 0 "Leader is male" 
label values leader_female leader_female_1

gen leader_male =.
replace leader_male = 1 if elected_leader ==1 & females ==0
replace leader_male = 0 if elected_leader ==1 & females ==1
label var leader_male "leader is male (=1); leader is female (=0)"
label define leader_male_1 1 "Leader is male" 0 "Leader is female" 
label values leader_male leader_male_1

gen female_leader =.
replace female_leader = 1 if elected_leader ==1 & females ==1
replace female_leader = 0 if elected_leader ==0 & females ==1
label var female_leader "female is leader (=1); female is not leader (=0)"
label define female_leader_1 1 "Female is leader" 0 "Female is no leader" 
label values female_leader female_leader_1

gen female_no_leader =.
replace female_no_leader = 1 if elected_leader ==0 & females ==1
replace female_no_leader = 0 if elected_leader ==1 & females ==1
label var female_no_leader "female is not leader (=1); female is  leader (=0)"
label define female_no_leader_1 1 "Female is no leader" 0 "Female is  leader" 
label values female_leader female_no_leader_1

gen male_leader =.
replace male_leader = 1 if elected_leader ==1 & females ==0
replace male_leader = 0 if elected_leader ==0 & females ==0
label var male_leader "male is leader (=1); male is not leader (=0)"
label define male_leader_1 1 "Male is leader" 0 "Male is no leader" 
label values male_leader male_leader_1

gen male_no_leader =.
replace male_no_leader = 1 if elected_leader ==0 & females ==0
replace male_no_leader = 0 if elected_leader ==1 & females ==0
label var male_no_leader "male is not leader (=1); male is  leader (=0)"
label define male_no_leader_1 1 "Male is no leader" 0 "Male is  leader" 
label values male_no_leader male_no_leader_1

*---------------------------Generate female leader variables at village level
bysort site round : egen leader_female_vill=sum(leader_female) 
label var leader_female_vill "Sum of female leaders"

bysort site round : egen no_leader_female_vill=sum(female_no_leader) 
label var no_leader_female_vill "Sum of females that are no leaders in village"

bysort site round : egen leader_male_vill=sum(leader_male) 
label var leader_male_vill "Sum of male leaders in village"

bysort site round : egen no_leader_male_vill=sum(male_no_leader) 
label var no_leader_male_vill "Sum of males that are no leaders in village"

**********************************************
* Generate variables on education  in village specified by gender 
**********************************************
gen edu_female_illit =.
replace edu_female_illit = 1 if edu ==1 & females ==1
replace edu_female_illit = 0 if edu >1 & females ==1

gen edu_female_prim =.
replace edu_female_prim = 1 if edu ==2 & females ==1
replace edu_female_prim = 0 if edu !=2 & females ==1

gen edu_female_sec =.
replace edu_female_sec = 1 if edu ==3 & females ==1
replace edu_female_sec = 0 if edu !=3 & females ==1

gen edu_female_uni =.
replace edu_female_uni = 1 if edu >=3 & females ==1
replace edu_female_uni = 0 if edu <3 & females ==1

***
gen edu_male_illit =.
replace edu_male_illit = 1 if edu ==1 & females ==0
replace edu_male_illit = 0 if edu >1 & females ==0

gen edu_male_prim =.
replace edu_male_prim = 1 if edu ==2 & females ==0
replace edu_male_prim = 0 if edu !=2 & females ==0

gen edu_male_sec =.
replace edu_male_sec = 1 if edu ==3 & females ==0
replace edu_male_sec = 0 if edu !=3 & females ==0

gen edu_male_uni =.
replace edu_male_uni = 1 if edu >=3 & females ==0
replace edu_male_uni = 0 if edu <3 & females ==0

***
bysort site round : egen edu_female_illit_vill=sum(edu_female_illit) 
label var edu_female_illit_vill "Sum of females that are illiterate"

bysort site round : egen edu_female_prim_vill=sum(edu_female_prim) 
label var edu_female_prim_vill "Sum of females that have primary education"

bysort site round : egen edu_female_sec_vill=sum(edu_female_sec) 
label var edu_female_sec_vill "Sum of females that have secondary education"

bysort site round : egen edu_female_uni_vill =sum(edu_female_uni) 
label var edu_female_uni_vill "Sum of females that have a uni degree"

***
bysort site round : egen edu_male_illit_vill=sum(edu_male_illit) 
label var edu_male_illit_vill "Sum of males that are illiterate"

bysort site round : egen edu_male_prim_vill=sum(edu_male_prim) 
label var edu_male_prim_vill "Sum of males that have primary education"

bysort site round : egen edu_male_sec_vill=sum(edu_male_sec) 
label var edu_male_sec_vill "Sum of males that have secondary education"

bysort site round : egen edu_male_uni_vill =sum(edu_male_uni) 
label var edu_male_uni_vill "Sum of males that have a uni degree"



******************************************************************
* ADD MISSING LABELS FOR GAME DATA
******************************************************************
label var investment "Individual Investment"
label var water_used "Individual water used for crop choice"
label var earning_dam "Individual earnings from dam in round"
label var round_earning "Individual total earnings in round"
label var crop_choice "Individual Crop Choice"
label var play_no "Player number"
label var cont_lab "Individual labor contribution to dam"
label var cont_money "Individual money contribution to dam"
label var reci_wat "Water received from dam"
label var group_b "Group if basic round"
label var group_c "Group if communication round"
label var pos_b "Position of player in basic round"
label var pos_c "Position of player in communication round"
label var site_ID "Site ID"
label var coll_money "Person who collected the donated money"
label var round "Round"

label var vill_argue "Total of arguments in village for group"
label var vill_reject_rule "Total of rejected rules in village for group"
label var vill_agree_rule "Total of agreed rules in village for group"
label var vill_propose_rule "Total of proposed rules in village for group"
label var vill_complains "Total of complains in village for group"
label var vill_praises "Total of praises in village for group"
label var vill_reward "Total of proposed reward in village group"
label var vill_punish "Total of proposed punishment in village group"
label var vill_unconnected "Total of unconnected inputs in village group"

label var vill_total_gamerelated "Total game related communication in village during discussion slots"
label var vill_total_all "Total communication in village during discussion slots"


rename site site_game

rename *_female_* *_fem_*
rename  *_female *_fem
rename  *_females *_fem

rename *_invest_* *_inv_*

*------------------
gen literacy =.
replace literacy = 1 if illiterate == 0
replace literacy = 0 if illiterate == 1

gen edu_primary =. 
replace edu_primary = 1 if edu ==2
replace edu_primary = 0 if edu ==1
replace edu_primary = 0 if edu >=3

gen edu_secondary =. 
replace edu_secondary = 1 if edu ==3
replace edu_secondary = 0 if edu <=2
replace edu_secondary = 0 if edu >=4

gen edu_university =. 
replace edu_university = 1 if edu >=4
replace edu_university = 0 if edu <=3

gen excluded_villages = 0 //checked with final sample list in "2023_03_Survey&Game_Wide" as of 29.03.2023
replace excluded_villages = 1 if site_ID ==29
replace excluded_villages = 1 if site_ID ==34
replace excluded_villages = 1 if site_ID ==37
replace excluded_villages = 1 if site_ID ==48



egen dam_contribution = rowmax (cont_lab  cont_money)


*leader composition in games
*dummy for male leader presence
gen male_leader_present = 0 if leader_male_vill==0
replace male_leader_present = 1 if leader_male_vill>0


*dummy for female leader presence
gen female_leader_present= 0 if leader_fem_vill==0
replace female_leader_present = 1 if leader_fem_vill>0

tab female_leader_present male_leader_present


*composition of leader presence
gen leader_present = 0 if male_leader_present==0 & female_leader_present==0
replace leader_present = 1 if male_leader_present == 1 & female_leader_present==0
replace leader_present = 2 if male_leader_present == 1 & female_leader_present==1
replace leader_present = 3 if male_leader_present == 0 & female_leader_present==1

lab def leader_lab 0 "None" 1 "Only Male" 2 "Both" 3 "Only Female", replace
lab val leader_present leader_lab
tab leader_present, gen(leader_comp)

gen participant_type = 1 if leader_fem==0
replace participant_type = 2 if leader_fem==1
replace participant_type = 3 if leader_type==1 & sex==1
replace participant_type = 4 if leader_type==1 & sex==0
lab def party 1 "Male leader" 2 "Female leader" 3 "Male villager" 4 "Female villager", replace
lab val participant_type party

lab def lead_fem 0 "Male leader (n=66)" 1 "Female leader (n=23)", replace
lab val leader_fem lead_fem

tab leader_type, gen(leader_)

egen total_leaders = rowtotal(sum_leader_state sum_leader_CR sum_leader_SHG sum_leader_culturestate)



save "$working_ANALYSIS/data/2022_06_Mandla_Game", replace

*##############################
* Get Data on the Facilitator Teams and the Intervention dates
* Source: Excel 
*##############################
clear
import excel "$working_ANALYSIS/data/Facilitators_MP_sites.xls", sheet("Sheet1")  firstrow
keep Site_ID Village date_new_lba Facilitationteam LeadFacilitator Assistant DEO Code count_intervention

rename Site_ID site_ID
drop if site_ID ==.
****** Intervention Dates
rename  date_new_lba date_intervention
format date_intervention  %td

gen date_first_intervention = mdy(3, 23, 2017) 
format date_first_intervention %tdYYMonthDD 
replace date_first_intervention = . if Code ==.

gen date_last_intervention = mdy(7, 15, 2017) 
format date_last_intervention %tdYYMonthDD 
replace date_last_intervention = . if Code ==.

gen date_count = date_intervention - date_first_intervention 

label var date_first_intervention  "Date of the first intervention taking place"
label var date_last_intervention   "Date of the last intervention taking place"
label var date_count "Days since first intervention took place"
label var count_intervention "Indicates the how maniest intervention this is conducted by the team"

****** Data on Facilitators
tab LeadFacilitator
gen game_lead_facil =.
replace game_lead_facil = 1 if LeadFacilitator == "Radha"
replace game_lead_facil = 0 if LeadFacilitator == "Shivraj"
label define facil 1 "Radha" 0 "Shivraj", replace
label values game_lead_facil facil
label var game_lead_facil "Lead facilitator during intervention in village"
drop LeadFacilitator

tab site_ID if game_lead_facil ==.
tab Village if site_ID ==13 // Dhamangaon
tab Village if site_ID ==37 // no observations?? --> should be  Khuksar_RF 
replace Village = "Khuksar_RF" if site_ID ==37

save   "$working_ANALYSIS/data/Data_Facilitators", replace

******************************************************************
*Match game data with facilitator data 
******************************************************************
use "$working_ANALYSIS/data/2022_06_Mandla_Game", clear

merge m:1 site_ID using "$working_ANALYSIS/data/Data_Facilitators"
drop _merge

tab site_ID if game_lead_facil ==.
tab site_game if site_ID ==13 // Dhamangaon
tab site_game if site_ID ==37 //  Khuksar_RF 

gen game_with_Radha =.
replace game_with_Radha =1 if site_game =="Deori"
replace game_with_Radha =1 if facil=="Chandrahas, Duche, Radha, Lara"
replace game_with_Radha =1 if facil=="Chandrahas, Radha, Duche, Lara"
replace game_with_Radha =1 if facil=="Radha Chadrahas and Duche"
replace game_with_Radha =1 if facil=="Radha Chandrahas Sunit and Duche"
replace game_with_Radha =1 if facil=="Radha Chandrahas Sunit and VD Duche"
replace game_with_Radha =1 if facil=="Radha Rajesh Shivraj and VD Duche"
replace game_with_Radha =1 if facil=="Radha Shivraj Chandrahas and VD Duche"
replace game_with_Radha =1 if facil=="Radha Shivraj Rajesh and VD Duche"
replace game_with_Radha =1 if facil=="Radha, Chandrahas, Duche and Soniya"
replace game_with_Radha =1 if facil=="Radha, Chandrahas, Shivraj, Duche"
replace game_with_Radha =1 if facil=="Radha, Rajesh, Duche"
replace game_with_Radha =1 if facil=="Radha, Rajesh, Sumit, Duche"
replace game_with_Radha =1 if facil=="Radha, Shivraj, Rajesh, Duche"
replace game_with_Radha =1 if facil=="Radha, Shivraj, Sumit, Duche"
replace game_with_Radha =1 if facil=="Rajesh Shivraj Radha and VD Duche"
replace game_with_Radha =1 if facil=="SHIVRAJ RADHA DUCHE AND SONIYA"
replace game_with_Radha =1 if facil=="Shivraj Rajesh Radha and VD Duche"
replace game_with_Radha =1 if facil=="Sonja, Duche, Chandrahas, Rada, Lara"
replace game_with_Radha =1 if facil=="Sonja, Prasoon, Shivraj, Abhisek, Rajiv, Lara, Rada"
replace game_with_Radha =0 if facil=="Duche, Chahandras, Shivraj, Sonja"
replace game_with_Radha =0 if facil=="Duche, Rajesh, Shivraj, Prasoon, Sonja"
replace game_with_Radha =0 if facil=="Prasoo, Rajesh, Shivraj,Sonja"
replace game_with_Radha =0 if facil=="Prasoon, Shivraj, Rajesh, Sonja"
replace game_with_Radha =0 if facil=="Prasoon, Shrivaj, Rajesh, Sonja"
replace game_with_Radha =0 if facil=="Prasoon, Sonja, Shivraj"
replace game_with_Radha =0 if facil=="Rajesh, Shivraj, Duche"
replace game_with_Radha =0 if facil=="Rajesh Shivraj Sanjay and VD Duche"
replace game_with_Radha =0 if facil=="Shivraj Rajesh Premlal and VD Duche"
replace game_with_Radha =0 if facil=="Shivraj Rajesh Sumit and VD Duche"
replace game_with_Radha =0 if facil=="Shivraj Rajesh and VD Duche"
replace game_with_Radha =0 if facil=="Shivraj, Rajesh, Duche"
replace game_with_Radha =0 if facil=="Shivraj, Rajesh, Guljar, Duche"
replace game_with_Radha =0 if facil=="Shivraj, Rajesh, Premlal, Duche"
replace game_with_Radha =0 if facil=="Shivraj, Rajesh, Sumit, Duche"
replace game_with_Radha =0 if facil=="Thomas, Prasoon, Shivraj, Lara"
replace game_with_Radha =0 if facil=="duche, chandrahas, Sonja, shivraj"
replace game_with_Radha =0 if facil=="Sonja, Duche, Chandrahas, Shivraj, Rajiv, Prasoon, Lara"

label define radha  1 "with radha" 0 "without Radha", replace
label values game_with_Radha radha
label var game_with_Radha "Radha (only Indian women) was part of facilitator team"

tab site_ID if game_with_Radha ==. // 8 14 17 18 25 29 37 48 50

tab facil if site_ID ==8
tab facil if site_ID ==14
tab facil if site_ID ==17
tab facil if site_ID ==18
tab facil if site_ID ==25
tab facil if site_ID ==29
tab facil if site_ID ==37
tab facil if site_ID ==48
tab facil if site_ID ==50 

tab date_intervention if game_with_Radha ==1 // first date with Radha: 08.04.2017 ---> as she joined later everything before that is probably w/o her (DOUBLE CHECK)
tab date_intervention if site_ID ==17  // 23.3.2017
tab date_intervention if site_ID ==29  // 25.3.2017
tab date_intervention if site_ID ==50  // 28.3.2017
tab date_intervention if site_ID ==18  // 29.3.2017
tab date_intervention if site_ID ==8  // 9.4.2017
tab date_intervention if site_ID ==25  // 10.4.2017
tab date_intervention if site_ID ==48  // 04.05.2017
tab date_intervention if site_ID ==14  // 17.5.2017
tab date_intervention if site_ID ==37  // no observation?

replace game_with_Radha =0 if site_ID == 17
replace game_with_Radha =0 if site_ID ==29
replace game_with_Radha =0 if site_ID == 50 
replace game_with_Radha =0 if site_ID == 18

********************************************************************************
*GENERATE CATEGROICAL VARIABLES THAT INDICATE THE OPTIMAL SUCCESS OF THE VILLAGES DURING THE GAME
********************************************************************************
* group_inv indicates investment of both groups in each site for each round. An investment at the group level is optimal if group invested a total of 16000.
*Caveat: of course that does in this definition not mean that all players invested the optimal amount. Instead, a few players could invest little while others invest a lot....
gen game_opt_invested =.
replace game_opt_invested = 1 if  group_inv >= 16000 
replace game_opt_invested = 0 if  group_inv < 16000 

*Did group 1 and 1 invested optimally in the 1st round
gen game_opt_invest_g1r1 = .
foreach num of numlist 1/60 { 
	foreach r of numlist 1/10 {
		foreach g of numlist 1, 2 {
			display as text "#########################################"
			display as text "round `r' site `num'  "
			summarize game_opt_invested if site_ID == `num' & round == 1 & group_b == 1 
			scalar m1 = r(max)
			replace game_opt_invest_g1r1 = m1 if site_ID == `num' & round == `r' & group_b == `g' 
					}		
				}
			}
gen game_opt_invest_g2r1 = .
foreach num of numlist 1/60 { 
 foreach g of numlist 1, 2 {
	foreach r of numlist 1/10 {
			display as text "round `r' site `num' group_no_com `g' "
			summarize game_opt_invested if site_ID == `num' & round == 1 & group_b == 2 
			scalar m1 = r(max)
			replace game_opt_invest_g2r1 = m1 if site_ID == `num' & round == `r' & group_b == `g' 
					}		
				}
			}
*Did group 1 and 1 invested optimally in the 2nd round
gen game_opt_invest_g1r2 = .
foreach num of numlist 1/60 { 
	foreach r of numlist 1/10 {
		foreach g of numlist 1, 2 {
			display as text "#########################################"
			display as text "round `r' site `num'  "
			summarize game_opt_invested if site_ID == `num' & round == 2 & group_b == 1 
			scalar m1 = r(max)
			replace game_opt_invest_g1r2 = m1 if site_ID == `num' & round == `r' & group_b == `g' 
					}		
				}
			}
gen game_opt_invest_g2r2 = .
foreach num of numlist 1/60 { 
 foreach g of numlist 1, 2 {
	foreach r of numlist 1/10 {
			display as text "round `r' site `num' group_no_com `g' "
			summarize game_opt_invested if site_ID == `num' & round == 2 & group_b == 2 
			scalar m1 = r(max)
			replace game_opt_invest_g2r2 = m1 if site_ID == `num' & round == `r' & group_b == `g' 
					}		
				}
			}
*Did group 1 and 1 invested optimally in the 3rd round
gen game_opt_invest_g1r3 = .
foreach num of numlist 1/60 { 
	foreach r of numlist 1/10 {
		foreach g of numlist 1, 2 {
			display as text "#########################################"
			display as text "round `r' site `num'  "
			summarize game_opt_invested if site_ID == `num' & round == 3 & group_b == 1 
			scalar m1 = r(max)
			replace game_opt_invest_g1r3 = m1 if site_ID == `num' & round == `r' & group_b == `g' 
					}		
				}
			}
gen game_opt_invest_g2r3 = .
foreach num of numlist 1/60 { 
 foreach g of numlist 1, 2 {
	foreach r of numlist 1/10 {
			display as text "round `r' site `num' group_no_com `g' "
			summarize game_opt_invested if site_ID == `num' & round == 3 & group_b == 2 
			scalar m1 = r(max)
			replace game_opt_invest_g2r3 = m1 if site_ID == `num' & round == `r' & group_b == `g' 
					}		
				}
			}
*Did group 1 and 1 invested optimally in the 4st round
gen game_opt_invest_g1r4 = .
foreach num of numlist 1/60 { 
	foreach r of numlist 1/10 {
		foreach g of numlist 1, 2 {
			display as text "#########################################"
			display as text "round `r' site `num'  "
			summarize game_opt_invested if site_ID == `num' & round == 4 & group_b == 1 
			scalar m1 = r(max)
			replace game_opt_invest_g1r4 = m1 if site_ID == `num' & round == `r' & group_b == `g' 
					}		
				}
			}
gen game_opt_invest_g2r4 = .
foreach num of numlist 1/60 { 
 foreach g of numlist 1, 2 {
	foreach r of numlist 1/10 {
			display as text "round `r' site `num' group_no_com `g' "
			summarize game_opt_invested if site_ID == `num' & round == 4 & group_b == 2 
			scalar m1 = r(max)
			replace game_opt_invest_g2r4 = m1 if site_ID == `num' & round == `r' & group_b == `g' 
					}		
				}
			}
*Did group 1 and 1 invested optimally in the 5th round
gen game_opt_invest_g1r5 = .
foreach num of numlist 1/60 { 
	foreach r of numlist 1/10 {
		foreach g of numlist 1, 2 {
			display as text "#########################################"
			display as text "round `r' site `num'  "
			summarize game_opt_invested if site_ID == `num' & round == 5 & group_b == 1 
			scalar m1 = r(max)
			replace game_opt_invest_g1r5 = m1 if site_ID == `num' & round == `r' & group_b == `g' 
					}		
				}
			}
gen game_opt_invest_g2r5 = .
foreach num of numlist 1/60 { 
 foreach g of numlist 1, 2 {
	foreach r of numlist 1/10 {
			display as text "round `r' site `num' group_no_com `g' "
			summarize game_opt_invested if site_ID == `num' & round == 5 & group_b == 2 
			scalar m1 = r(max)
			replace game_opt_invest_g2r5 = m1 if site_ID == `num' & round == `r' & group_b == `g' 
					}		
				}
			}
*Did group 1 and 1 invested optimally in the 6th round
gen game_opt_invest_g1r6 = .
foreach num of numlist 1/60 { 
	foreach r of numlist 1/10 {
		foreach g of numlist 1, 2 {
			display as text "#########################################"
			display as text "round `r' site `num'  "
			summarize game_opt_invested if site_ID == `num' & round == 6 & group_b == 1 
			scalar m1 = r(max)
			replace game_opt_invest_g1r6 = m1 if site_ID == `num' & round == `r' & group_b == `g' 
					}		
				}
			}
gen game_opt_invest_g2r6 = .
foreach num of numlist 1/60 { 
 foreach g of numlist 1, 2 {
	foreach r of numlist 1/10 {
			display as text "round `r' site `num' group_no_com `g' "
			summarize game_opt_invested if site_ID == `num' & round == 6 & group_b == 2 
			scalar m1 = r(max)
			replace game_opt_invest_g2r6 = m1 if site_ID == `num' & round == `r' & group_b == `g' 
					}		
				}
			}
*Did group 1 and 1 invested optimally in the 7th round
gen game_opt_invest_g1r7 = .
foreach num of numlist 1/60 { 
	foreach r of numlist 1/10 {
		foreach g of numlist 1, 2 {
			display as text "#########################################"
			display as text "round `r' site `num'  "
			summarize game_opt_invested if site_ID == `num' & round == 7 & group_b == 1 
			scalar m1 = r(max)
			replace game_opt_invest_g1r7 = m1 if site_ID == `num' & round == `r' & group_b == `g' 
					}		
				}
			}
gen game_opt_invest_g2r7 = .
foreach num of numlist 1/60 { 
 foreach g of numlist 1, 2 {
	foreach r of numlist 1/10 {
			display as text "round `r' site `num' group_no_com `g' "
			summarize game_opt_invested if site_ID == `num' & round == 7 & group_b == 2 
			scalar m1 = r(max)
			replace game_opt_invest_g2r7 = m1 if site_ID == `num' & round == `r' & group_b == `g' 
					}		
				}
			}
*Did group 1 and 1 invested optimally in the 8th round
gen game_opt_invest_g1r8 = .
foreach num of numlist 1/60 { 
 foreach g of numlist 1, 2 {
	foreach r of numlist 1/10 {
			display as text "round `r' site `num' group_no_com `g' "
			summarize game_opt_invested if site_ID == `num' & round == 8 & group_c == 1 
			scalar m1 = r(max)
			replace game_opt_invest_g1r8 = m1 if site_ID == `num' & round == `r' & group_c == `g' 
					}		
				}
			}
gen game_opt_invest_g2r8 = .
foreach num of numlist 1/60 { 
 foreach g of numlist 1, 2 {
	foreach r of numlist 1/10 {
			display as text "round `r' site `num' group_no_com `g' "
			summarize game_opt_invested if site_ID == `num' & round == 8 & group_c == 2 
			scalar m1 = r(max)
			replace game_opt_invest_g2r8 = m1 if site_ID == `num' & round == `r' & group_c == `g' 
					}		
				}
			}
*Did group 1 and 1 invested optimally in the 9th round
gen game_opt_invest_g1r9 = .
foreach num of numlist 1/60 { 
 foreach g of numlist 1, 2 {
	foreach r of numlist 1/10 {
			display as text "round `r' site `num' group_no_com `g' "
			summarize game_opt_invested if site_ID == `num' & round == 9 & group_c == 1 
			scalar m1 = r(max)
			replace game_opt_invest_g1r9 = m1 if site_ID == `num' & round == `r' & group_c == `g' 
					}		
				}
			}
gen game_opt_invest_g2r9 = .
foreach num of numlist 1/60 { 
 foreach g of numlist 1, 2 {
	foreach r of numlist 1/10 {
			display as text "round `r' site `num' group_no_com `g' "
			summarize game_opt_invested if site_ID == `num' & round == 9 & group_c == 2 
			scalar m1 = r(max)
			replace game_opt_invest_g2r9 = m1 if site_ID == `num' & round == `r' & group_c == `g' 
					}		
				}
			}
*Did group 1 and 1 invested optimally in the 10th round
gen game_opt_invest_g1r10 = .
foreach num of numlist 1/60 { 
 foreach g of numlist 1, 2 {
	foreach r of numlist 1/10 {
			display as text "round `r' site `num' group_c `g' "
			summarize game_opt_invested if site_ID == `num' & round == 10 & group_c == 1 
			scalar m1 = r(max)
			replace game_opt_invest_g1r10 = m1 if site_ID == `num' & round == `r' & group_c == `g' 
					}		
				}
			}
gen game_opt_invest_g2r10 = .
foreach num of numlist 1/60 { 
 foreach g of numlist 1, 2 {
	foreach r of numlist 1/10 {
			display as text "round `r' site `num' group_no_com `g' "
			summarize game_opt_invested if site_ID == `num' & round == 10 & group_c == 2 
			scalar m1 = r(max)
			replace game_opt_invest_g2r10 = m1 if site_ID == `num' & round == `r' & group_c == `g' 
					}		
				}
			}	
**********************
*Generate variable that counts how may rounds the groups in the village reached optimal investment (max 20 / 2 groups each 10 rounds)
egen game_total_opt_invest = rowtotal(game_opt_invest_g1r1 game_opt_invest_g2r1 game_opt_invest_g1r2 game_opt_invest_g2r2 game_opt_invest_g1r3 game_opt_invest_g2r3 game_opt_invest_g1r4 game_opt_invest_g2r4 game_opt_invest_g1r5 game_opt_invest_g2r5 game_opt_invest_g1r6 game_opt_invest_g2r6 game_opt_invest_g1r7 game_opt_invest_g2r7 game_opt_invest_g1r8 game_opt_invest_g2r8 game_opt_invest_g1r9 game_opt_invest_g2r9 game_opt_invest_g1r10 game_opt_invest_g2r10)

**********************
* GENERATE VARIABLE THAT INDICATE IF BOTH; NONE OR ONE GROUP INVESTED OPTIMALLY IN ROUND 8
gen game_opt_invest_r8 =.	
replace game_opt_invest_r8 =1  if game_opt_invest_g1r8 ==0 & game_opt_invest_g2r8 ==0
replace game_opt_invest_r8 =2  if game_opt_invest_g1r8 ==1 & game_opt_invest_g2r8 ==0
replace game_opt_invest_r8 =2  if game_opt_invest_g1r8 ==0 & game_opt_invest_g2r8 ==1
replace game_opt_invest_r8 =3  if game_opt_invest_g1r8 ==1 & game_opt_invest_g2r8 ==1
label var game_opt_invest_r8 "Optimal investment in round 8 reached by.."
label values game_opt_invest_r8 invest

* GENERATE VARIABLE THAT INDICATE IF BOTH; NONE OR ONE GROUP INVESTED OPTIMALLY IN ROUND 9
gen game_opt_invest_r9 =.	
replace game_opt_invest_r9 =1  if game_opt_invest_g1r9 ==0 & game_opt_invest_g2r9 ==0
replace game_opt_invest_r9 =2  if game_opt_invest_g1r9 ==1 & game_opt_invest_g2r9 ==0
replace game_opt_invest_r9 =2  if game_opt_invest_g1r9 ==0 & game_opt_invest_g2r9 ==1
replace game_opt_invest_r9 =3  if game_opt_invest_g1r9 ==1 & game_opt_invest_g2r9 ==1
label var game_opt_invest_r9 "Optimal investment in round 9 reached by.."
label values game_opt_invest_r9 invest
	
* GENERATE VARIABLE THAT INDICATE IF BOTH; NONE OR ONE GROUP INVESTED OPTIMALLY IN ROUND 10	
gen game_opt_invest_r10=.	
replace game_opt_invest_r10 =1  if game_opt_invest_g1r10 ==0 & game_opt_invest_g2r10 ==0
replace game_opt_invest_r10 =2  if game_opt_invest_g1r10 ==1 & game_opt_invest_g2r10 ==0
replace game_opt_invest_r10 =2  if game_opt_invest_g1r10 ==0 & game_opt_invest_g2r10 ==1
replace game_opt_invest_r10 =3  if game_opt_invest_g1r10 ==1 & game_opt_invest_g2r10 ==1
label var game_opt_invest_r10 "Optimal investment in round 10 reached by.."
label values game_opt_invest_r10 invest

*#####################################################################
gen game_optimal_invest_r10 = 0
replace game_optimal_invest_r10 =1  if game_opt_invest_g1r10 ==1 & game_opt_invest_g2r10 ==1

gen game_optimal_invest_r9_10 = 0
replace game_optimal_invest_r10 =1  if game_opt_invest_g1r10 ==1 & game_opt_invest_g2r10 ==1 & game_opt_invest_g1r9 ==1 & game_opt_invest_g2r9 ==1

gen game_optimal_invest_r8_10 = 0
replace game_optimal_invest_r10 =1  if game_opt_invest_g1r10 ==1 & game_opt_invest_g2r10 ==1 & game_opt_invest_g1r9 ==1 & game_opt_invest_g2r9 ==1 & game_opt_invest_g1r8 ==1 & game_opt_invest_g2r8 ==1

label var game_optimal_invest_r8_10 "Both groups invested optimally in last three rounds"
label var game_optimal_invest_r9_10 "Both groups invested optimally in last two rounds"
label var game_optimal_invest_r10 "Both groups invested optimally in last round"

********************************************************************************
*GENERATE DUMMY VARIABLE THAT INDICATE THE ALMOST OPTIMAL SUCCESS OF THE VILLAGES DURING THE GAME
********************************************************************************
* gradual optimal investment indicator
*optimal investment => 16000 --> 100%
gen game_opt_invest_cat =.
replace game_opt_invest_cat = 1 if  group_inv >= 160 
replace game_opt_invest_cat = 2 if  group_inv >= 3200 
replace game_opt_invest_cat = 3 if  group_inv >= 6400 
replace game_opt_invest_cat = 4 if  group_inv >= 9600 
replace game_opt_invest_cat = 5 if  group_inv >= 12800 
replace game_opt_invest_cat = 6 if  group_inv >= 16000 

label define invest_cat 1 "invested 0-20%" 2 "invested 20-40%" 3 "invested 40-60%" 4 "invested 60-80%" 5 "invested 80-100%" 6 "invested 100%", replace
label values game_opt_invest_cat invest_cat
tab game_opt_invest_cat

*Did group 1 and 2 invested almost optimally in the 8th round
gen game_opt_invest_cat_g1r8 = .
foreach num of numlist 1/60 { 
	foreach r of numlist 1/10 {
		foreach g of numlist 1, 2 {
			display as text "##############################"
			display as text "round `r' site `num'  "
			summarize game_opt_invest_cat if site_ID == `num' & round==8 & group_b == 1 
			scalar m1 = r(max)
			replace game_opt_invest_cat_g1r8 = m1 if site_ID == `num' & round == `r' & group_b == `g' 
					}		
				}	
			}
gen game_opt_invest_cat_g2r8 = .
foreach num of numlist 1/60 { 
 foreach g of numlist 1, 2 {
	foreach r of numlist 1/10 {
			display as text "round `r' site `num' group_no_com `g' "
			summarize game_opt_invest_cat if site_ID == `num' & round==8 & group_b == 2 
			scalar m1 = r(max)
			replace game_opt_invest_cat_g2r8 = m1 if site_ID == `num' & round == `r' & group_b == `g' 
					}		
				}	
			}
*Did group 1 and 2 invested almost optimally in the 9th round
gen game_opt_invest_cat_g1r9 = .
foreach num of numlist 1/60 { 
	foreach r of numlist 1/10 {
		foreach g of numlist 1, 2 {
			display as text "###########################"
			display as text "round `r' site `num'  "
			summarize game_opt_invest_cat if site_ID == `num' & round==9 & group_b == 1 
			scalar m1 = r(max)
			replace game_opt_invest_cat_g1r9 = m1 if site_ID == `num' & round == `r' & group_b == `g' 
					}		
				}	
			}
gen game_opt_invest_cat_g2r9 = .
foreach num of numlist 1/60 { 
 foreach g of numlist 1, 2 {
	foreach r of numlist 1/10 {
			display as text "round `r' site `num' group_no_com `g' "
			summarize game_opt_invest_cat if site_ID == `num' & round==9 & group_b == 2 
			scalar m1 = r(max)
			replace game_opt_invest_cat_g2r9 = m1 if site_ID == `num' & round == `r' & group_b == `g' 
					}		
				}	
			}
			
*Did group 1 and 2 invested almost optimally in the 10th round
gen game_opt_invest_cat_g1r10 = .
foreach num of numlist 1/60 { 
	foreach r of numlist 1/10 {
		foreach g of numlist 1, 2 {
			display as text "###############################"
			display as text "round `r' site `num'  "
			summarize game_opt_invest_cat if site_ID == `num' & round==10 & group_b == 1 
			scalar m1 = r(max)
			replace game_opt_invest_cat_g1r10 = m1 if site_ID == `num' & round == `r' & group_b == `g' 
					}		
				}	
			}
gen game_opt_invest_cat_g2r10 = .
foreach num of numlist 1/60 { 
 foreach g of numlist 1, 2 {
	foreach r of numlist 1/10 {
			display as text "round `r' site `num' group_no_com `g' "
			summarize game_opt_invest_cat if site_ID == `num' & round==10 & group_b == 2 
			scalar m1 = r(max)
			replace game_opt_invest_cat_g2r10 = m1 if site_ID == `num' & round == `r' & group_b == `g' 
					}		
				}	
			}
***********************
gen game_almost_opt_invest_r10 = 0
replace game_almost_opt_invest_r10 =1  if game_opt_invest_cat_g2r10 >=5 & game_opt_invest_cat_g2r10 >=5 

gen game_almost_opt_invest_r9_10 = 0
replace game_almost_opt_invest_r9_10 =1  if game_opt_invest_cat_g2r10 >=5 & game_opt_invest_cat_g2r10 >=5 & game_opt_invest_cat_g2r9 >=5 & game_opt_invest_cat_g2r9 >=5 

gen game_almost_opt_invest_r8_10 = 0
replace game_almost_opt_invest_r9_10 =1  if game_opt_invest_cat_g2r10 >=5 & game_opt_invest_cat_g2r10 >=5 & game_opt_invest_cat_g2r9 >=5 & game_opt_invest_cat_g2r9 >=5  & game_opt_invest_cat_g2r8 >=5 & game_opt_invest_cat_g2r8 >=5 

label var game_almost_opt_invest_r10 		"Both groups invested about 80-100 % in last three rounds"
label var game_almost_opt_invest_r9_10 	"Both groups invested about 80-100 % in last two rounds"
label var game_almost_opt_invest_r8_10 	"Both groups invested about 80-100 %  in last round"

save "$working_ANALYSIS/data/zwischenergebniss_test_leader", replace 

********************************************************************************
*GENERATE VARIABLES THAT INDICATE HOW COOPERATIVELY THE LEADER PLAYED
********************************************************************************
use "$working_ANALYSIS/data/zwischenergebniss_test_leader", clear 

/*gen invested_optimally =.
replace invested_optimally = 1 if  investment>=2300
replace invested_optimally = 0 if  investment<2300
label var invested_optimally "Player invested optimally in round"

gen leader_invested_optimally =.
replace leader_invested_optimally = 1 if  investment>=2300 & elected_leader ==1
replace leader_invested_optimally = 0 if  investment<2300 & elected_leader ==1
label var leader_invested_optimally "Leader invested optimally in round"
*/

*Group investment of 16 ,000 needed to water 7ha gram ---> players need to invest at least 2.256 --> use 2.3000 as threshold
gen leader_opt_r8 =.
replace leader_opt_r8 = 1 if elected_leader ==1 & investment>=2300  & round ==8
replace leader_opt_r8 = 0 if elected_leader ==1 & investment<2300  & round ==8
gen leader_opt_r9 =.
replace leader_opt_r9 = 1 if elected_leader ==1 & investment>=2300  & round ==9
replace leader_opt_r9 = 0 if elected_leader ==1 & investment<2300  & round ==9
gen leader_opt_r10 =.
replace leader_opt_r10 = 1 if elected_leader ==1 & investment>=2300 & round ==10
replace leader_opt_r10 = 0 if elected_leader ==1 & investment<2300  & round ==10

bysort playerid: egen leader_invested_optimally_r8 = sum(leader_opt_r8)
replace leader_invested_optimally_r8 =. if elected_leader==0
bysort playerid: egen leader_invested_optimally_r9 = sum(leader_opt_r9)
replace leader_invested_optimally_r9 =. if elected_leader==0
bysort playerid: egen leader_invested_optimally_r10 = sum(leader_opt_r10)
replace leader_invested_optimally_r10 =. if elected_leader==0

gen leader_opt_r9_10 = 0
replace leader_opt_r9_10 = 1 if leader_invested_optimally_r10 ==1 & leader_invested_optimally_r9 ==1 
replace leader_opt_r9_10 = . if elected_leader==0
gen leader_opt_r8_10 = 0
replace leader_opt_r8_10 = 1 if leader_invested_optimally_r10 ==1 & leader_invested_optimally_r9 ==1  & leader_invested_optimally_r8 ==1 
replace leader_opt_r8_10 = . if elected_leader==0

sort site_ID round playerid 
bysort site_ID round: egen sum_lead_opt_r9_10 = sum (leader_opt_r9_10) 
bysort site_ID round: egen sum_lead_opt_r8_10 = sum (leader_opt_r8_10) 
label var sum_lead_opt_r9_10 "Number of leaders in village that played optimally in rounds 9-10 based on all players"
label var sum_lead_opt_r8_10 "Number of leaders in village that played optimally in round 8-10 based on all players"

gen share_lead_opt_r9_10 =  sum_lead_opt_r9_10/14
gen share_lead_opt_r8_10 =  sum_lead_opt_r8_10/14
label var share_lead_opt_r9_10 "Share of no leaders in village that played optimally in round 9-10 based on all players"
label var share_lead_opt_r8_10 "Share of no leaders in village that played optimally in round 8-10 based on all players"


*##############################
* Clean Game level data such that we only have data at the village level and can merge it with the endline and baseline data
*##############################

*rename *_female *_fem
*rename *_females *_fem
*rename *_female_* *_fem_*
*rename *_females_* *_fem_*
*rename *_primary_* *_prim_*
* rename *_secondary_* *_sec_*
rename *_invest_* *_inv_*
rename *_invest *_inv

keep  site_game site_census  round play_no site_ID payment_announcement census_no_hh census_population_total census_population_males census_population_fem census_caste_total census_caste_males census_caste_fem census_tribes_total census_tribes_males census_tribes_fem census_gov_school_prim census_priv_school_prim census_gov_school_middle census_priv_school_middle census_gov_school_sec census_priv_school_sec payment_form  sample_vill sum_uni_degree_village share_uni_degree_village sum_illiterate_village share_illiterate_village vill_males vill_fem  share_fem_village vill_elected_leader_sum leader_present_vill sum_leader_no sum_leader_state sum_leader_CR sum_leader_SHG sum_leader_culturestate share_leader_vill share_leader_state_vill share_leader_CR_vill share_leader_SHG_vill share_leader_culture_vill come_back_dummy overall_earning_village damforfarming av_inv_vill_R1_5 av_inv_vill_R6_10 av_inv_vill_R1_10 cont_money_vill cont_lab_vill reci_wat_vill dist_field_vill vill_argue vill_reject_rule vill_agree_rule vill_propose_rule vill_praises vill_complains vill_punish vill_reward vill_unconnected  vill_total_gamerelated vill_total_all    leader_fem_vill no_leader_fem_vill leader_male_vill no_leader_male_vill edu_fem_illit_vill edu_male_illit_vill    edu_fem_prim_vill edu_fem_sec_vill edu_fem_uni_vill  edu_male_prim_vill edu_male_sec_vill edu_male_uni_vill date_intervention count_intervention Facilitationteam   date_count game_lead_facil game_with_Radha game_total_opt_inv game_opt_inv_r8 game_opt_inv_r9 game_opt_inv_r10 game_optimal_inv_r10 game_optimal_inv_r9_10 game_optimal_inv_r8_10 game_almost_opt_inv_r10 game_almost_opt_inv_r9_10 game_almost_opt_inv_r8_10  come_back Village original_sample Sample_variable Excluded_sites game_played FES_site payment_form_2 No_HH Shar_SCST Shar_Lit share_lead_opt_r9_10 share_lead_opt_r8_10 sum_lead_opt_r9_10 sum_lead_opt_r8_10

drop if round >1
drop if play_no >1
drop round play_no

*----------------------------------------------------------
*Get missing labels
*----------------------------------------------------------
label var av_inv_vill_R1_5  "Average investments of village in first game phase"
label var av_inv_vill_R6_10  "Average investments of village in second game phase"
label var av_inv_vill_R1_10 "Average investments of village over the entire game"
label var  game_total_opt_inv "Count of optimal invested rounds (max20)"
*----------------------------------------------------------
* Get proper naming convention
*----------------------------------------------------------
rename game_* *_
rename * game_*
rename game_census_* census_*
rename game_site_ID site_ID

save "$working_ANALYSIS/data/2022_06_Mandla_Game_village_long", replace


*##############################
* GET VILLAGE SURVEY DATA
*##############################

*----------------- GET BASELINE DATA -----------------
clear

import excel "$working_ANALYSIS/data/MP_suvey_data_short.xlsx", sheet ("Baseline_MP") firstrow

rename CommunityName site
*drop strange observations
drop if SrNo == .
drop if SrNo == 109 // Two villages Ramhepur. The one with Comm_ID is 243 is the right observation
drop if SrNo == 56  // There aretwo different villages with same name. Jhulup (Near to Bichiya): This is a sample village. ID 26 Jhulup (Near to Mocha comes in Balaghat district) ID 208. This is not in our sample, But data was collected during the baseline by Chandrahas.
drop if SrNo == 75  // There aretwo different villages with same name Batwar. The correct one is the one with the Comm_ID 7. 
rename Comm_ID  site_ID

rename site BS_site
rename SrNo BS_SrNo
save "$working_ANALYSIS/data/2023_03_Survey_Baseline", replace

use "$working_ANALYSIS/data/2022_09_identifier_included_excluded", clear //    not matched (21)
merge m:1 site_ID using "$working_ANALYSIS/data/2023_03_Survey_Baseline"
drop if _merge ==2
drop _merge

save "$working_ANALYSIS/data/2023_03_Survey_Baseline", replace

*----------------------------------------------------------
use  "$working_ANALYSIS/data/2022_09_identifier_included_excluded", clear 
merge m:1 site_ID using   "$working_ANALYSIS/data/2023_03_Survey_Baseline"
drop if _merge ==2
drop _merge

global vars "Village original_sample Sample_variable Excluded_sites game_played FES_site payment_form No_HH Shar_SCST Shar_Lit"
foreach v of global vars {
	rename `v' `v'_BS
	}
	
save "$working_ANALYSIS/data/2023_03_Survey_Baseline", replace


*----------------- GET ENDLINE DATA -----------------
clear
import excel "$working_ANALYSIS/data/MP_suvey_data_short", sheet ("Endline_MP") firstrow
rename CommuityName site
rename Comm_id Comm_ID
*drop strange observations
drop if SrNo == .
rename  Comm_ID site_ID

rename Date FS_date
rename site FS_site
rename Interviewer FS_Interviewer
rename SrNo FS_SrNo

drop AI

sort site_ID site
tab site if site_ID ==.

save "$working_ANALYSIS/data/2023_03_Survey_Endline", replace

*----------------------------------------------------------
use "$working_ANALYSIS/data/2022_09_identifier_included_excluded", clear 
merge m:1 site_ID using "$working_ANALYSIS/data/2023_03_Survey_Endline"
drop if _merge ==2
drop _merge

global vars "Village original_sample Sample_variable Excluded_sites game_played FES_site payment_form No_HH Shar_SCST Shar_Lit"
foreach v of global vars {
	rename `v' `v'_FS
	}

save "$working_ANALYSIS/data/2023_03_Survey_Endline", replace



*#########################################
*----------------- MERGE BASELINE AND ENDLINE DATA -----------------
use "$working_ANALYSIS/data/2023_03_Survey_Baseline", clear
merge m:1 site_ID using "$working_ANALYSIS/data/2023_03_Survey_Endline" // Simariya Urf Rampur F.V. is in using only and indicated as control village. But there are no survey results?

drop _merge
* site Aouri Mal only in Baseline not in Endline

*1. Clean village names / IDs (based on Mail from Duche 30.09.2021). Spelling mistakes were ignored. Only corrected the wrong site id. 
* Village IDs 236 and 242 are mixed existing and newly coded data
*Existing 236 = Urdali mal
*Existing 242 = Urdali
replace site_ID = 242 if BS_site =="Urdali "
replace site_ID = 236 if BS_site =="Urdali Mal."

*-----------------------------------------------------´
* CREATE BASELINE LABELS & Change naming conventions
drop BS_SrNo
rename BS_site siteBS_BS

*Interview Partner
rename BS_DS_Village_panchayat_leader survey_interview_lead_BS
label var survey_interview_lead_BS "BS: Interview partner =Village leader/Panchayat"
rename BS_DS_Far_damuser survey_interview_farmerdam_BS
label var survey_interview_farmerdam_BS "BS: Interview partner = Farmer/Dam user"

* 1.	Has your stop dam received any maintenance within the last 12 month?
rename BS_DS_Maint_12m_ 	survey_maint_12m_BS
label var survey_maint_12m_BS "BS: Dam received any maintenance within the last 12 month"

*1.1 Has your stop dam received any maintenance within the last 12 month only by the village community?
rename BS_VD_Commu_cont_1y2 	survey_maint_com_BS
label var survey_maint_com_BS "BS: Dam received any maintenance within the last 12 month by community"

* 5.	Are there any rules related to the maintenance of the dam? Please describe them as detailed as possible.
rename BS_DS_Rules_maint_ survey_rules_maint_all_BS
label var survey_rules_maint_all_BS "BS: There are rules by the community for dam maintenance?"
rename BS_DS_Rule_maint_ survey_rules_maint_BS
label var survey_rules_maint_BS "BS: There are dam maintenance rules"

* Have there been any conflicts around the dam within the last 5 years
rename BS_VD_Confl_dam survey_conflicts_any_BS
label var survey_conflicts_any_BS "BS: Any conflicts around the dam within the last 5 years"
rename BS_VD_Resource_dist survey_conflict_alloc_BS
label var survey_conflict_alloc_BS "BS: Conflicts on resource distribution"
rename BS_VD_Confl_maint survey_conflict_maint_BS
label var survey_conflict_maint_BS "BS: Conflicts on maintenance"
rename BS_VD_Confl_oper survey_conflict_oper_BS
label var survey_conflict_oper_BS "BS: Conflicts on operation"

*7.	Please list all types of benefits anybody enjoys related to the dam!
*rename BS_DS_Dam_benefit_agri_ survey_benefit_agri_BS
*label var survey_benefit_agri_BS"BS: There are agricultural benefits related to dam"
rename BS_DS_Dam_benefit_domuse_ survey_benefit_domuse_BS
label var survey_benefit_domuse_BS "BS: There are domestic use benefits related to dam" 
rename BS_DS_Dam_benefit_livestock_ survey_benefit_livestock_BS
label var survey_benefit_livestock_BS "BS: There are livestock benefits related to dam"
rename BS_DS_Dam_benefit_fish_ survey_benefit_fish_BS
label var survey_benefit_fish_BS "BS: There are fishing benefits related to dam" 
rename BS_DS_Dam_benefit_other_ survey_benefit_other_BS
label var survey_benefit_other_BS "BS: There are other benefits related to dam"

* Which question ?
rename BS_DS_Pote_irri survey_dam_for_irrigation_BS
label var survey_dam_for_irrigation_BS "BS:Dam is used for irrigation"

*9.	Are there any rules related to the water extraction? Please describe them!
rename BS_DS_Rule_extr_maint_ survey_rules_extr_maint_BS
label var survey_rules_extr_maint_BS "BS: There are maintenance rules/practices for water etxraction"

*11.	Rating
rename BS_DS_Cap_red_silt_ survey_rating_silt_BS
label var survey_rating_silt_BS "BS: Rating reduced dam capacity due to siltation"
rename BS_DS_Cap_red_veget survey_rating_vege_BS
label var survey_rating_vege_BS "BS: Rating reduced dam capacity due to vegetation" 
rename BS_DS_Earthwall_ survey_rating_earthwall_BS
label var survey_rating_earthwall_BS "BS: Rating on dams earthwall condition"
rename BS_DS_Mainwall_ survey_rating_mainwall_BS
label var survey_rating_mainwall_BS "BS: Rating on dams mainwall condition"
rename BS_DS_Sluicegate_ survey_rating_sluicegate_BS
label var survey_rating_sluicegate_BS "BS: Rating on dams sluicegate condition"
rename BS_DS_Feeder_channel_ survey_rating_feederch_BS
label var survey_rating_feederch_BS "BS: Rating on dams feeder channel condition"

*---------------------------------------------------------------------------------------------------------------------------------------
* CREATE ENDLINE LABELS
drop FS_SrNo FS_Interviewer FS_date
rename FS_site siteFS_FS

*Interview Partner
rename FS_DS_Village_panchayat_leader survey_interview_lead_FS
label var survey_interview_lead_FS "FS: Interview partner =Village leader/Panchayat"
rename FS_DS_Far_damuser survey_interview_farmerdam_FS
label var survey_interview_farmerdam_FS "FS: Interview partner = Farmer/Dam user"

* Has your stop dam received any maintenance after March 2017?	
rename FS_DS_Maint_2017_ 	survey_maint_2017_FS
label var survey_maint_2017_FS "FS: Dam received any maintenance since 2017?"

*1.1 Has your stop dam received any maintenance within the last 12 month only by the village community?
rename FS_VD_FS_Commu_cont 	survey_maint_com_FS
label var survey_maint_com_FS "FS: Dam received any maintenance by community since 2017"

* Are there any rules prepared by the community members related to maintenance of dam?
rename FS_DS_Rules_maint_ survey_rules_maint_all_FS
label var survey_rules_maint_all_FS "FS: There are rules by the community for dam maintenance?"
rename FS_DS_Rule_maint_ survey_rules_maint_FS
label var survey_rules_maint_FS "FS: There are dam maintenance rules"
rename FS_DS_Rule_extr_maint_ survey_rules_extr_maint_FS
label var survey_rules_extr_maint_FS "FS: There are maintenance rules/practices for water etxraction"

* Conflicts around the dam within the last 5 years
rename FS_VD_Resource_dist survey_conflict_alloc_FS
label var survey_conflict_alloc_FS "FS: Conflicts on resource distribution"
rename FS_VD_Confl_maint survey_conflict_maint_FS
label var survey_conflict_maint_FS "FS: Conflicts on maintenance"
rename FS_VD_Confl_oper survey_conflict_oper_FS
label var survey_conflict_oper_FS "FS: Conflicts on operation"
rename FS_VD_Confl_oth survey_conflicts_other_FS
label var survey_conflicts_other_FS "FS: Conflicts on operation"

*Please list all types of benefits anybody enjoys related to the dam! 
rename FS_DS_Dam_benefit_agri_ survey_benefit_agri_FS
label var survey_benefit_agri_FS "FS: There are agricultural benefits related to dam"
rename FS_DS_Dam_benefit_domuse_ survey_benefit_domuse_FS
label var survey_benefit_domuse_FS "FS: There are domestic use benefits related to dam" 
rename FS_DS_Dam_benefit_livestock_ survey_benefit_livestock_FS
label var survey_benefit_livestock_FS "FS: There are livestock benefits related to dam"
rename FS_DS_Dam_benefit_fish_ survey_benefit_fish_FS
label var survey_benefit_fish_FS "FS: There are fishing benefits related to dam" 
rename FS_DS_Dam_benefit_other_ survey_benefit_other_FS
label var survey_benefit_other_FS "FS: There are other benefits related to dam"

*If the dam is not used for irrigation, could it potentially be used for irrigation
rename FS_DS_Pote_irri survey_dam_for_irrigation_FS
label var survey_dam_for_irrigation_FS "FS: Dam is used for irrigation"

*Rating
rename FS_DS_Cap_red_silt_ survey_rating_silt_FS
label var survey_rating_silt_FS "FS: Rating reduced dam capacity due to siltation"
rename FS_DS_Cap_red_veget survey_rating_vege_FS
label var survey_rating_vege_FS "FS: Rating reduced dam capacity due to vegetation" 
rename FS_DS_Earthwall_ survey_rating_earthwall_FS
label var survey_rating_earthwall_FS "FS: Rating on dams earthwall condition"
rename FS_DS_Mainwall_ survey_rating_mainwall_FS
label var survey_rating_mainwall_FS "FS: Rating on dams mainwall condition"
rename FS_DS_Sluicegate_ survey_rating_sluicegate_FS
label var survey_rating_sluicegate_FS "FS: Rating on dams sluicegate condition"
rename FS_DS_Feeder_channel_ survey_rating_feederch_FS
label var survey_rating_feederch_FS "FS: Rating on dams feeder channel condition"

*Game Played in the village?	
rename FS_DS__Game_Ply_ survey_game_played_FS
label var survey_game_played_FS "FS: The game was played in the village"

*Community members participated in the game discussed or share experience of the game with other community members/ in meeting/ in village council meeting?	
rename FS_DS_Par_shar_exp_inf_family survey_share_exp_family_FS
label var survey_share_exp_family_FS "FS: Game discussed with family"
rename FS_DS_Par_shar_exp_friends_ survey_share_exp_friends_FS
label var survey_share_exp_friends_FS "FS: Game discussed with friends"
rename FS_DS_Par_shar_exp_Comm_meet survey_share_exp_comm_meet_FS
label var survey_share_exp_comm_meet_FS "FS: Game discussed in community meeting"
rename FS_DS_Par_shar_exp_VC_meet survey_share_exp_vc_meet_FS
label var survey_share_exp_vc_meet_FS "FS: Game discussed with Panchayat"
rename FS_Par_shar_exp_oth_mem_ survey_share_exp_others_FS
label var survey_share_exp_others_FS "FS: Game discussed with other members"

save "$working_ANALYSIS/data/2023_03_Survey_Wide", replace

**********************************************
* Append Census Data
use "$working_ANALYSIS/data/2023_03_Survey_Wide", clear
merge 1:1 site_ID using "$working_ANALYSIS/data/2022_06_Mandla_Census"

*keep for now only the game village observations of the census and not the observations of the control villages 
tab siteBS_BS if _merge ==1 // Bagaspur, Danitola, Mohgaon Mal & Mohgaon Ryt no census data available
tab site_census if _merge ==2 
drop if _merge ==2
drop _merge

drop site_census payment_lump_individ type  payment_announcement
save "$working_ANALYSIS/data/2023_03_Survey_Wide", replace

*#############################################################
* --------------------------- CHANGE SURVEY DATA FROM WIDE TO LONG FORMAT  ---------------------------
*#############################################################

use  "$working_ANALYSIS/data/2023_03_Survey_Wide", clear

drop if site_ID ==.
order *, alphabetic
destring survey_interview_lead_BS, replace

global  vars_census "census_no_hh census_population_total census_population_males census_population_fem census_caste_total census_caste_males census_caste_fem census_tribes_total census_tribes_males census_tribes_fem census_gov_school_prim census_priv_school_prim census_gov_school_middle census_priv_school_middle census_gov_school_sec census_priv_school_sec"

foreach v of global vars_census {
	rename `v' `v'_BS
	}

reshape long Excluded_sites_ FES_site_ Sample_variable_ Village_ census_caste_fem_ census_caste_males_ census_caste_total_ census_gov_school_middle_ census_gov_school_prim_ census_gov_school_sec_ census_no_hh_ census_population_fem_ census_population_males_ census_population_total_ census_priv_school_middle_ census_priv_school_prim_ census_priv_school_sec_ census_tribes_fem_ census_tribes_males_ census_tribes_total_ game_played_ original_sample_ payment_form_   survey_CWRgroup_already_ survey_CWRgroup_new_ survey_activity_any_ survey_activity_earthwall_ survey_activity_mainwall_ survey_activity_silt_ survey_activity_sluicegate_ survey_activity_vege_ survey_benefit_agri_ survey_benefit_domuse_ survey_benefit_fish_ survey_benefit_livestock_ survey_benefit_other_ survey_change_benefit_ survey_collact_new_ survey_compay_community_ survey_compay_equal_ survey_compay_leader_ survey_compay_otheruser_ survey_cwr_bori_ survey_cwr_dam_ survey_cwr_other_ survey_cwr_pond_ survey_dam_for_irrigation_ survey_game_played_ survey_indipay_comm_ survey_indipay_equally_ survey_indipay_other_ survey_indipayn_notspent_ survey_interview_farmerdam_ survey_interview_lead_ survey_interview_others_ survey_interview_waterua_ survey_maint_12m_ survey_maint_2017_ survey_rating_earthwall_ survey_rating_feederch_ survey_rating_mainwall_ survey_rating_silt_ survey_rating_sluicegate_ survey_rating_vege_ survey_rules_alloc_ survey_rules_extr_alloc_ survey_rules_extr_maint_ survey_rules_extr_opre_ survey_rules_extr_other_ survey_rules_maint_ survey_rules_maint_all_ survey_rules_old_all_ survey_rules_old_alloc_ survey_rules_old_maint_ survey_rules_old_oper_ survey_rules_old_other_ survey_rules_oper_ survey_rules_other_ survey_share_exp_comm_meet_ survey_share_exp_family_ survey_share_exp_friends_ survey_share_exp_others_ survey_share_exp_vc_meet_ Shar_Lit_ Shar_SCST_ No_HH_  survey_maint_com_ survey_conflict_alloc_ survey_conflict_maint_ survey_conflict_oper_ survey_conflicts_other_ survey_conflicts_any_ , i(site_ID) j(BS_FS) string

tab BS_FS

order *, alphabetic


*-------------------------------------------------------------------------------------------------
*Label variables 
label var BS_FS "Survey identifier. BS = Baseline, FS = Endline"
*Both for FS & BS
label var survey_activity_silt_ "BS&FS: Dam maintenance activities: Remove silt"
label var survey_activity_vege_ "BS&FS: Dam maintenance activities: Remove vegetation"
label var survey_activity_sluicegate_ "BS&FS: Dam maintenance activities: Sluicegate repair"
label var survey_activity_earthwall_ "BS&FS: Dam maintenance activities: Repair earthwall"
label var survey_activity_mainwall_ "BS&FS: Dam maintenance activities: Mainwall repair"
label var survey_activity_any_ "BS&FS:  Conducted dam maintenance activity: Any repair"

label var survey_interview_lead_ "BS&FS: Interview partner =Village leader/Panchayat"
label var survey_interview_farmerdam_ "BS&FS: Interview partner = Farmer/Dam user"
label var survey_interview_waterua_ "BS&FS: Interview partner = Water Association Member"
label var survey_interview_others_ "BS&FS: Interview partner = Water Association Member"

label var survey_rules_extr_alloc_ "BS&FS: There are allocation rules/practices for water etxraction"
label var survey_rules_extr_maint_ "BS&FS: There are maintenance rules/practices for water etxraction"
label var survey_rules_extr_opre_ "BS&FS: There are operational rules/practices for water etxraction"
label var survey_rules_extr_other_ "BS&FS: There are other rules/practices for water etxraction"

label var survey_rules_maint_all_ "There are rules by the community for dam maintenance?"
label var survey_rules_maint_ "BS&FS: There are dam maintenance rules"
label var survey_rules_alloc_ "BS&FS: There are resource allocation rules"
label var survey_rules_oper_ "BS&FS: There are operational rules"
label var survey_rules_other_ "BS&FS: There are other rules"

label var survey_benefit_agri_ "BS&FS: There are agricultural benefits related to dam"
label var survey_benefit_domuse_ "BS&FS: There are domestic use benefits related to dam" 
label var survey_benefit_livestock_ "BS&FS: There are livestock benefits related to dam"
label var survey_benefit_fish_ "BS&FS: There are fishing benefits related to dam" 
label var survey_benefit_other_ "BS&FS: There are other benefits related to dam"

label var survey_conflict_maint_ "BS&FS: There were maintenance conflicts around the dam"
label var survey_conflict_alloc_ "BS&FS: There were allocation conflicts around the dam" 
label var survey_conflict_oper_ "BS&FS: There were operational conflicts around the dam"
label var survey_conflicts_other_ "FS: There were other conflicts around the dam"
label var survey_conflicts_any_ "BS: There were any conflicts around the dam"

label var survey_rating_silt_ "BS&FS: Rating reduced dam capacity due to siltation"
label var survey_rating_vege_ "BS&FS: Rating reduced dam capacity due to vegetation" 
label var survey_rating_earthwall_ "BS&FS: Rating on dams earthwall condition"
label var survey_rating_mainwall_ "BS&FS: Rating on dams mainwall condition"
label var survey_rating_sluicegate_ "BS&FS: Rating on dams sluicegate condition"
label var survey_rating_feederch_ "BS&FS: Rating on dams feeder channel condition"
label var survey_dam_for_irrigation_ "BS&FS: Dam is used for irrigation"

*Both in FS & BS but with slight differences
label var survey_maint_2017_ "FS: Dam received any maintenance since 2017?"
label var survey_maint_12m_ "BS: Dam received any maintenance in last year?"
label var survey_maint_com_ "BS & FS: Community maintained dam"


*Only BS survey 
label var survey_rules_old_all_ "BS: Remember old community rules for dam management?"
label var survey_rules_old_maint_ "BS: Remember old community rules for dam maintenance"
label var survey_rules_old_alloc_ "BS: Remember old community rules for dam allocation"
label var survey_rules_old_oper_ "BS: Remember old community rules for dam operation"
label var survey_rules_old_other_ "BS: Remember old community rules for other dam issues"

*Only in FS survey
label var survey_cwr_dam_ "FS: Community has stop dam"
label var survey_cwr_pond_ "FS: Community has pond"
label var survey_cwr_bori_ "FS: Community has bori bonds"
label var survey_cwr_other_ "FS: Community has other common water resources"
label var survey_game_played_ "FS: The game was played in the village"
label var survey_change_benefit_ "FS: Change in  community regarding shared benefit from the cwr after the game"
label var survey_collact_new_ "FS: Community met for collective action after game played"
label var survey_share_exp_family_ "FS: Game discussed with family"
label var survey_share_exp_friends_ "FS: Game discussed with friends"
label var survey_share_exp_comm_meet_ "FS: Game discussed in community meeting"
label var survey_share_exp_vc_meet_ "FS: Game discussed with Panchayat"
label var survey_share_exp_others_ "FS: Game discussed with other members"
label var survey_CWRgroup_new_ "FS: After game new group to take care of water resources?"
label var survey_CWRgroup_already_ "FS: Was there a crw group before? "
label var survey_indipay_equally_ "FS: individual money from game equally distr"
label var survey_indipay_comm_ "FS: individual money from game used for common work"
label var survey_indipayn_notspent_ "FS: individual money from game not spend"
label var survey_indipay_other_ "FS: individual money from game used for other purposes"
label var survey_compay_equal_ "FS: lump sum payment from game equally distr"
label var survey_compay_community_ "FS: lump sum payment from game used for common work"
label var survey_compay_leader_ "FS: lump sum payment from game not spend"
label var survey_compay_otheruser_ "FS: lump sum payment from game used for other purposes"

*Census data
rename census_*_ census_*
label var census_no_hh "Census: Total households in village"
label var census_population_total "Census: Total population in village"
label var census_population_males   "Census: Total male in village"
label var census_population_fem "Census: Total female in village"
label var census_caste_total  "Census: Total scheduled castes population of village"
label var census_caste_males "Census: Total male scheduled castes population of village"
label var census_caste_fem "Census: Total female scheduled castes population of village"
label var census_tribes_total "Census: Total scheduled tribes population of village"
label var census_tribes_males  "Census: Total male scheduled tribes population of village"
label var census_tribes_fem  "Census: Total female scheduled tribes population of village"
label var census_gov_school_prim  "Census: Number of govt primary schools"
label var census_priv_school_prim "Census: Number of private primary schools"
label var census_gov_school_middle "Census: Number of govt middle schools"
label var census_priv_school_middle "Census: Number of private middle schools"
label var census_gov_school_sec "Census: Number of govt secondary schools"
label var census_priv_school_sec "Census: Number of private secondary schools"

save "$working_ANALYSIS/data/2023_03_Survey_Long", replace


*#############################################################
* ---------------------- MERGE SURVEY  AND GAME_VILLAGAE DATA IN LONG FORMAT ----------------------
*#############################################################
clear
use "$working_ANALYSIS/data/2022_06_Mandla_Game_village_long", clear
merge m:m site_ID using "$working_ANALYSIS/data/2023_03_Survey_Long"

*only for checking for correctness
 *keep site_ID game_Village game_original_sample game_Sample_variable game_Excluded_sites game_played_ game_FES_site game_payment_form_2 BS_FS Excluded_sites_ FES_site_ Sample_variable_ Village_ original_sample_ payment_form_ paymentform siteBS_BS siteFS_FS

drop game_original_sample game_Sample_variable game_Excluded_sites game_FES_site game_payment_form_2 game_site_census   siteBS_ siteFS_   _merge game_No_HH game_Shar_SCST game_Shar_Lit

* clean village names & ID's
rename game_site_game site_game
replace	 site_game = "Bhawartal"	if	site_ID == 201 	
replace	 site_game = "Malara"	if	site_ID == 202 
replace	 site_game = "Harrabhat Jar"	if	site_ID == 203 
replace	 site_game = "Patpara"	if	site_ID == 204 
replace	 site_game = "Aurai Mal.(Ourai Mal.)" if	site_ID == 205 
replace	 site_game = "Mohgaon Ryt." 	if	site_ID == 206 
replace	 site_game = "Bamhani Ryt."	if	site_ID == 207 	
replace	 site_game = "Mohgaon Mal." 	if	site_ID == 209 
replace	 site_game = "Saamp"  	if	site_ID == 210 
replace	 site_game = "Kariwah"	if	site_ID == 211 	
replace	 site_game = "Harrabhat Mal."	if	site_ID == 212 	
replace	 site_game = "Bhawan"	if	site_ID == 213 	
replace	 site_game = "Ratanpur Ryt." 	if	site_ID == 214  
replace	 site_game = "Vishanpura Ryt."	if	site_ID == 215 
replace	 site_game = "Chaunranga Mal."	if	site_ID == 216 
replace	 site_game = "Mohad" 	if	site_ID == 217 
replace	 site_game = "Navgawan (Naigawan)Ryt."	if	site_ID == 218 
replace	 site_game = "Barkheda Ryt." 	if	site_ID == 219 
replace	 site_game = "Barkheda"	if	site_ID == 220 
replace	 site_game = "Bhimpuri Ryt." 	if	site_ID == 221 
replace	 site_game = "Bhundelakhoh" 	if	site_ID == 222 
replace	 site_game = "Chauranga (Chakiya Tola)"	if	site_ID == 223 
replace	 site_game = "Dudhari"	if	site_ID == 224 
replace	 site_game = "Indra F.V."	if	site_ID == 225 
replace	 site_game = "Karanjia Mal."	if	site_ID == 226 
replace	 site_game = "Katanga Mal."	if	site_ID == 227 
replace	 site_game = "Katangi"	if	site_ID == 228 
replace	 site_game = "Khatola"	if	site_ID == 229 
replace	 site_game = "Khuluwa"	if	site_ID == 230 
replace	 site_game = "Lohta F.V."	if	site_ID == 231 
replace	 site_game = "Rajo Mal."	if	site_ID == 232 
replace	 site_game = "Surehala"	if	site_ID == 233 
replace	 site_game = "Umariya Mal."	if	site_ID == 234 
replace	 site_game = "Umarwada"	if	site_ID == 235 
replace	 site_game = "Urdali Ryt."	if site_ID == 236 
replace	 site_game = "Umardoh" 	if	site_ID == 238 
replace	 site_game = "Umariya (Zariya Puliyawala Nala)"	if	site_ID == 239 
replace	 site_game = "Umariya (Zariya Nala)"	if	site_ID == 240 
replace	 site_game = "Dungariya"	if	site_ID == 241 
replace	 site_game = "Urdali Mal." 	if	site_ID == 242 
replace	 site_game = "Ramhepur"	if	site_ID == 243 	
replace	 site_game = "Umariya" if	site_ID == 244 
replace	 site_game =  "Aurai Ryt.(Ourai Ryt.)" if	site_ID == 245 
replace	 site_game = "Birsa Mal."  if	site_ID == 247 
replace	 site_game = "Danitola"	if	site_ID == 248 
replace	 site_game = "Kata Jar"	if	site_ID == 249 
replace	 site_game = "Matawal Alias Danitola" if	site_ID == 250 
replace	 site_game =  "Niwsa" if	site_ID == 251 
replace	 site_game = "Ramnagar"	if	site_ID == 252 

*----------------------------------------------------
rename FES_site_  FES_site

rename BS_FS BS_FS_str 
gen BS_FS =.
replace BS_FS = 0 if BS_FS_str =="BS"
replace BS_FS = 1 if BS_FS_str =="FS"
drop  BS_FS_str
* for survey_*, the identifier BS_FS shows if it is a Baseline or Endline variable

*----------------------------------------------------
* Drop villages that should not be in analysis
rename Excluded_sites Excluded_sites_old
gen Excluded_sites =.
replace Excluded_sites = 1 if Excluded_sites_old =="excluded"
replace Excluded_sites = 0 if Excluded_sites_old =="not excluded"

drop if Excluded_sites ==1 // drops 48 and 252. We played the game in Nakawal (48)  but village was on control list. In 252,  after appointment we went to village but only a few people came.
drop if site_ID ==29  // Kanskheda with site_ID ==29 Game was played but not in sample. Thus drop
drop if site_ID == 34 // no water infrastructure in Kharpariya
drop if site_ID == 37 // Kuhskar is not in final sample
drop if site_ID == 218 // no water infrastructure  in Navgawan (Naigawan)Ryt.
drop if site_ID == 243 // baseline data are mostly blank, thus dropped Ramehepur
drop if site_ID == 254
drop if site_ID == 378

*-----------------------------------------------------------
* Generate variables for analysis
gen treatment  = 1 if Sample_variable ==1
replace treatment = 0 if Sample_variable ==2
lab var treatment "Identifier for villages where games were played."
lab def treated 0 "Control" 1 "Games", replace
lab val treatment treated

*Error: Village ID 201 is indicated as games village but is a control village*
replace treatment = 0 if site_ID == 201


*Generate variable on whether rules on maintenance existed
egen survey_maint_rule = rowmax (survey_rules_maint_  survey_rules_extr_maint_)
label var survey_maint_rule "Maintenance rule exist" 

* Games were discussed outside the workshop?
gen com_outside_game =.
replace  com_outside_game = 0 if survey_share_exp_others_==1
replace  com_outside_game = 0 if survey_share_exp_family_==1 
replace  com_outside_game = 1 if survey_share_exp_comm_meet_==1 
replace  com_outside_game = 1 if survey_share_exp_vc_meet_==1 
label var com_outside_game "=1 if games were discussed in formal or informal meetings in the village"
replace com_outside_game = 0 if site_ID==17 // replace missing values with median values, see mail Thomas

*----------------------------------------------------------------------
*Create share of females in village and census data (variables indicated with census_*)
gen census_pop_females_share = census_population_fem/census_population_total
gen census_caste_females_share = census_caste_fem/census_caste_total
gen census_tribes_females_share = census_tribes_fem/census_tribes_total
label var census_pop_females_share "Share of females in the village based on census data"
label var census_caste_females_share "Share of female scheduled castes population in the village based on census data"
label var census_tribes_females_share "Share of female scheduled tribes population in the village based on census data"

*Share of women and men in sessions
gen share_leader_female_vill = game_leader_fem_vill /14
gen share_no_leader_female_vill = game_no_leader_fem_vill /14 
gen share_leader_male_vill = game_leader_male_vill /14
gen share_no_leader_male_vill = game_no_leader_male_vill /14
label var share_leader_female_vill "Share of female leaders per session"
label var share_no_leader_female_vill "Share of women per session"
label var share_leader_male_vill "Share of male leaders per session"
label var share_no_leader_male_vill "Share of men per session"

*Share of women participating in games
gen share_female_percent = game_share_fem_vill*100
lab var share_female_percent "Share female participants in % including female leaders"

gen share_female_percent2 = share_no_leader_female_vill*100
lab var share_female_percent2 "Share female participants in %"

gen share_female_percent3 = share_no_leader_female_vill*10
lab var share_female_percent3 "Share female participants in 10%"


*leader composition in games
*dummy for male leader presence
gen male_leader_present = 0 if game_leader_male_vill==0
replace male_leader_present = 1 if game_leader_male_vill>0
replace male_leader_present = . if treatment==0

*dummy for female leader presence
gen female_leader_present= 0
replace female_leader_present = 1 if game_leader_fem_vill>0
replace female_leader_present = . if treatment==0

tab female_leader_present male_leader_present

*composition of leader presence
gen leader_present = 0 if male_leader_present==0 & female_leader_present==0
replace leader_present = 1 if male_leader_present == 1 & female_leader_present==0
replace leader_present = 2 if male_leader_present == 1 & female_leader_present==1
replace leader_present = 3 if male_leader_present == 0 & female_leader_present==1
replace leader_present = . if treatment==0
lab def leader_lab 0 "None" 1 "Only Male" 2 "Both" 3 "Only Female", replace
lab val leader_present leader_lab
tab leader_present, gen(leader_comp)


*Number of leaders present
egen total_leaders=rowtotal(game_leader_fem_vill game_leader_male_vill)


*----------------------------------------------------------
*recode shares to either dummies () or percent
*presence of illiterate participants
gen d_illiterate = 0 if game_share_illiterate_village ==0
replace d_illiterate = 1 if game_share_illiterate_village>0 & game_share_illiterate_village!=.

*share of leaders present in games
gen share_leader_percent = game_share_leader_vill*100
gen share_leader_opt_percent = game_share_lead_opt_r9_10*100
label var share_leader_opt_percent "Share of leaders present in games"

*replace missing values with median values // see mail Thomas
replace game_lead_facil = 0 if site_ID==13 // who was lead facilitator in Dhamangoan?
replace com_outside_game = 0 if site_ID==17
replace game_count_intervention = 26 if site_ID==13 // when were the games played in Dhamangoan?

* Replace missing census data (see Mail Duche 5.1.2022)
replace Shar_SCST = 100 if site_ID == 209
replace Shar_Lit = 54.2 if site_ID == 209
replace No_HH = 129 if site_ID == 209

* Replace missing fs data  (see Mail Thomas 5.1.22 - 17:02)
replace survey_maint_12m_ = 0 if site_ID == 32
replace survey_maint_2017_ = 0 if  site_ID == 203
replace survey_maint_2017_ = 0 if  site_ID == 216

save "$working_ANALYSIS/data/2023_03_Survey&Game_Long", replace

*##################################
*##################################
*##################################
*##################################
*##################################
*##################################
*##################################
*##################################
*##################################



*#############################################################
* ------------ TRANSFORM SURVEY&GAME_VILLAGE DATA FROM LONG TO WIDE FORMAT ------------
*#############################################################
use "$working_ANALYSIS/data/2023_03_Survey&Game_Long", clear
xtset site_ID BS_FS



rename game_vill_*  game_*
rename *_illiterate_* *_illit_*

*1.c. rename with _
global vars "site_ID game_Village game_played_ site_game game_come_back census_no_hh census_population_total census_population_males census_population_fem census_caste_total census_caste_males census_caste_fem census_tribes_total census_tribes_males census_tribes_fem census_gov_school_prim census_priv_school_prim census_gov_school_middle census_priv_school_middle census_gov_school_sec census_priv_school_sec game_payment_announcement game_sample_vill game_sum_uni_degree_village game_share_uni_degree_village game_sum_illit_village game_share_illit_village game_males game_fem game_share_fem_village game_elected_leader_sum game_leader_present_vill game_sum_leader_no game_sum_leader_state game_sum_leader_CR game_sum_leader_SHG game_sum_leader_culturestate game_share_leader_vill game_share_leader_state_vill game_share_leader_CR_vill game_share_leader_SHG_vill game_share_leader_culture_vill game_come_back_dummy game_overall_earning_village game_damforfarming game_av_inv_vill_R1_5 game_av_inv_vill_R6_10 game_av_inv_vill_R1_10 game_cont_money_vill game_cont_lab_vill game_reci_wat_vill game_dist_field_vill game_argue game_reject_rule game_agree_rule game_propose_rule game_praises game_complains game_punish game_reward game_unconnected game_total_gamerelated game_total_all game_leader_fem_vill game_no_leader_fem_vill game_leader_male_vill game_no_leader_male_vill game_edu_fem_illit_vill game_edu_fem_prim_vill game_edu_fem_sec_vill game_edu_fem_uni_vill game_edu_male_illit_vill game_edu_male_prim_vill game_edu_male_sec_vill game_edu_male_uni_vill game_date_intervention game_count_intervention game_Facilitationteam game_date_count game_lead_facil_ game_with_Radha_ game_total_opt_inv_ game_opt_inv_r8_ game_opt_inv_r9_ game_opt_inv_r10_ game_optimal_inv_r10_ game_optimal_inv_r9_10_ game_optimal_inv_r8_10_ game_almost_opt_inv_r10_ game_almost_opt_inv_r9_10_ game_almost_opt_inv_r8_10_ game_sum_lead_opt_r9_10 game_sum_lead_opt_r8_10 game_share_lead_opt_r9_10 game_share_lead_opt_r8_10 Excluded_sites_old FES_site No_HH_ Sample_variable_ Shar_Lit_ Shar_SCST_ Village_ original_sample_ payment_form_ paymentform survey_CWRgroup_already_ survey_CWRgroup_new_ survey_activity_any_ survey_activity_earthwall_ survey_activity_mainwall_ survey_activity_silt_ survey_activity_sluicegate_ survey_activity_vege_ survey_benefit_agri_ survey_benefit_domuse_ survey_benefit_fish_ survey_benefit_livestock_ survey_benefit_other_ survey_change_benefit_ survey_collact_new_ survey_compay_community_ survey_compay_equal_ survey_compay_leader_ survey_compay_otheruser_ survey_conflict_alloc_ survey_conflict_maint_ survey_conflict_oper_ survey_conflicts_any_ survey_conflicts_other_ survey_cwr_bori_ survey_cwr_dam_ survey_cwr_other_ survey_cwr_pond_ survey_dam_for_irrigation_ survey_game_played_ survey_indipay_comm_ survey_indipay_equally_ survey_indipay_other_ survey_indipayn_notspent_ survey_interview_farmerdam_ survey_interview_lead_ survey_interview_others_ survey_interview_waterua_ survey_maint_12m_ survey_maint_2017_ survey_maint_com_ survey_rating_earthwall_ survey_rating_feederch_ survey_rating_mainwall_ survey_rating_silt_ survey_rating_sluicegate_ survey_rating_vege_ survey_rules_alloc_ survey_rules_extr_alloc_ survey_rules_extr_maint_ survey_rules_extr_opre_ survey_rules_extr_other_ survey_rules_maint_ survey_rules_maint_all_ survey_rules_old_all_ survey_rules_old_alloc_ survey_rules_old_maint_ survey_rules_old_oper_ survey_rules_old_other_ survey_rules_oper_ survey_rules_other_ survey_share_exp_comm_meet_ survey_share_exp_family_ survey_share_exp_friends_ survey_share_exp_others_ survey_share_exp_vc_meet_ BS_FS Excluded_sites treatment survey_maint_rule com_outside_game census_pop_females_share census_caste_females_share census_tribes_females_share share_leader_female_vill share_no_leader_female_vill share_leader_male_vill share_no_leader_male_vill share_female_percent share_female_percent2 share_female_percent3 male_leader_present female_leader_present leader_present leader_comp1 leader_comp2 leader_comp3 leader_comp4  d_illiterate share_leader_percent share_leader_opt_percent"

foreach v of global vars {
	rename `v' `v'_
	}
rename *__ *_

*1.d RESHAPE
*variable BS_FS_ contains missing values
reshape wide  game_Village_ game_played_ site_game_ game_come_back_ census_no_hh_ census_population_total_ census_population_males_ census_population_fem_ census_caste_total_ census_caste_males_ census_caste_fem_ census_tribes_total_ census_tribes_males_ census_tribes_fem_ census_gov_school_prim_ census_priv_school_prim_ census_gov_school_middle_ census_priv_school_middle_ census_gov_school_sec_ census_priv_school_sec_ game_payment_announcement_ game_sample_vill_ game_sum_uni_degree_village_ game_share_uni_degree_village_ game_sum_illit_village_ game_share_illit_village_ game_males_ game_fem_ game_share_fem_village_ game_elected_leader_sum_ game_leader_present_vill_ game_sum_leader_no_ game_sum_leader_state_ game_sum_leader_CR_ game_sum_leader_SHG_ game_sum_leader_culturestate_ game_share_leader_vill_ game_share_leader_state_vill_ game_share_leader_CR_vill_ game_share_leader_SHG_vill_ game_share_leader_culture_vill_ game_come_back_dummy_ game_overall_earning_village_ game_damforfarming_ game_av_inv_vill_R1_5_ game_av_inv_vill_R6_10_ game_av_inv_vill_R1_10_ game_cont_money_vill_ game_cont_lab_vill_ game_reci_wat_vill_ game_dist_field_vill_ game_argue_ game_reject_rule_ game_agree_rule_ game_propose_rule_ game_praises_ game_complains_ game_punish_ game_reward_ game_unconnected_ game_total_gamerelated_ game_total_all_ game_leader_fem_vill_ game_no_leader_fem_vill_ game_leader_male_vill_ game_no_leader_male_vill_ game_edu_fem_illit_vill_ game_edu_fem_prim_vill_ game_edu_fem_sec_vill_ game_edu_fem_uni_vill_ game_edu_male_illit_vill_ game_edu_male_prim_vill_ game_edu_male_sec_vill_ game_edu_male_uni_vill_ game_date_intervention_ game_count_intervention_ game_Facilitationteam_ game_date_count_ game_lead_facil_ game_with_Radha_ game_total_opt_inv_ game_opt_inv_r8_ game_opt_inv_r9_ game_opt_inv_r10_ game_optimal_inv_r10_ game_optimal_inv_r9_10_ game_optimal_inv_r8_10_ game_almost_opt_inv_r10_ game_almost_opt_inv_r9_10_ game_almost_opt_inv_r8_10_ game_sum_lead_opt_r9_10_ game_sum_lead_opt_r8_10_ game_share_lead_opt_r9_10_ game_share_lead_opt_r8_10_ Excluded_sites_old_ FES_site_ No_HH_ Sample_variable_ Shar_Lit_ Shar_SCST_ Village_ original_sample_ payment_form_ paymentform_ survey_CWRgroup_already_ survey_CWRgroup_new_ survey_activity_any_ survey_activity_earthwall_ survey_activity_mainwall_ survey_activity_silt_ survey_activity_sluicegate_ survey_activity_vege_ survey_benefit_agri_ survey_benefit_domuse_ survey_benefit_fish_ survey_benefit_livestock_ survey_benefit_other_ survey_change_benefit_ survey_collact_new_ survey_compay_community_ survey_compay_equal_ survey_compay_leader_ survey_compay_otheruser_ survey_conflict_alloc_ survey_conflict_maint_ survey_conflict_oper_ survey_conflicts_any_ survey_conflicts_other_ survey_cwr_bori_ survey_cwr_dam_ survey_cwr_other_ survey_cwr_pond_ survey_dam_for_irrigation_ survey_game_played_ survey_indipay_comm_ survey_indipay_equally_ survey_indipay_other_ survey_indipayn_notspent_ survey_interview_farmerdam_ survey_interview_lead_ survey_interview_others_ survey_interview_waterua_ survey_maint_12m_ survey_maint_2017_ survey_maint_com_ survey_rating_earthwall_ survey_rating_feederch_ survey_rating_mainwall_ survey_rating_silt_ survey_rating_sluicegate_ survey_rating_vege_ survey_rules_alloc_ survey_rules_extr_alloc_ survey_rules_extr_maint_ survey_rules_extr_opre_ survey_rules_extr_other_ survey_rules_maint_ survey_rules_maint_all_ survey_rules_old_all_ survey_rules_old_alloc_ survey_rules_old_maint_ survey_rules_old_oper_ survey_rules_old_other_ survey_rules_oper_ survey_rules_other_ survey_share_exp_comm_meet_ survey_share_exp_family_ survey_share_exp_friends_ survey_share_exp_others_ survey_share_exp_vc_meet_ Excluded_sites_ treatment_ survey_maint_rule_ com_outside_game_ census_pop_females_share_ census_caste_females_share_ census_tribes_females_share_ share_leader_female_vill_ share_no_leader_female_vill_ share_leader_male_vill_ share_no_leader_male_vill_ share_female_percent_ share_female_percent2_ share_female_percent3_ male_leader_present_ female_leader_present_ leader_present_  leader_comp1_ leader_comp2_ leader_comp3_ leader_comp4_ d_illiterate_ share_leader_percent_ share_leader_opt_percent_, i(site_ID) j(BS_FS)

rename game_share_leader_culture_vill_0 game_share_leader_cult_vill_0
rename game_share_leader_culture_vill_1 game_share_leader_cult_vill_1

rename *_0 *_BS
rename *_1 *_FS

*-----------------------------------------------------------------
* Clean data up
order *, alphabetic
rename *village* *vill*

*Drop doubled observations from game and census 
drop census_caste_fem_FS census_caste_males_FS census_caste_total_FS census_gov_school_middle_FS census_gov_school_prim_FS census_gov_school_sec_FS census_no_hh_FS census_population_fem_FS census_population_males_FS census_population_total_FS census_priv_school_middle_FS census_priv_school_prim_FS census_priv_school_sec_FS census_tribes_fem_FS census_tribes_males_FS census_tribes_total_FS game_agree_rule_FS   game_almost_opt_inv_r10_FS game_almost_opt_inv_r8_10_FS game_almost_opt_inv_r9_10_FS game_argue_FS   game_av_inv_vill_R1_10_FS game_av_inv_vill_R1_5_FS game_av_inv_vill_R6_10_FS    game_come_back_dummy_FS  game_complains_FS  game_cont_lab_vill_FS game_cont_money_vill_FS game_count_intervention_FS game_damforfarming_FS game_date_count_FS game_date_intervention_FS game_dist_field_vill_FS game_edu_fem_illit_vill_FS game_edu_fem_prim_vill_FS game_edu_fem_sec_vill_FS game_edu_fem_uni_vill_FS game_edu_male_illit_vill_FS game_edu_male_prim_vill_FS game_edu_male_sec_vill_FS game_edu_male_uni_vill_FS game_elected_leader_sum_FS game_Facilitationteam_FS game_fem_FS game_lead_facil_FS game_leader_fem_vill_FS game_leader_male_vill_FS game_leader_present_vill_FS game_males_FS game_no_leader_fem_vill_FS game_no_leader_male_vill_FS game_opt_inv_r10_FS game_opt_inv_r8_FS game_opt_inv_r9_FS game_optimal_inv_r10_FS game_optimal_inv_r8_10_FS game_optimal_inv_r9_10_FS game_overall_earning_vill_FS game_payment_announcement_FS  game_praises_FS   game_propose_rule_FS  game_punish_FS   game_reci_wat_vill_FS game_reject_rule_FS   game_reward_FS   game_sample_vill_FS game_share_fem_vill_FS game_share_illit_vill_FS game_share_leader_CR_vill_FS game_share_leader_cult_vill_FS game_share_leader_SHG_vill_FS game_share_leader_state_vill_FS game_share_leader_vill_FS game_share_uni_degree_vill_FS game_sum_illit_vill_FS game_sum_leader_CR_FS game_sum_leader_culturestate_FS game_sum_leader_no_FS game_sum_leader_SHG_FS game_sum_leader_state_FS game_sum_uni_degree_vill_FS game_total_all_FS     game_total_gamerelated_FS game_total_opt_inv_FS game_unconnected_FS      game_with_Radha_FS  Village_FS Sample_variable_FS FES_site_FS Excluded_sites_FS payment_form_FS paymentform_FS original_sample_FS game_Village_FS game_come_back_FS  No_HH_FS Shar_SCST_FS Shar_Lit_FS game_share_lead_opt_r8_10_FS game_share_lead_opt_r9_10_FS game_sum_lead_opt_r8_10_FS game_sum_lead_opt_r9_10_FS   treatment_FS   census_pop_females_share_FS census_caste_females_share_FS census_tribes_females_share_FS share_leader_female_vill_FS share_no_leader_female_vill_FS share_leader_male_vill_FS share_no_leader_male_vill_FS share_female_percent_FS share_female_percent2_FS share_female_percent3_FS leader_present_FS  d_illiterate_FS share_leader_percent_FS share_leader_opt_percent_FS payment_form_BS com_outside_game_BS census_no_hh_FS census_no_hh_FS census_population_total_FS census_population_males_FS census_population_fem_FS census_caste_total_FS census_caste_males_FS census_caste_fem_FS census_tribes_total_FS census_tribes_males_FS census_tribes_fem_FS census_gov_school_prim_FS census_priv_school_prim_FS census_gov_school_middle_FS census_priv_school_middle_FS census_gov_school_sec_FS census_priv_school_sec_FS census_pop_females_share_FS census_caste_females_share_FS census_tribes_females_share_FS  survey_game_played_BS site_game_FS

*Drop variables not collected in baseline survey
drop survey_share_exp_vc_meet_BS survey_share_exp_others_BS survey_share_exp_friends_BS survey_share_exp_family_BS survey_share_exp_comm_meet_BS survey_indipayn_notspent_BS survey_indipay_other_BS survey_indipay_equally_BS survey_indipay_comm_BS  survey_cwr_pond_BS survey_cwr_other_BS survey_cwr_dam_BS survey_cwr_bori_BS      survey_compay_otheruser_BS survey_compay_leader_BS survey_compay_equal_BS survey_compay_community_BS survey_collact_new_BS survey_change_benefit_BS survey_activity_any_BS survey_CWRgroup_new_BS survey_CWRgroup_already_BS survey_maint_2017_BS survey_conflicts_other_BS

*Drop variables not collected in endline survey
drop survey_rules_old_other_FS survey_rules_old_oper_FS survey_rules_old_maint_FS survey_rules_old_alloc_FS survey_rules_old_all_FS survey_maint_12m_FS     survey_conflicts_any_FS

global  vars "census_caste_fem_BS census_caste_females_share_BS census_caste_males_BS census_caste_total_BS census_gov_school_middle_BS census_gov_school_prim_BS census_gov_school_sec_BS census_no_hh_BS census_pop_females_share_BS census_population_fem_BS census_population_males_BS census_population_total_BS census_priv_school_middle_BS census_priv_school_prim_BS census_priv_school_sec_BS census_tribes_fem_BS census_tribes_females_share_BS census_tribes_males_BS census_tribes_total_BS game_Facilitationteam_BS game_Village_BS game_agree_rule_BS game_almost_opt_inv_r10_BS game_almost_opt_inv_r8_10_BS game_almost_opt_inv_r9_10_BS game_argue_BS game_av_inv_vill_R1_10_BS game_av_inv_vill_R1_5_BS game_av_inv_vill_R6_10_BS game_come_back_BS game_come_back_dummy_BS game_complains_BS game_cont_lab_vill_BS game_cont_money_vill_BS game_count_intervention_BS game_damforfarming_BS game_date_count_BS game_date_intervention_BS game_dist_field_vill_BS game_edu_fem_illit_vill_BS game_edu_fem_prim_vill_BS game_edu_fem_sec_vill_BS game_edu_fem_uni_vill_BS game_edu_male_illit_vill_BS game_edu_male_prim_vill_BS game_edu_male_sec_vill_BS game_edu_male_uni_vill_BS game_elected_leader_sum_BS game_fem_BS game_lead_facil_BS game_leader_fem_vill_BS game_leader_male_vill_BS game_leader_present_vill_BS game_males_BS game_no_leader_fem_vill_BS game_no_leader_male_vill_BS game_opt_inv_r10_BS game_opt_inv_r8_BS game_opt_inv_r9_BS game_optimal_inv_r10_BS game_optimal_inv_r8_10_BS game_optimal_inv_r9_10_BS game_overall_earning_vill_BS game_payment_announcement_BS game_played_BS game_played_FS game_praises_BS game_propose_rule_BS game_punish_BS game_reci_wat_vill_BS game_reject_rule_BS game_reward_BS game_sample_vill_BS game_share_fem_vill_BS game_share_illit_vill_BS game_share_lead_opt_r8_10_BS game_share_lead_opt_r9_10_BS game_share_leader_CR_vill_BS game_share_leader_SHG_vill_BS game_share_leader_cult_vill_BS game_share_leader_state_vill_BS game_share_leader_vill_BS game_share_uni_degree_vill_BS game_sum_illit_vill_BS game_sum_lead_opt_r8_10_BS game_sum_lead_opt_r9_10_BS game_sum_leader_CR_BS game_sum_leader_SHG_BS game_sum_leader_culturestate_BS game_sum_leader_no_BS game_sum_leader_state_BS game_sum_uni_degree_vill_BS game_total_all_BS game_total_gamerelated_BS game_total_opt_inv_BS game_unconnected_BS game_with_Radha_BS site_game_BS"

foreach v of global vars {
	rename `v' `v'_
	}
rename *_BS_ *

*keep site_ID_  game_payment_form payment_form_BS paymentform_BS // identical
rename com_outside_game_FS survey_com_outside_game
rename  paymentform_BS paymentform
rename original_sample_BS original_sample
rename Excluded_sites_BS Excluded_sites
rename FES_site_BS FES_site
rename Sample_variable_BS Sample_variable
rename Village_BS Village
rename Shar_Lit_BS Shar_Lit
rename Shar_SCST_BS Shar_SCST
rename No_HH_BS No_HH
rename site_ID_ site_ID	

*----------
*2 Label
*----------
label var survey_activity_any_FS "FS: Conducted dam maintenance activity: Any repair"
label var survey_activity_earthwall_BS"BS: Dam maintenance activities: Repair earthwall"
label var survey_activity_earthwall_FS "FS: Dam maintenance activities: Repair earthwall"
label var survey_activity_mainwall_BS"BS: Dam maintenance activities: Mainwall repair"
label var survey_activity_mainwall_FS "FS: Dam maintenance activities: Mainwall repair"
label var survey_activity_silt_BS"BS: Dam maintenance activities: Remove silt"
label var survey_activity_silt_FS "FS: Dam maintenance activities: Remove silt"
label var survey_activity_sluicegate_BS"BS: Dam maintenance activities: Sluicegate repair"
label var survey_activity_sluicegate_FS "FS: Dam maintenance activities: Sluicegate repair"
label var survey_activity_vege_BS"BS: Dam maintenance activities: Remove vegetation"
label var survey_activity_vege_FS "FS: Dam maintenance activities: Remove vegetation"
label var survey_benefit_agri_BS"BS: There are agricultural benefits related to dam"
label var survey_benefit_agri_FS "FS: There are agricultural benefits related to dam"
label var survey_benefit_domuse_BS "BS: There are domestic use benefits related to dam" 
label var survey_benefit_domuse_FS "FS: There are domestic use benefits related to dam" 
label var survey_benefit_fish_BS "BS: There are fishing benefits related to dam" 
label var survey_benefit_fish_FS "FS: There are fishing benefits related to dam" 
label var survey_benefit_livestock_BS "BS: There are livestock benefits related to dam"
label var survey_benefit_livestock_FS "FS: There are livestock benefits related to dam"
label var survey_benefit_other_BS "BS: There are other benefits related to dam"
label var survey_benefit_other_FS "FS: There are other benefits related to dam"
label var survey_change_benefit_FS "FS: There has been change in shared CWR benefit after game"
label var survey_collact_new_FS "FS: community met for collective action after game played"
label var survey_compay_community_FS "FS: lump sum payment from game used for common work"
label var survey_compay_equal_FS "FS: lump sum payment from game equally distr"
label var survey_compay_leader_FS "FS: lump sum payment from game not spend"
label var survey_compay_otheruser_FS "FS: lump sum payment from game used for other purposes"
label var survey_conflict_alloc_BS "BS: Hhere were allocation conflicts around the dam" 
label var survey_conflict_alloc_FS "FS: There were allocation conflicts around the dam" 
label var survey_conflict_maint_BS "BS: There were maintenance conflicts around the dam"
label var survey_conflict_maint_FS "FS: There were maintenance conflicts around the dam"
label var survey_conflict_oper_BS "BS: Hhere were operational conflicts around the dam"
label var survey_conflict_oper_FS "FS: There were operational conflicts around the dam"
label var survey_conflicts_any_BS "BS: There were any conflicts around the dam"
label var survey_conflicts_other_FS "FS: There were other conflicts around the dam"
label var survey_cwr_bori_FS "FS: Community has bori bonds"
label var survey_cwr_dam_FS "FS: Community has stop dam"
label var survey_cwr_other_FS "FS: Community has other common water resources"
label var survey_cwr_pond_FS "FS: Community has pond"

label var survey_CWRgroup_already_FS "FS: Was there such a group before? "
label var survey_CWRgroup_new_FS "FS: After game new group to take care of water resources?"
label var survey_dam_for_irrigation_BS "BS:Dam is used for irrigation"
label var survey_dam_for_irrigation_FS "FS: Dam is used for irrigation"
label var survey_game_played_FS "FS: The game was played in the village"
label var survey_indipay_comm_FS "FS: individual money from game used for common work"
label var survey_indipay_equally_FS "FS: individual money from game equally distr"
label var survey_indipay_other_FS "FS: individual money from game used for other purposes"
label var survey_indipayn_notspent_FS "FS: individual money from game not spend"
label var survey_interview_farmerdam_BS "BS: Interview partner = Farmer/Dam user"
label var survey_interview_farmerdam_FS "FS: Interview partner = Farmer/Dam user"
label var survey_interview_lead_BS "BS: Interview partner =Village leader/Panchayat"
label var survey_interview_lead_FS "FS: Interview partner =Village leader/Panchayat"
label var survey_interview_others_BS "BS: Interview partner = Water Association Member"
label var survey_interview_others_FS "FS: Interview partner = Water Association Member"
label var survey_interview_waterua_BS "BS: Interview partner = Water Association Member"
label var survey_interview_waterua_FS "FS: Interview partner = Water Association Member"
label var survey_maint_12m_BS "BS: Dam received any maintenance within the last 12 month"
label var survey_maint_2017_FS "FS: Dam received any maintenance since 2017?"
label var survey_rating_earthwall_BS "BS: Rating on dams earthwall condition"
label var survey_rating_earthwall_FS "FS: Rating on dams earthwall condition"
label var survey_rating_feederch_BS "BS: Rating on dams feeder channel condition"
label var survey_rating_feederch_FS "FS: Rating on dams feeder channel condition"
label var survey_rating_mainwall_BS "BS: Rating on dams mainwall condition"
label var survey_rating_mainwall_FS "FS: Rating on dams mainwall condition"
label var survey_rating_silt_BS "BS: Rating reduced dam capacity due to siltation"
label var survey_rating_silt_FS "FS: Rating reduced dam capacity due to siltation"
label var survey_rating_sluicegate_BS "BS: Rating on dams sluicegate condition"
label var survey_rating_sluicegate_FS "FS: Rating on dams sluicegate condition"
label var survey_rating_vege_BS "BS: Rating reduced dam capacity due to vegetation" 
label var survey_rating_vege_FS "FS: Rating reduced dam capacity due to vegetation" 
label var survey_rules_alloc_BS "BS: There are resource allocation rules"
label var survey_rules_alloc_FS "FS: There are resource allocation rules"
label var survey_rules_extr_alloc_BS "BS: There are allocation rules/practices for water etxraction"
label var survey_rules_extr_alloc_FS "FS: There are allocation rules/practices for water etxraction"
label var survey_rules_extr_maint_BS "BS: There are maintenance rules/practices for water etxraction"
label var survey_rules_extr_maint_FS "FS: There are maintenance rules/practices for water etxraction"
label var survey_rules_extr_opre_BS "BS: There are operational rules/practices for water etxraction"
label var survey_rules_extr_opre_FS "FS: There are operational rules/practices for water etxraction"
label var survey_rules_extr_other_BS "BS: There are other rules/practices for water etxraction"
label var survey_rules_extr_other_FS "FS: There are other rules/practices for water etxraction"
label var survey_rules_maint_all_BS "BS: There are rules by the community for dam maintenance?"
label var survey_rules_maint_all_FS "FS: There are rules by the community for dam maintenance?"
label var survey_rules_maint_BS "BS: There are dam maintenance rules"
label var survey_rules_maint_FS "FS: There are dam maintenance rules"
label var survey_rules_old_all_BS "BS: Remember old community rules for dam management?"
label var survey_rules_old_alloc_BS "BS: Remember old community rules for dam allocation"
label var survey_rules_old_maint_BS "BS: Remember old community rules for dam maintenance"
label var survey_rules_old_oper_BS "BS: Remember old community rules for dam operation"
label var survey_rules_old_other_BS "BS: Remember old community rules for other dam issues"
label var survey_rules_oper_BS "BS: There are operational rules"
label var survey_rules_oper_FS "FS: There are operational rules"
label var survey_rules_other_BS "BS: There are other rules"
label var survey_rules_other_FS "FS: There are other rules"
label var survey_share_exp_comm_meet_FS "FS: Game discussed in community meeting"
label var survey_share_exp_family_FS "FS: Game discussed with family"
label var survey_share_exp_friends_FS "FS: Game discussed with friends"
label var survey_share_exp_others_FS "FS: Game discussed with other members"
label var survey_share_exp_vc_meet_FS "FS: Game discussed with Panchayat"


*label census data
label var census_no_hh "Census: Total households in village"
label var census_population_total "Census: Total population in village"
label var census_population_males "Census: Total male in village"
label var census_population_fem "Census: Total female in village"
label var census_caste_total "Census: Total scheduled castes population of village"
label var census_caste_males "Census: Total male scheduled castes population of village"
label var census_caste_fem "Census: Total female scheduled castes population of village"
label var census_tribes_total "Census: Total scheduled tribes population of village"
label var census_tribes_males "Census: Total male scheduled tribes population of village"
label var census_tribes_fem "Census: Total female scheduled tribes population of village"
label var census_gov_school_prim "Census: Number of govt primary schools"
label var census_priv_school_prim "Census: Number of private primary schools"
label var census_gov_school_middle "Census: Number of govt middle schools"
label var census_priv_school_middle "Census: Number of private middle schools"
label var census_gov_school_sec "Census: Number of govt secondary schools"
label var census_priv_school_sec "Census: Number of private secondary schools"
label var census_caste_females_share "Census: Share of females in caste"
label var census_pop_females_share "Census: Share of females among population"
label var census_tribes_females_share "Census: Share of females among scheduled tribes population of village"


*label game data
label var paymentform "Used payment in village (IP=individual; CP=community pay)"
label var game_payment_announcement "Payment was announced in village"
label var game_argue "Total of arguments in village for group"
label var game_reject_rule "Total of rejected rules in village for group"
label var game_agree_rule "Total of agreed rules in village for group"
label var game_propose_rule "Total of proposed rules in village for group"
label var game_complains "Total of complains in village for group"
label var game_praises "Total of praises in village for group"
label var game_reward "Total of proposed reward in village group"
label var game_punish "Total of proposed punishment in village group"
label var game_unconnected "Total of unconnected inputs in village group"
label var game_total_gamerelated "Total game related communication in village during discussion slots"
label var game_total_all "Total communication in village during discussion slots"
label var game_edu_fem_illit_vill "Sum of females that are illiterate"
label var game_edu_fem_prim_vill "Sum of females that have primary education"
label var game_edu_fem_sec_vill "Sum of females that have secondary education"
label var game_edu_fem_uni_vill "Sum of females that have a uni degree"
label var game_edu_male_illit_vill "Sum of males that are illiterate"
label var game_edu_male_prim_vill "Sum of males that have primary education"
label var game_edu_male_sec_vill "Sum of males that have secondary education"
label var game_edu_male_uni_vill "Sum of males that have a uni degree"
label var game_share_fem_vill "Share of females in village"	

rename game_fem game_total_fem
label var game_total_fem "Total no of female players in village"
rename game_males game_total_males
label var game_total_males "Total no of male players in village"
label var game_sum_uni_degree_vill "Sum of participant that have a uni degree"	
label var game_share_uni_degree_vill "Share of participant that have a uni degree"	
label var game_sum_illit_vill "Sum of participant that are illiterate"	
label var game_share_illit_vill "Share of participant that are illiterate"	
label var game_elected_leader_sum "Sum of leaders present during game"	
label var game_leader_present_vill "Leader was present during game"	
label var game_share_leader_CR_vill "Share of leaders in common resources in village"	
label var game_share_leader_SHG_vill "Share of leaders in self help group in village"	
label var game_share_leader_cult_vill"Share of leaders in social or cultural groups in village"	
label var game_share_leader_state_vill "Share of leaders in state or political position in village"	
label var game_share_leader_vill "Share of no leaders in village"	
label var game_sum_leader_CR "Sum of leaders in common resources in village"	
label var game_sum_leader_SHG "Sum of leaders in self help group in village"	
label var game_sum_leader_culturestate "Total of leaders in social or cultural groups in village"	
label var game_sum_leader_no "Total of no leaders in village"	
label var game_sum_leader_state "Total of leaders in state or political position in village"	
label var game_leader_fem_vill "Sum of female leaders"	
label var game_leader_male_vill "Sum of male leaders in village"	
label var game_no_leader_fem_vill "Sum of females that are no leaders in village"	
label var game_no_leader_male_vill "Sum of males that are no leaders in village"	
label var game_almost_opt_inv_r10 "Both groups invested about 80-100 % in last round"
label var game_almost_opt_inv_r8_10 "Both groups invested about 80-100 % in last three rounds"
label var game_almost_opt_inv_r9_10 "Both groups invested about 80-100 % in last two rounds"
label var game_optimal_inv_r10 "Both groups invested optimally in last round"	
label var game_optimal_inv_r8_10 "Both groups invested optimally in last three rounds"	
label var game_optimal_inv_r9_10 "Both groups invested optimally in last two rounds"	
label var game_opt_inv_r10 "Optimal investment in round 10 reached by.."	
label var game_opt_inv_r8 "Optimal investment in round 8 reached by.."	
label var game_opt_inv_r9 "Optimal investment in round 9 reached by.."	
label var game_av_inv_vill_R1_10 "Average round investment in village by each player over all rounds"
label var game_av_inv_vill_R1_5 "Average round investment in village by each player over phase I"
label var game_av_inv_vill_R6_10 "Average round investment in village by each player over phase II"
label var game_total_opt_inv "Count of optimal invested rounds (max20)"
label var game_overall_earning_vill "Overall earning of village in whole game"
label var game_date_count "Days since first intervention took place"	
label var game_date_intervention "Date of the intervention "	
label var game_count_intervention "Indicates the how maniest intervention this is conducted by the team"	
label var game_Facilitationteam "Facilitator team during intervention"
label var game_lead_facil "Lead facilitator during intervention"
label var game_with_Radha "Radha was part of the intervention team"
label var game_come_back_dummy "Indicates whether community wants us to come back to perform another experiment"	
label var game_cont_lab_vill "Total of participants that contributed labor to dam maintenance"	
label var game_cont_money_vill "Total of participants that contributed money to dam maintenance"	
label var game_damforfarming "Dam used for farming"	
label var game_dist_field_vill "Average distance between participants fields and dam in village"	
label var game_reci_wat_vill "Total of participants that received water from village dam"	


label var game_sum_lead_opt_r9_10 "Number of leaders in village that played optimally in rounds 9-10 based on all players"
label var game_sum_lead_opt_r8_10 "Number of leaders in village that played optimally in round 8-10 based on all players"
label var game_share_lead_opt_r9_10 "Share of no leaders in village that played optimally in round 9-10 based on all players"
label var game_share_lead_opt_r8_10 "Share of no leaders in village that played optimally in round 8-10 based on all players"

label var survey_maint_12m_BS "Maintenance conducted (Baseline)"
label var survey_maint_2017_FS  "Maintenance conducted (Endline)"
label var survey_dam_for_irrigation_BS "Dam used for irrigation"

label var survey_maint_12m_BS "Maintenance conducted (Baseline)"
label var survey_maint_2017_FS  "Maintenance conducted (Endline)"
label var survey_maint_rule_BS "Maintenance rule exist (Baseline)" 
label var survey_maint_rule_FS "Maintenance rule exist (Endline)"

label var survey_dam_for_irrigation_BS "Dam used for irrigation"

label var share_leader_opt_percent "Share of leaders present in games"
label var survey_com_outside_game  "Intervention discussed"
label var game_share_illit_vill "Illiterate participans (=1)"
label var game_share_fem_vill   "Female present in %"
label var game_share_leader_vill "Leaders present in %" 
label var share_leader_female_vill "Female leaders  presentin %"   
label var game_come_back_dummy "Come back (=1)"

label var No_HH "Village size (households)"
label var FES_site "NGO presence (=1)"
label var Shar_Lit "Share literacy in %"
label var Shar_SCST  "Share caste/tribal in %"

label var Village "Name of Village"

lab var FES_site "NGO active in village (=1)"
lab var share_female_percent3_BS "Non-leader female participants (in 10%)"
lab var leader_comp1_BS "No leader participated (=1)"
lab var leader_comp2_BS "Only male leader participated (=1)"
lab var leader_comp3_BS "Both male and female leader participated (=1)"
lab var leader_comp4_BS "Only female leader participated (=1)"

lab var survey_dam_for_irrigation_FS "Dam used for irrigation (=1)"
lab var survey_maint_2017_FS "Endline: Maintenance (=1)"
lab var survey_maint_12m_BS "Baseline: Maintenance (=1)"
lab var survey_maint_rule_FS "Endline: Maintenance rule (=1)"
lab var survey_maint_rule_BS "Baseline: Maintenance rule (=1)"


* Replace missing census data (see Mail Duche 5.1.2022)
replace Shar_SCST = 100 if site_ID == 209
replace Shar_Lit = 54.2 if site_ID == 209
replace No_HH = 129 if site_ID == 209

* Replace missing fs data  (see Mail Thomas 5.1.22 - 17:02)
replace survey_maint_2017_FS = 0 if site_ID == 32
replace survey_maint_12m_BS = 0 if  site_ID == 203
replace survey_maint_12m_BS = 0 if  site_ID == 216

*Sequence of interventions in treatment villages
sort game_date_intervention
gen sequence=[_n]
gen seq_split= 0
replace seq_split=1 if sequence>28
lab var sequence "Sequence of game interventions (1 to 56)"


*game related formal discussions
gen game_discussed_formally = 0 if survey_share_exp_comm_meet_FS==0 & survey_share_exp_vc_meet_FS==0
replace game_discussed_formally = 1 if survey_share_exp_vc_meet_FS==1 | survey_share_exp_comm_meet_FS==1
tab game_discussed_formally


*Schools in each village
egen n_school_gov = rowtotal(census_gov_school_middle census_gov_school_prim census_gov_school_sec)
egen n_school_priv = rowtotal(census_priv_school_middle census_priv_school_prim census_priv_school_sec)

gen d_public_school = 0 if n_school_gov==0
replace d_public_school = 1 if n_school_gov>0

gen d_private_school = 0 if n_school_priv==0
replace d_private_school = 1 if n_school_priv>0

gen no_school = 1 if d_public_school==0 & d_private_school==0
replace no_school = 0 if  d_public_school>0 | d_private_school>0

tab1 d_public_school d_private_school no_school

gen number_schools = n_school_gov+n_school_priv


*drop variables with all missings and generate some additional variabels and labels
dropmiss, force


save "$working_ANALYSIS/processed/games_wide.dta", replace





*Merge information on SHG in villages
clear all
import excel "$working_ANALYSIS/data/SHG_data.xlsx", sheet ("Sample") firstrow
destring SHG_before2017 SHG_after2017 n_SHG_before2017 n_SHG_after2017, replace

*all information ON SHG for 56 treatment communities matched
*winsorize extreme outliers in SHGs
winsor2 n_SHG_before2017, cuts(0 95) replace
winsor2 n_SHG_after2017, cuts(0 95) replace


save "$working_ANALYSIS/data/village_SHG.dta", replace


use "$working_ANALYSIS/processed/games_wide.dta"
merge 1:1 site_ID using "$working_ANALYSIS/data/village_SHG.dta"
drop _merge
*all information ON SHG for 56 treatment communities and 27 control sites matched

save "$working_ANALYSIS/processed/games_SHG.dta", replace



*Merge information on distances to district capital
clear all
import excel "$working_ANALYSIS/data/Sample_Locations.xlsx", sheet ("Sheet1") firstrow

save "$working_ANALYSIS/data/road_distances.dta", replace


use "$working_ANALYSIS/processed/games_SHG.dta"
merge 1:1 site_ID using "$working_ANALYSIS/data/road_distances.dta"
drop _merge

*----------------------------
* SAVE FINAL DATASET
*----------------------------
save "$working_ANALYSIS/processed/games_clean_final.dta", replace





** EOF