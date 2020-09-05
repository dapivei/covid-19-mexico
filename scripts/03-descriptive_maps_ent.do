/*=================================================================

GEOGRAPHIC DISTRIBUTION MAPS (CASOS Y DECESOS), ASOCIADOS 
AL DOCUMENTO "RETRASOS EN EL REPORTE DE MUERTES Y SUS IMPLICACIONES
EN LA EVOLUCION DEL COVID-19 EN MÉXICO: CASO NAYARIT."

© Daniela Pinto Veizaga, 2020
==================================================================*/


/* ++++++++++++++++++++++++++++++++++++++++++
			1- SET UP ENVIRONMENT
++++++++++++++++++++++++++++++++++++++++++ */

* Limpiamos el ambiente

clear
set scheme s1color

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
			2- GENERAMOS VARIABLES DE INTERÉS
++++++++++++++++++++++++++++++++++++++++++ */

* Identificamos a los pacientes con covid

gen covid=resultado==1
label variable covid "con prueba confirmatoria de COVID-19"
* Identificamos a los pacientes que fallecieron

gen deceso=fecha_def!="9999-99-99"
label variable deceso "con fecha de defuncion registrada"


* Sumamos casos y decesos dentro de cada municipio

collapse (sum) covid deceso, by(entidad_res)

*sort statemun
cd ".."
cd "01-input/01-shapefiles"
*save "casos_decesos_ent.dta", replace


/* ++++++++++++++++++++++++++++++++++++++++++
			3- MAPAS
++++++++++++++++++++++++++++++++++++++++++ */

* Creamos archivos en formato .dta

*shp2dta using 00ent, database(entsmex) ///
*    coordinates(coordents) genid(id) gencentroids(c) replace
	
* Llamamos archivos en formato .dta
use entsmex.dta, clear
destring CVEGEO, gen(entidad_res) force

sort entidad_res
merge 1:1 entidad_res using casos_decesos_ent.dta
drop if _merge==2

replace covid=0 if covid==.
replace deceso=0 if deceso ==.
drop _merge

* Merge con data de poblacion 2015 (Encuesta Intercensal 2015)
merge 1:1 entidad_res using poblacion_ent.dta
drop if _merge==2

* Genera variable de interés casos y decesos por cada 10000 habitantes
gen covid_pop = (covid/poblacion_2015)*10000
label variable covid_pop "casos con covid por cada 10000 habitantes"
gen deceso_pop = (deceso/poblacion_2015)*10000
label variable deceso_pop "decesos con covid por cada 10000 habitantes"

* Generar .dta con labels 
*gen labtype  = 1
*append using entsmex.dta
*replace labtype = 2 if labtype==.
*replace NOMGEO = string(covid_pop, "%3.2f") if labtype ==2
*keep x_c y_c NOMGEO labtype
*save maplabels_ent, replace

* Otras estadísticas

*sum casos if entidad_res=18, det
*poblacion en el mapa de base de datos
*sum covid, det

*cd ".."
*cd ".."
*cd "04-output/01-mapas"
*label(data(entsmex.dta) xcoord(_X)  ycoord(_Y) by(NOMGEO))               ///
*label(data(coordents.dta) xcoord(_X)  ycoord(_Y) label (_ID) by(_ID))    ///



* Decesos en México (absolutos)

spmap deceso using coordents, id(id)                                       ///
clmethod(custom) clbreaks(0 500 1000 2000 4000 6000 10000 15000 20000)     ///
osize(vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin)      ///
fcolor(Reds)                                                               ///
label(data(maplabels_ent) xcoord(x_c)  ycoord(y_c)                         ///
label(NOMGEO) by(labtype)  size(*0.4 ..) pos(0 0) )                        ///
legenda(off)  
                                                          
graph save "decesoscovid_mexico_ent.gph",  replace 
graph export "decesoscovid_mexico_ent.png", as(png) replace


* Casos en México (absolutos)

spmap covid using coordents, id(id)                                        ///
clmethod(custom) clbreaks(0 500 2500 5000 10000 30000 50000 80000 110000)  ///
osize(vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin)      ///
fcolor(Reds)                                                               ///
label(data(maplabels_ent) xcoord(x_c)  ycoord(y_c)                         ///
label(NOMGEO) by(labtype)  size(*0.4 ..) pos(0 0) )                        ///
legenda(off)  

graph save "casoscovid_mexico_ent.gph", replace
graph export "casoscovid_mexico_ent.png", as(png) replace



* Decesos en México (ajustado por poblacion)

spmap deceso_pop using coordents, id(id)                                   ///
clmethod(custom) clbreaks(0 2 3 6 9 12 15 30 70)                           ///
osize(vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin)      ///
fcolor(Reds)                                                               ///
label(data(maplabels_ent) xcoord(x_c)  ycoord(y_c)                         ///
label(NOMGEO) by(labtype)  size(*0.4 ..) pos(0 0) )                        ///
legenda(off)  
                                                          
graph save "decesoscovid_mexico_ent_pop.gph",  replace 
graph export "decesoscovid_mexico_ent_pop.png", as(png) replace


* Casos en México (ajustado por poblacion)

spmap covid_pop using coordents, id(id)                                    ///
clmethod(custom) clbreaks(0 10 20 40 80 160 200 250 300)                   ///
osize(vvthin vvthin vvthin vvthin  vvthin  vvthin vvthin vvthin vvthin)    ///
fcolor(Reds)                                                               ///
label(data(maplabels_ent) xcoord(x_c)  ycoord(y_c)                         ///
label(NOMGEO) by(labtype)  size(*0.4 ..) pos(0 0) )                        ///
legenda(off)      
graph save "casoscovid_mexico_ent_pop.gph", replace
graph export "casoscovid_mexico_ent_pop.png", as(png) replace

                
* Combine decesos por cada 10000 habitantes
graph combine "decesoscovid_nayarit_mun_pop.gph" "decesoscovid_mexico_ent_pop.gph",                    ///
      plotregion(color(white))                                                                         ///
	  title("Nayarit y el resto de México: Decesos confirmados por c/ 10,000 habitantes",              ///
	  size(*.8))                                                                                       ///
	  subtitle("Desagregación por Entidades", size(*.8))                                               ///
	  graphregion(margin(zero))                                                                        /// 
	  col(2)                                                                                           ///
	  ysize(5)                                                                                         ///
	  xsize(8)                                                                                         ///
	  iscale(*1)                                                                                       ///
      note("Fuente:  Base de datos dispuesta al público por la Secretaría de Salud de México.", size(*0.8))
graph export "decesos_covid_ent_pop.tif", as(tif) replace
graph export "decesos_covid_ent_pop.png", as(png) replace




* Combine casos covid por cada 10000 habitantes

graph combine "casoscovid_nayarit_mun_pop.gph" "casoscovid_mexico_ent_pop.gph",                        ///
	  plotregion(color(white))                                                                         ///
	  title("Nayarit y el resto de México: Casos confirmados por c/ 10,000 habitantes",                ///
	  size(*.8))                                                                                       ///
	  subtitle("Desagregación por Entidades", size(*.8))                                               ///
	  graphregion(margin(zero))                                                                        /// 
	  col(2)                                                                                           ///
	  ysize(5)                                                                                         ///
	  xsize(8)                                                                                         ///
	  iscale(*1)                                                                                       ///
      note("Fuente:  Base de datos dispuesta al público por la Secretaria de Salud de México.", size(*0.8))
graph export "casos_covid_ent_pop.tif", as(tif) replace
graph export "casos_covid_ent_pop.png", as(png) replace
