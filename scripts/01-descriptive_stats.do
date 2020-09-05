/*=================================================================

DESCRIPTIVE STATS ASOCIADOS AL DOCUMENTO "RETRASOS EN EL REPORTE 
DE MUERTES Y SUS IMPLICACIONES EN LA EVOLUCION DEL COVID-19 
EN MÉXICO: CASO NAYARIT."

© Daniela Pinto Veizaga, 2020
==================================================================*/

/* ++++++++++++++++++++++++++++++++++++++++++
			1- SET UP ENVIRONMENT
++++++++++++++++++++++++++++++++++++++++++ */

* Limpiamos el ambiente

clear

* Set working directory to locate data

cd "/Users/danielapintoveizaga/"
cd "INSTITUTO TECNOLOGICO AUTONOMO DE MEXICO/"
cd "EMILIO GUTIERREZ FERNANDEZ - Inv_Aplicada_2020_2/"
cd "avances-estudiantes/Daniela Pinto Veizaga - Nayarit/02-data"

* Definimos variable local para obtener la última fecha

local yesterday : display %tdYND date("`c(current_date)'", "DMY") - 1

* Call latest .csv file

import delimited "`yesterday'COVID19MEXICO.csv"

/* ++++++++++++++++++++++++++++++++++++++++++
			2- CONSTRUCCION 
			VARIABLES INDICADORES
++++++++++++++++++++++++++++++++++++++++++ */

* Identificamos a los pacientes con covid

gen covid=resultado==1
label variable covid "con prueba confirmatoria de COVID-19"

* Identificamos a los pacientes que fallecieron

gen deceso=fecha_def!="9999-99-99"
label variable deceso "con fecha de defuncion registrada"

* Definimos indicadora para Nayarit

gen nayarit=entidad_res==18
label variable nayarit "reside en Nayarit"

* Crea grupos de edad

set trace on
forvalues bot = 0(10)80 {
    local top = `bot' + 10
	local limit = `bot'+1
	if `bot' < 10 {
	gen edad`bot'_`top' = edad >= `bot' & edad <= `top'
	label variable edad`bot'_`top' "entre `bot' y `top'"
	}
	else if `bot' >= 80 {
	gen edad`limit'_plus=edad > `bot'
	label variable edad`limit'_plus "`limit' o más"
	}
	else {
	gen edad`limit'_`top' = edad > `bot' & edad <= `top'
	label variable edad`limit'_`top' "entre `limit' y `top'"
	}
	}
set trace off

* Generación de variables indicadores: sexo, lengua indigena, conmorbilidades

local originals sexo habla_lengua_indig obesidad diabetes tabaquismo epoc ///
asma hipertension cardiovascular renal_cronica inmusupr 

foreach original of local originals {
	gen `original'_dummy=`original'==1
	label variable `original'_dummy "`original'"
}

label variable tabaquismo_dummy "fuma"
label variable cardiovascular_dummy "enfermedad cardiovasculares"
label variable renal_cronica_dummy "enfermedad renal cronica"
label variable inmusupr_dummy "inmunosupresion"
label variable sexo_dummy "mujer"
label variable habla_lengua_indig_dummy "habla una lengua indigena"

* Más variables relacionadas con conmorbilidades

gen conmorbilidades=obesidad_dummy + diabetes_dummy + tabaquismo_dummy    ///
+ epoc_dummy + asma_dummy + hipertension_dummy+ cardiovascular_dummy      ///
+ renal_cronica_dummy + inmusupr_dummy        
label variable conmorbilidades "numero de conmorbilidades"
gen conmorbilidades_morethan1=conmorbilidades>1
label variable conmorbilidades_morethan1 "mas de una conmorbilidad"
rename edad age

/* ++++++++++++++++++++++++++++++++++++++++++
			3- SUMMARY: TABLAS COMPARATIVAS:
++++++++++++++++++++++++++++++++++++++++++ */

* Definimos path de resguardo de los outputs del do-file

cd ".."
cd "04-output/02-tablas"

* Definimos descriptives, todas las dummys que creamos y los grupos de edad 

global descriptives "*_dummy edad* "

* Decesos Nayarit vs resto del país

balancetable nayarit $descriptives using "nayarit_vs_resto.xls"           ///
 if covid==1 & deceso==1, varlabels replace                               ///
 ctitles("Resto del Pais" "Nayarit" "Diferencia")

balancetable nayarit $descriptives using "nayarit_vs_resto.tex"           ///
 if covid==1 & deceso==1, varlabels replace                               /// 
 ctitles("Resto del Pais" "Nayarit" "Diferencia")
 
* Observables entre casos y decesos por covid en Nayarit
balancetable deceso $descriptives using "casos_vs_decesos_nayarit.xls"    ///
 if covid==1 & nayarit==1, varlabels replace                              ///
 ctitles("Casos confirmados" "Decesos confirmados" "Diferencia")

 balancetable deceso $descriptives using "casos_vs_decesos_nayarit.tex"   ///
 if covid==1 & nayarit==1, varlabels replace                              ///
 ctitles("Casos confirmados" "Decesos confirmados" "Diferencia")



