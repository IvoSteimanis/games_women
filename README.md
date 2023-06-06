# Replication Package
This repository contains the raw data and code that replicates tables and figures for the following paper:: <br>
__Title:__ Changing the Game: The Role of Women in Experiential Learning  <br>
__Authors:__ Thomas Falk<sup>1,2,*</sup>, Lara Bartels<sup>3</sup> Ivo Steimanis<sup>2</sup>, Vishwambhar Duche<sup>4</sup> & Björn Vollan<sup>2</sup> <br>
__Affiliations:__ <sup>1</sup> Department of Economics, Philipps University Marburg, 35032 Marburg, Germany <br>
__*Correspondence to:__ homas Falk T.Falk@cgiar.org <br>
__ORCID:__ Falk: 0000-0002-2200-3048, Bartels: 0000-0002-1426-6892, Steimanis: 0000-0002-8550-4675, Vollan: 0000-0002-5592-4185 <br>
__Classification:__ Social Sciences, Economic Sciences <br>
__Keywords:__ India, water management, social dilemma, social learning, games <br>

## License
The data are licensed under a Creative Commons Attribution 4.0 International Public License. The code is licensed under a Modified BSD License. See LICENSE.txt for details.

## Software requirements
All analysis were done in Stata version 16:
- Add-on packages are included in __scripts/libraries/stata__ and do not need to be installed by user. The names, installation sources, and installation dates of these packages are available in __scripts/libraries/stata/stata.trk__.

## Instructions
1.	Save the folder __‘analysis’__ to your local drive.
2.	Open the master script __‘run.do’__ and change the global pointing to the working direction (line 20) to the location where you save the folder on your local drive 
3.	Run the master script __‘run.do’__  to replicate the analysis and generate all tables and figures reported in the paper and supplementary online materials

## Datasets
-	"2022_09_identifier_included_excluded.dta" includes organizational information on the villages such as their allocation to control and treated.
- Input file: Overview_games_intervention_control.xls
- "2022_06_Mandla_Census.dta" includes the Census 2011 data of the sample villages.
-	Input file: Zensus_Mandla.xls
-	“2022_06_Mandla_Game_raw.dta” includes the raw data on the game intervention.<br>
Input files…. 
-	"2022_06_Mandla_Game.dta" includes the cleaned game intervention data.
-	"Data_Facilitators.dta" includes information on the interventions’ facilitator teams and the intervention dates. 
-	Input file: Facilitators_MP_sites.xls
-	"2022_06_Mandla_Game_village_long.dta" matched the clean game intervention data with the facilitator data and transformed the individual intervention data to data at the village level to merge them with the survey data.
-	"2023_03_Survey_Baseline.dta” includes the baseline survey data.
-	Input file: MP_suvey_data_short.xls
-	"2023_03_Survey_Endline.dta” includes the follow-up survey data.
-	Input file: MP_suvey_data_short.xls
-	"2023_03_Survey_Wide.dta" includes the merged baseline and follow-up survey data.
-	"2023_03_Survey_Long.dta" includes the merged baseline and follow-up survey data in a long format to merge them with the intervention data.
-	"2023_03_Survey&Game_Long.dta” includes the merged survey and intervention data in a long format. Our analysis is based on tis final data set. 
-	"2023_03_Survey&Game_Wide.dta" includes the merged survey and intervention data in a wide format.


## Descriptions of scripts
__01_cleangen.do__
This script processes the raw data from the game intervention as well as the baseline and endline survey waves. Within this scrip several data sources are cleaned and used to create the final data for analysis.
-	"2022_09_identifier_included_excluded.dta" includes organizational information on the villages such as their allocation to control and treated.
-	"2022_06_Mandla_Census.dta" includes the Census 2011 data of the sample villages.
-	“2022_06_Mandla_Game_raw.dta” includes the raw data on the game intervention.
-	"2022_06_Mandla_Game.dta" includes the cleaned game intervention data.
-	"Data_Facilitators.dta" includes information on the interventions’ facilitator teams and the intervention dates. 
-	"2022_06_Mandla_Game_village_long.dta" matched the clean game intervention data with the facilitator data and transformed the individual intervention data to data at the village level to merge them with the survey data.
-	"2023_03_Survey_Baseline.dta” includes the baseline survey data.
-	"2023_03_Survey_Endline.dta” includes the follow-up survey data.
-	"2023_03_Survey_Wide.dta" includes the merged baseline and follow-up survey data.
-	"2023_03_Survey_Long.dta" includes the merged baseline and follow-up survey data in a long format to merge them with the intervention data.
-	"2023_03_Survey&Game_Long.dta” includes the merged survey and intervention data in a long format. Our analysis is based on tis final data set. 
-	"2023_03_Survey&Game_Wide.dta" includes the merged survey and intervention data in a wide format.<br>

__02_analysis.do__
This script estimates regression models in Stata, creates figures and tables, saving them to results/figures and results/tables


