*--------------------------------------------------

*--------------------------------------------------

* Create and define a local installation directory for the packages
cap mkdir "$working_ANALYSIS/scripts/libraries\stata"
net set ado "$working_ANALYSIS/scripts/libraries\stata"

* Install packages from SSC
foreach p in grstyle palettes elabel geodist colrspace tab_chi xls2dta coefplot  estout stripplot winsor2 {
	ssc install `p', replace
}


