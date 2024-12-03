global DATA = "/Users/marcelkitenge/Documents/WHO Consultancy/Limpopo Documents/Data/PHC Data/PHC Vaccination-Performance Evaluation"
global TEMPO ="/Users/marcelkitenge/Documents/WHO Consultancy/Limpopo Documents/Data/PHC Data/PHC Vaccination-Performance Evaluation"

import excel "$DATA\All Public Vaccination till  5 August 2022.xlsx", sheet("Sheet1") firstrow clear

format visit_date %td
sort visit_date
br visit_date
count if visit_date==date("13sep2021","DMY")

****** Allocating PHCs and Hospitals ******

tab Facility if strmatch(Facility,"*Hospital*") & visit_date>=date("17sep2021","DMY")

generate phc=1
replace phc=0 if strmatch(Facility,"*Hospital*")

replace phc=2 if VaccineSite=="Covid-19 Vaccination Outreach 1 - Pick n Pay Mall at Lebo"
replace phc=2 if VaccineSite=="Covid-19 Vaccination Outreach 22 - PALEDI SUPERSPAR"
replace phc=2 if VaccineSite=="Covid-19 Vaccination Outreach 8 - Cambridge Seshego"
replace phc=2 if VaccineSite=="Covid-19 Vaccination Outreach 9 - Pick N Pay Polokwane"
replace phc=2 if VaccineSite=="Covid-19 Vaccination Outreach 11 - Lulekani Spar"
replace phc=2 if VaccineSite=="Covid-19 Vaccination Outreach 20 - Modjadjiskloof SPAR"
replace phc=2 if VaccineSite=="Covid-19 Vaccination Outreach 10 - Pick N Pay (Burgersfort Tubatse)"
replace phc=2 if VaccineSite=="Covid-19 Vaccination Outreach 11 - Pick N Pay (Steelpoort)"
replace phc=2 if VaccineSite=="Covid-19 Vaccination Outreach 1 - Boxer Magneetshogte"
replace phc=2 if VaccineSite=="Covid-19 Vaccination Outreach 13 - SuperSpar Moratiwa Crossing"
replace phc=2 if VaccineSite=="Covid-19 Vaccination Outreach 11 - Vuwani SPAR"
replace phc=2 if VaccineSite=="Covid-19 Vaccination Outreach 12 - SASELAMANI SPAR"
replace phc=2 if VaccineSite=="Covid-19 Vaccination Outreach 11 - Elim Super Spar"
replace phc=2 if VaccineSite=="Covid-19 Vaccination Outreach 20 - Thohoyandou Boxer"
replace phc=2 if VaccineSite=="Covid-19 Vaccination Outreach 21 - Thohoyandou Spar"
replace phc=2 if VaccineSite=="Covid-19 Vaccination Outreach 1 - MOKOPANE SUPER SPAR"
replace phc=2 if VaccineSite=="Covid-19 Vaccination Outreach 1 - Mookgophong Spar"

//replace phc=2 if strmatch(VaccineSite,"*Outreach*")
replace phc=3 if strmatch(VaccineSite,"*Mobile*") 

label variable phc "PHC Vaccination Sites"
label define phc 0 "Hospitals" 1"PHCs" 2"NGO Funded" 3"Mobile-Outreach"
label values phc phc

tab phc
tab Facility
tab Facility phc

sort phc VaccineSite
br Facility VaccineSite phc
label list phc

save "$DATA/Vaccination_Import.dta",replace 

********* Keep only those PHC and date PHC Vaccination expansion ***********

use "$DATA/Vaccination_Import.dta", clear

//keep if phc==1 & visit_date>=date("17sep2021","DMY")

//keep if (phc==1|phc==2) & (visit_date>=date("01jan2022","DMY") & visit_date<=date("28sep2022","DMY"))
br Facility phc VaccineSite
count 

gen Total_Vaccincation=(Sumofsecond_dose_vaccinations+Sumoffirst_dose_vaccinations+ImmunocompromisedAdditionalDos+GeneralBoosterDose+SisonkeBoosterDose)


sort visit_date

br District Facility VaccineSite VaccineType Sumoffirst_dose_vaccinations Sumofsecond_dose_vaccinations	SisonkeBoosterDose ImmunocompromisedAdditionalDos GeneralBoosterDose visit_date phc Total_Vaccincation

save "$DATA/Vaccination_raw.dta", replace


use "$DATA/Vaccination_raw.dta", clear 


collapse (sum) Sumoffirst_dose_vaccinations Sumofsecond_dose_vaccinations Total_Vaccincation, by(visit_date District SubDistrict)

// create a numeric variable for country
encode District, gen(District_)
list visit_date District District_  /// 
     in -9/l, sepby(visit_date) abbreviate(13) 
	 
label list District_

// Save the "long" version of the data
save "$DATA/Vaccination_long.dta", replace


// Vaccination by Sub-district- Capricorn

use "$DATA/Vaccination_long.dta", clear

keep if District_==1
keep SubDistrict visit_date Total_Vaccincation District_

encode SubDistrict, gen(SubDistrict_)
label list SubDistrict_ 


collapse (sum) Total_Vaccincation, by(visit_date District_ SubDistrict_)

reshape wide Total_Vaccincation , i(visit_date) j(SubDistrict_)

drop if visit_date==date("18sep2021","DMY") | visit_date==date("24sep2021","DMY") | visit_date==date("25sep2021","DMY") | visit_date==date("02oct2021","DMY") | visit_date==date("09oct2021","DMY") | visit_date==date("10oct2021","DMY") | visit_date==date("16oct2021","DMY") | visit_date==date("23oct2021","DMY") | visit_date==date("24oct2021","DMY") | visit_date==date("15jan2022","DMY") | visit_date==date("30jan2022","DMY") | visit_date==date("29jan2022","DMY")| visit_date==date("30jan2022","DMY") | visit_date==date("12feb2022","DMY") | visit_date==date("22jan2022","DMY")


// rename the variables  
rename Total_Vaccincation1 Blouberg
rename Total_Vaccincation2 Lepelle_Nkumpi
rename Total_Vaccincation3 Molemole
rename Total_Vaccincation4 Polokwane

// rename the variables 

label var Blouberg "Blouberg"
label var Lepelle_Nkumpi "Lepelle_Nkumpi"
label var Molemole "Molemole"
label var Polokwane "Polokwane"

twoway (line Blouberg visit_date, lwidth(thick))          ///
       (line Lepelle_Nkumpi visit_date, lwidth(thick))          ///
       (line Molemole visit_date, lwidth(thick))          ///
	   (line Polokwane visit_date, lwidth(thick))           ///
       , legend(rows(2))                           ///
       ylabel(, angle(horizontal) format(%12.0fc)) ///
	   xtitle(Timepoint-Day) ///
	   title("Capricorn Vacc overtime by Sub-district,01Jan-12Feb2022") ///
	   ytitle(Number of Vaccines) yscale(range(0 .)) ylabel(#5, labsize(small) angle(horizontal))

graph export "$DATA/Capricorn.png", as(png) name("Graph") replace



// Vaccination by Sub-district- Mopani

use "$DATA/Vaccination_long.dta", clear

keep if District_==2
keep SubDistrict visit_date Total_Vaccincation District_

encode SubDistrict, gen(SubDistrict_)
label list SubDistrict_ 


collapse (sum) Total_Vaccincation, by(visit_date District_ SubDistrict_)

reshape wide Total_Vaccincation , i(visit_date) j(SubDistrict_)

drop if visit_date==date("18sep2021","DMY") | visit_date==date("24sep2021","DMY") | visit_date==date("25sep2021","DMY") | visit_date==date("02oct2021","DMY") | visit_date==date("09oct2021","DMY") | visit_date==date("10oct2021","DMY") | visit_date==date("16oct2021","DMY") | visit_date==date("23oct2021","DMY") | visit_date==date("24oct2021","DMY") | visit_date==date("15jan2022","DMY") | visit_date==date("30jan2022","DMY") | visit_date==date("29jan2022","DMY")| visit_date==date("30jan2022","DMY") | visit_date==date("12feb2022","DMY") | visit_date==date("22jan2022","DMY") | visit_date==date("05feb2022","DMY") | visit_date==date("08jan2022","DMY") 


// rename the variables  
rename Total_Vaccincation1 Ba_Phalaborwa
rename Total_Vaccincation2 Greater_Giyani
rename Total_Vaccincation3 Greater_Letaba
rename Total_Vaccincation4 Greater_Tzaneen
rename Total_Vaccincation5 Maruleng

// rename the variables 

label var Ba_Phalaborwa "Ba_Phal"
label var Greater_Giyani "Greater_Giy"
label var Greater_Letaba "Greater_Let"
label var Greater_Tzaneen "Greater_Tza"
label var Maruleng "Marul"

twoway (line Ba_Phalaborwa visit_date, lwidth(thick))          ///
       (line Greater_Giyani visit_date, lwidth(thick))         ///
       (line Greater_Letaba visit_date, lwidth(thick))         ///
	   (line Greater_Tzaneen visit_date, lwidth(thick))        ///
	   (line Maruleng visit_date, lwidth(thick))        ///
       , legend(rows(2))                           ///
       ylabel(, angle(horizontal) format(%12.0fc)) ///
	   xtitle(Timepoint-Day) ///
	   title("Mopani Vacc overtime by Sub-district,01Jan-12Feb2022") ///
	   ytitle(Number of Vaccines) yscale(range(0 .)) ylabel(#5, labsize(small) angle(horizontal)) 

graph export "$DATA/Mopani.png", as(png) name("Graph") replace



// Vaccination by Sub-district- Sekhukhune

use "$DATA/Vaccination_long.dta", clear

keep if District_==3
keep SubDistrict visit_date Total_Vaccincation District_

encode SubDistrict, gen(SubDistrict_)
label list SubDistrict_ 


collapse (sum) Total_Vaccincation, by(visit_date District_ SubDistrict_)

reshape wide Total_Vaccincation , i(visit_date) j(SubDistrict_)

drop if visit_date==date("18sep2021","DMY") | visit_date==date("24sep2021","DMY") | visit_date==date("25sep2021","DMY") | visit_date==date("02oct2021","DMY") | visit_date==date("09oct2021","DMY") | visit_date==date("10oct2021","DMY") | visit_date==date("16oct2021","DMY") | visit_date==date("23oct2021","DMY") | visit_date==date("24oct2021","DMY") | visit_date==date("15jan2022","DMY") | visit_date==date("30jan2022","DMY") | visit_date==date("29jan2022","DMY")| visit_date==date("30jan2022","DMY") | visit_date==date("12feb2022","DMY") | visit_date==date("22jan2022","DMY") | visit_date==date("05feb2022","DMY") | visit_date==date("08jan2022","DMY") | visit_date==date("23jan2022","DMY") 

// rename the variables  
rename Total_Vaccincation1 Motsoaledi
rename Total_Vaccincation2 Ephrahim_Mogale 
rename Total_Vaccincation3 Fetakgomo_Tubatse
rename Total_Vaccincation4 Makhuduthamaga


// rename the variables 

label var Motsoaledi "Motsoa"
label var Ephrahim_Mogale "Ephra Mogale"
label var Fetakgomo_Tubatse "Fet Tubatse"
label var Makhuduthamaga "Makhudu"


twoway (line Motsoaledi visit_date, lwidth(thick))          ///
       (line Ephrahim_Mogale visit_date, lwidth(thick))         ///
       (line Fetakgomo_Tubatse visit_date, lwidth(thick))         ///
	   (line Makhuduthamaga visit_date, lwidth(thick))        ///
       , legend(rows(2))                           ///
       ylabel(, angle(horizontal) format(%12.0fc)) ///
	   xtitle(Timepoint-Day) ///
	   title("Sekhukhune Vacc overtime by Sub-district,01Jan-12Feb2022") ///
	   ytitle(Number of Vaccines) yscale(range(0 .)) ylabel(#5, labsize(small) angle(horizontal))

graph export "$DATA/Sekhukhune.png", as(png) name("Graph") replace



// Vaccination by Sub-district- Vhembe

use "$DATA/Vaccination_long.dta", clear

keep if District_==4
keep SubDistrict visit_date Total_Vaccincation District_

encode SubDistrict, gen(SubDistrict_)
label list SubDistrict_ 


collapse (sum) Total_Vaccincation, by(visit_date District_ SubDistrict_)

reshape wide Total_Vaccincation , i(visit_date) j(SubDistrict_)


// rename the variables  
rename Total_Vaccincation1 Collins_Chabane
rename Total_Vaccincation2 Makhado 
rename Total_Vaccincation3 Musina
rename Total_Vaccincation4 Thulamela

// rename the variables 

label var Collins_Chabane "Collins_Chab"
label var Makhado  "Makhado"
label var Musina "Musina"
label var Thulamela "Thulamela"

drop if visit_date==date("18sep2021","DMY") | visit_date==date("24sep2021","DMY") | visit_date==date("25sep2021","DMY") | visit_date==date("02oct2021","DMY") | visit_date==date("09oct2021","DMY") | visit_date==date("10oct2021","DMY") | visit_date==date("16oct2021","DMY") | visit_date==date("23oct2021","DMY") | visit_date==date("24oct2021","DMY") | visit_date==date("15jan2022","DMY") | visit_date==date("30jan2022","DMY") | visit_date==date("29jan2022","DMY")| visit_date==date("30jan2022","DMY") | visit_date==date("12feb2022","DMY") | visit_date==date("22jan2022","DMY") | visit_date==date("05feb2022","DMY") | visit_date==date("08jan2022","DMY") | visit_date==date("23jan2022","DMY")  | visit_date==date("01jan2022","DMY") | visit_date==date("02jan2022","DMY") | visit_date==date("16jan2022","DMY") | visit_date==date("06feb2022","DMY") | visit_date==date("13feb2022","DMY") | visit_date==date("09jan2022","DMY")

twoway (line Collins_Chabane visit_date, lwidth(thick))          ///
       (line Makhado visit_date, lwidth(thick))         ///
       (line Musina visit_date, lwidth(thick))         ///
	   (line Thulamela visit_date, lwidth(thick))        ///
       , legend(rows(2))                           ///
       ylabel(, angle(horizontal) format(%12.0fc)) ///
	   xtitle(Timepoint-Day) ///
	   title("Vhembe Vacc overtime by Sub-district,01Jan-12Feb2022") ///
	   ytitle(Number of Vaccines) yscale(range(0 .)) ylabel(#5, labsize(small) angle(horizontal))

graph export "$DATA/Vhembe.png", as(png) name("Graph") replace



// Vaccination by Sub-district- Waterberg

use "$DATA/Vaccination_long.dta", clear

keep if District_==5
keep SubDistrict visit_date Total_Vaccincation District_

encode SubDistrict, gen(SubDistrict_)
label list SubDistrict_ 


collapse (sum) Total_Vaccincation, by(visit_date District_ SubDistrict_)

reshape wide Total_Vaccincation , i(visit_date) j(SubDistrict_)


// rename the variables  
rename Total_Vaccincation1 BelaBela
rename Total_Vaccincation2 Lephalale 
rename Total_Vaccincation3 Mogalakwena
rename Total_Vaccincation4 Mookgophong_Modimo
rename Total_Vaccincation5 Thabazimbi

drop if visit_date==date("18sep2021","DMY") | visit_date==date("24sep2021","DMY") | visit_date==date("25sep2021","DMY") | visit_date==date("02oct2021","DMY") | visit_date==date("09oct2021","DMY") | visit_date==date("10oct2021","DMY") | visit_date==date("16oct2021","DMY") | visit_date==date("23oct2021","DMY") | visit_date==date("30oct2021","DMY") | visit_date==date("31oct2021","DMY")

// rename the variables 

label var BelaBela "BelaBela"
label var Lephalale  "Lephalale"
label var Mogalakwena "Mogalakwena"
label var Mookgophong_Modimo "Mookgophong_Modimo"
label var Thabazimbi "Thabazimbi"

twoway (line BelaBela visit_date, lwidth(thick))            ///
       (line Lephalale visit_date, lwidth(thick))           ///
       (line Mogalakwena visit_date, lwidth(thick))         ///
	   (line Mookgophong_Modimo visit_date, lwidth(thick))  ///
	   (line Thabazimbi visit_date, lwidth(thick))  ///
       , legend(rows(2))                           ///
       ylabel(, angle(horizontal) format(%12.0fc)) ///
	   xtitle(Timepoint-Day) ///
	   title("Waterberg Vacc overtime by Sub-district,17Sep-29Oct21") ///
	   ytitle(Number of Vaccines) yscale(range(0 .)) ylabel(#5, labsize(small) angle(horizontal))

graph export "$DATA/Waterberg.png", as(png) name("Graph") replace



****** Provincial Analaysis ***************


use "$DATA/Vaccination_raw.dta", clear 

encode District, gen(District_)
encode SubDistrict, gen(SubDistrict_)


// Create a "wide" version of the data

describe

collapse (sum) Total_Vaccincation , by(visit_date District_)


keep Total_Vaccincation visit_date District_ 

// reshape the data from "long" to "wide"

reshape wide Total_Vaccincation, i(visit_date) j(District_) 

//reshape wide Total_Vaccincation District_, i(visit_date) j(phc)
br 


// tsset time series data with panels
//tsset District_ visit_date, daily


// label the variables
label var Total_Vaccincation1 "Capricorn"
label var Total_Vaccincation2 "Mopani"
label var Total_Vaccincation3 "Sekhukhune"
label var Total_Vaccincation4 "Vhembe"
label var Total_Vaccincation5 "Waterberg"

// rename the variables  
rename Total_Vaccincation1 Capricorn
rename Total_Vaccincation2 Mopani
rename Total_Vaccincation3 Sekhukhune
rename Total_Vaccincation4 Vhembe
rename Total_Vaccincation5 Waterberg

describe
list  Capricorn Mopani Sekhukhune Vhembe Waterberg ///
     in -5/l, abbreviate(13)
	 
drop if visit_date==date("24sep2021","DMY") | visit_date==date("25sep2021","DMY") | visit_date==date("10oct2021","DMY") | visit_date==date("18sep2021","DMY") | visit_date==date("09oct2021","DMY") |visit_date==date("19sep2021","DMY") |visit_date==date("24oct2021","DMY")

br 
	 
twoway (line Capricorn visit_date, lwidth(thick))       ///
       (line Mopani visit_date, lwidth(thick))          ///
       (line Sekhukhune visit_date, lwidth(thick))      ///
	   (line Vhembe visit_date, lwidth(thick))          ///
	   (line Waterberg visit_date, lwidth(thick))       ///
       , legend(rows(2))                                ///
       ylabel(, angle(horizontal) format(%12.0fc))
	   

**********Capricorn-Median-Minumun-Maximum*************

	   
use "$DATA/Vaccination_raw.dta", clear 

encode District, gen(District_)
encode SubDistrict, gen(SubDistrict_)
label var visit_date "Days"

keep if District_==1

drop if visit_date==date("24sep2021","DMY") | visit_date==date("25sep2021","DMY") | visit_date==date("10oct2021","DMY") | visit_date==date("18sep2021","DMY") | visit_date==date("02oct2021","DMY") | visit_date==date("09oct2021","DMY") | visit_date==date("16oct2021","DMY") | visit_date==date("23oct2021","DMY") | visit_date==date("24oct2021","DMY")

describe
	   
bysort Facility: egen Medvacc=median(Total_Vaccincation)
bysort Facility: egen Minvacc=min(Total_Vaccincation)
bysort Facility: egen Maxvacc=max(Total_Vaccincation)

bysort Facility : keep if _n==1
sort District
br District Facility Medvacc Minvacc Maxvacc

encode Facility, gen(Facility_)
drop if Facility=="lp Univ of Limpopo NMS"
tab Facility_

count 
count if Medvacc>=20

twoway ///
	(scatter Medvacc visit_date, mlabel(Facility_)) ///
		if Medvacc>=20 ///
		, ///
		title("Capri-PHCs with Median Vacci Greather than 19") ///
		note("(31/47) Facilities with Median Greater than 19 ", size(vsmall)) 
		

graph export "$DATA/Capricorn_Median.png", as(png) name("Graph") replace
	   
**********Mopani- Median-Minumun-Maximum *************

	   
use "$DATA/Vaccination_raw.dta", clear 

label var visit_date "Days"

encode District, gen(District_)
encode SubDistrict, gen(SubDistrict_)

keep if District_==2

drop if visit_date==date("24sep2021","DMY") | visit_date==date("25sep2021","DMY") | visit_date==date("10oct2021","DMY") | visit_date==date("18sep2021","DMY") | visit_date==date("02oct2021","DMY") | visit_date==date("09oct2021","DMY") | visit_date==date("16oct2021","DMY") | visit_date==date("23oct2021","DMY") | visit_date==date("24oct2021","DMY")

describe
	   
bysort Facility: egen Medvacc=median(Total_Vaccincation)
bysort Facility: egen Minvacc=min(Total_Vaccincation)
bysort Facility: egen Maxvacc=max(Total_Vaccincation)

bysort Facility : keep if _n==1
sort District
br District Facility Medvacc Minvacc Maxvacc

encode Facility, gen(Facility_)
tab Facility_

count 
count if Medvacc>=20

twoway ///
	(scatter Medvacc visit_date, mlabel(Facility_)) ///
		if Medvacc>=20 ///
		, ///
		title("Mopani-PHCs with Median Vacci Greather 19") ///
		note("(25/44) Facilities with Median Greater than 19 ", size(vsmall)) 
		
graph export "$DATA/Mopani_Median.png", as(png) name("Graph") replace



********** Sekhukhune- Median-Minumun-Maximum *************

	   
use "$DATA/Vaccination_raw.dta", clear 

label var visit_date "Days"
encode District, gen(District_)
encode SubDistrict, gen(SubDistrict_)

keep if District_==3

drop if visit_date==date("24sep2021","DMY") | visit_date==date("25sep2021","DMY") | visit_date==date("10oct2021","DMY") | visit_date==date("18sep2021","DMY") | visit_date==date("02oct2021","DMY") | visit_date==date("09oct2021","DMY") | visit_date==date("16oct2021","DMY") | visit_date==date("23oct2021","DMY") | visit_date==date("24oct2021","DMY")

describe
	   
bysort Facility: egen Medvacc=median(Total_Vaccincation)
bysort Facility: egen Minvacc=min(Total_Vaccincation)
bysort Facility: egen Maxvacc=max(Total_Vaccincation)

bysort Facility : keep if _n==1
sort District
br District Facility Medvacc Minvacc Maxvacc

encode Facility, gen(Facility_)
tab Facility_

count 
count if Medvacc>=20

twoway ///
	(scatter Medvacc visit_date, mlabel(Facility_)) ///
		if Medvacc>=20 ///
		, ///
		title("Sekhukhune-PHCs with Median Vacci Greather than 19") ///
		note("(29/57) Facilities with Median Greater than 19 ", size(vsmall)) 
		
graph export "$DATA/Sekhukhune_Median.png", as(png) name("Graph") replace


********** Vhembe- Median-Minumun-Maximum *************

	   
use "$DATA/Vaccination_raw.dta", clear 

label var visit_date "Days"
encode District, gen(District_)
encode SubDistrict, gen(SubDistrict_)

keep if District_==4

drop if visit_date==date("24sep2021","DMY") | visit_date==date("25sep2021","DMY") | visit_date==date("10oct2021","DMY") | visit_date==date("18sep2021","DMY") | visit_date==date("02oct2021","DMY") | visit_date==date("09oct2021","DMY") | visit_date==date("16oct2021","DMY") | visit_date==date("23oct2021","DMY") | visit_date==date("24oct2021","DMY") | visit_date==date("30oct2021","DMY") | visit_date==date("31oct2021","DMY")

describe
gen week_days= dow(visit_date)
br week_days visit_date
	   
bysort Facility: egen Medvacc=median(Total_Vaccincation)
bysort Facility: egen Minvacc=min(Total_Vaccincation)
bysort Facility: egen Maxvacc=max(Total_Vaccincation)

bysort Facility : keep if _n==1
sort District
br District Facility Medvacc Minvacc Maxvacc

encode Facility, gen(Facility_)
tab Facility_

count 
count if Medvacc>=20

twoway ///
	(scatter Medvacc visit_date, mlabel(Facility_)) ///
		if Medvacc>=20 ///
		, ///
		title("Vhembe-PHCs with Median Vacci Greather than 19") ///
		note("(25/50) Facilities with Median Greater than 19 ", size(vsmall)) 
		
graph export "$DATA/Vhembe_Median.png", as(png) name("Graph") replace



********** Waterberg- Median-Minumun-Maximum *************
	   
use "$DATA/Vaccination_raw.dta", clear 

label var visit_date "Days"
encode District, gen(District_)
encode SubDistrict, gen(SubDistrict_)

keep if District_==5

drop if visit_date==date("24sep2021","DMY") | visit_date==date("25sep2021","DMY") | visit_date==date("10oct2021","DMY") | visit_date==date("18sep2021","DMY") | visit_date==date("02oct2021","DMY") | visit_date==date("09oct2021","DMY") | visit_date==date("16oct2021","DMY") | visit_date==date("23oct2021","DMY") | visit_date==date("24oct2021","DMY")

describe
gen week_days= dow(visit_date)
br week_days visit_date
	   
bysort Facility: egen Medvacc=median(Total_Vaccincation)
bysort Facility: egen Minvacc=min(Total_Vaccincation)
bysort Facility: egen Maxvacc=max(Total_Vaccincation)

bysort Facility : keep if _n==1
sort District
br District Facility Medvacc Minvacc Maxvacc

encode Facility, gen(Facility_)
tab Facility_

count 
count if Medvacc>=20

twoway ///
	(scatter Medvacc visit_date, mlabel(Facility_)) ///
		if Medvacc>=20 ///
		, ///
		title("Waterberg-PHCs with Median Vacci Greather than 19") ///
		note("(22/35) Facilities with Median Greater than 19 ", size(vsmall)) 
		
graph export "$DATA/Waterberg_Median.png", as(png) name("Graph") replace




***************** Hospital vs PHC: CAPRICORN ****************


use "$DATA/Vaccination_Import.dta", clear

gen Total_Vaccincation=(Sumofsecond_dose_vaccinations+Sumoffirst_dose_vaccinations)
keep if visit_date>=date("17sep2021","DMY")
collapse (sum) Total_Vaccincation Sumofsecond_dose_vaccinations Sumoffirst_dose_vaccinations, by(visit_date District phc)

// create a numeric variable for country
encode District, gen(District_)
list visit_date District District_  /// 
     in -9/l, sepby(visit_date) abbreviate(13)
	 
label list District_


// Create a "wide" version of the data

keep if District_==1
keep visit_date Total_Vaccincation  Sumofsecond_dose_vaccinations Sumoffirst_dose_vaccinations phc

reshape wide Total_Vaccincation Sumofsecond_dose_vaccinations Sumoffirst_dose_vaccinations, i(visit_date) j(phc)

rename Total_Vaccincation0 Hopistal
rename Total_Vaccincation1 PHC
rename Total_Vaccincation2 Outreach 
br visit_date Hopistal PHC Outreach 


***************** Hospital vs PHC: Mopani ****************

use "$DATA/Vaccination_Import.dta", clear

gen Total_Vaccincation=(Sumofsecond_dose_vaccinations+Sumoffirst_dose_vaccinations)
keep if visit_date>=date("17sep2021","DMY")
collapse (sum) Total_Vaccincation Sumofsecond_dose_vaccinations Sumoffirst_dose_vaccinations, by(visit_date District phc)

// create a numeric variable for country
encode District, gen(District_)
list visit_date District District_  /// 
     in -9/l, sepby(visit_date) abbreviate(13)
	 
label list District_


// Create a "wide" version of the data

keep if District_==2
keep visit_date Total_Vaccincation  Sumofsecond_dose_vaccinations Sumoffirst_dose_vaccinations phc

reshape wide Total_Vaccincation Sumofsecond_dose_vaccinations Sumoffirst_dose_vaccinations, i(visit_date) j(phc)

rename Total_Vaccincation0 Hopistal
rename Total_Vaccincation1 PHC
rename Total_Vaccincation2 Outreach 
br visit_date Hopistal PHC Outreach 

***************** Hospital vs PHC: Sekhukhune ****************


use "$DATA/Vaccination_Import.dta", clear

gen Total_Vaccincation=(Sumofsecond_dose_vaccinations+Sumoffirst_dose_vaccinations)
keep if visit_date>=date("17sep2021","DMY")
collapse (sum) Total_Vaccincation Sumofsecond_dose_vaccinations Sumoffirst_dose_vaccinations, by(visit_date District phc)

// create a numeric variable for country
encode District, gen(District_)
list visit_date District District_  /// 
     in -9/l, sepby(visit_date) abbreviate(13)
	 
label list District_


// Create a "wide" version of the data

keep if District_==3
keep visit_date Total_Vaccincation  Sumofsecond_dose_vaccinations Sumoffirst_dose_vaccinations phc

reshape wide Total_Vaccincation Sumofsecond_dose_vaccinations Sumoffirst_dose_vaccinations, i(visit_date) j(phc)

rename Total_Vaccincation0 Hopistal
rename Total_Vaccincation1 PHC
//rename Total_Vaccincation2 Outreach 
br visit_date Hopistal PHC 



***************** Hospital vs PHC: Vhembe ****************


use "$DATA/Vaccination_Import.dta", clear

gen Total_Vaccincation=(Sumofsecond_dose_vaccinations+Sumoffirst_dose_vaccinations)
keep if visit_date>=date("17sep2021","DMY")
collapse (sum) Total_Vaccincation Sumofsecond_dose_vaccinations Sumoffirst_dose_vaccinations, by(visit_date District phc)

// create a numeric variable for country
encode District, gen(District_)
list visit_date District District_  /// 
     in -9/l, sepby(visit_date) abbreviate(13)
	 
label list District_


// Create a "wide" version of the data

keep if District_==4
keep visit_date Total_Vaccincation  Sumofsecond_dose_vaccinations Sumoffirst_dose_vaccinations phc

reshape wide Total_Vaccincation Sumofsecond_dose_vaccinations Sumoffirst_dose_vaccinations, i(visit_date) j(phc)

rename Total_Vaccincation0 Hopistal
rename Total_Vaccincation1 PHC
rename Total_Vaccincation2 Outreach 
br visit_date Hopistal PHC Outreach 


***************** Hospital vs PHC: Waterberg ****************


use "$DATA/Vaccination_Import.dta", clear

gen Total_Vaccincation=(Sumofsecond_dose_vaccinations+Sumoffirst_dose_vaccinations)
keep if visit_date>=date("17sep2021","DMY")
collapse (sum) Total_Vaccincation Sumofsecond_dose_vaccinations Sumoffirst_dose_vaccinations, by(visit_date District phc)

// create a numeric variable for country
encode District, gen(District_)
list visit_date District District_  /// 
     in -9/l, sepby(visit_date) abbreviate(13)
	 
label list District_


// Create a "wide" version of the data

keep if District_==5
keep visit_date Total_Vaccincation  Sumofsecond_dose_vaccinations Sumoffirst_dose_vaccinations phc

reshape wide Total_Vaccincation Sumofsecond_dose_vaccinations Sumoffirst_dose_vaccinations, i(visit_date) j(phc)

rename Total_Vaccincation0 Hopistal
rename Total_Vaccincation1 PHC
rename Total_Vaccincation2 Outreach 
br visit_date Hopistal PHC Outreach 

gen week_days = dow(visit_date)


*** Counting Number of active PHC sites 

use "$DATA/Vaccination_Import.dta", clear 


label list 
keep if phc==3 & visit_date>=date("29aug2022","DMY") & visit_date<=date("03sep2022","DMY")

count 
br visit_date
sort visit_date

bysort Facility : keep if _n==1
count 

encode District, gen(District_)
label list District_ 

count if District_==1
count if District_==2
count if District_==3
count if District_==4
count if District_==5

 
 *** Counting Number of active Outreach sites 

use "$DATA/Vaccination_Import.dta", clear 


keep if phc==3 & visit_date>=date("01aug2022","DMY") & visit_date<=date("06aug2022","DMY")

label list phc

count 
sort visit_date
br visit_date

bysort Facility : keep if _n==1
count 

encode District, gen(District_)
label list District_ 

count if District_==1
count if District_==2
count if District_==3
count if District_==4
count if District_==5

