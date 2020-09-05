/*=================================================================

DISTRIBUCIÓN GEOGRÁFICA DE CASOS Y DECESOS POR MUNICIPIO. DO-FILE
ASOCIADO AL DOCUMENTO "RETRASOS EN EL REPORTE DE MUERTES Y SUS 
IMPLICACIONES EN LA EVOLUCION DEL COVID-19 EN MÉXICO: CASO NAYARIT."

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

collapse (sum) covid deceso, by(entidad_res municipio_res)
drop if municipio_res==999
gen statemun=entidad_res*1000+municipio_res

*sort statemun
cd ".."
cd "01-input/01-shapefiles"
save "casos_decesos_mpio.dta", replace


/* ++++++++++++++++++++++++++++++++++++++++++
			3- MAPAS
++++++++++++++++++++++++++++++++++++++++++ */

* Creamos archivos en formto .dta


*shp2dta using national_municipal, data(munsmex) coor(coordmuns)         ///
*genid(id) gencentroids(c) replace

* Llamamos archivos en formato .dta
use munsmex.dta, clear
destring CVEGEO, gen(statemun) force

sort statemun
merge 1:1 statemun using casos_decesos_mpio.dta

drop if _merge==2

gen edo=floor(statemun/1000)
replace covid=0 if covid==.
replace deceso=0 if deceso ==.

* Genera variables de interés: ajustes por población 
gen covid_pop = (covid/POB1)*10000
gen deceso_pop = (deceso/POB1)*10000
*sum casos if entidad_res=18, det
*poblacion en el mapa de base de datos
*sum covid, det

*cd ".."
*cd ".."
*cd "04-output/01-mapas"

* Generar .dta con labels 
*gen labtype  = 1
*append using munsmex.dta
*replace labtype = 2 if labtype==.
*replace NOM_MUN = string(covid_pop, "%3.2f") if labtype ==2
*drop if NOM_ENT!="Nayarit"
*keep x_c y_c NOM_MUN labtype
*save maplabels_mun_nay, replace

* Decesos en México (absolutos)

spmap deceso using coordmuns, id(id)                                        ///
clmethod(custom) clbreaks(0 50 100 200 400 600 1000 1500 2500)              ///
osize(vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin)       ///
fcolor(Reds)                                                                ///
legenda(off)  
                                                          
graph save "decesoscovid_mexico_mun.gph",  replace 
graph export "decesoscovid_mexico_mun.png", as(png) replace



* Decesos en Nayarit (absolutos)

spmap deceso using coordmuns if edo==18, id(id)                             ///
clmethod(custom) clbreaks(0 50 100 200 400 600 1000 1500 2500)              ///
legtitle("Decesos confirmados")                                             ///
legend(size(vsmall)) legorder(lohi) legend(position(7))                     ///
osize(vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin)       ///
fcolor(Reds)                                                                ///
label(data(maplabels_mun_nay) xcoord(x_c)  ycoord(y_c)                      ///
label(NOM_MUN) by(labtype)  size(*0.2 ..) pos(0 0) )                        ///
fysize(60)                                                                  ///
fxsize(60)                                         
graph save "decesoscovid_nayarit_mun.gph",  replace 
graph export "decesoscovid_nayarit_mun.png", as(png) replace


* Combine decesos absolutos
graph combine "decesoscovid_nayarit_mun.gph" "decesoscovid_mexico_mun.gph", ///
      plotregion(color(white))                                              ///
	  title("Nayarit y el resto de México: Decesos (números absolutos)",    ///
	  size(*.8))                                                            ///
	  subtitle("Desagregación por Municipios", size(*.8))                   ///
	  graphregion(margin(zero))                                             /// 
	  col(2)                                                                ///
	  ysize(5)                                                              ///
	  xsize(8)                                                              ///
	  iscale(*1.1)                                                          ///
      note("Fuente:  Base de datos dispuesta al público por la Secretaría de Salud de México.", size(*0.8))
graph export "decesos_covid_mun.tif", as(tif) replace
graph export "decesos_covid_mun.png", as(png) replace


* Casos en México (absolutos)

spmap covid using coordmuns, id(id)                                         ///
clmethod(custom) clbreaks(0 50 100 200 400 800 1600 10000 20000)            ///
legenda(off)                                                                ///
osize(vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin)       ///
fcolor(Reds)                                                                
                     
graph save "casoscovid_mexico_mun.gph", replace
graph export "casoscovid_mexico_mun.png", as(png) replace



* Casos Nayarit (absolutos)

spmap covid using coordmuns if edo==18, id(id)                              ///
clmethod(custom) clbreaks(0 50 100 200 400 800 1600 10000 20000)            ///
legtitle("Casos confirmados")                                               ///
legend(size(vsmall)) legorder(lohi) legend(position(7))                     ///
osize(vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin)       ///
fcolor(Reds)                                                                ///
label(data(maplabels_mun_nay) xcoord(x_c)  ycoord(y_c)                      ///
label(NOM_MUN) by(labtype)  size(*0.4 ..) pos(0 0) )                        ///
fysize(60)                                                                  ///
fxsize(60)                                                   
graph save "casoscovid_nayarit_mun.gph",  replace 
graph export "casoscovid_nayarit_mun.png", as(png) replace 

* Combine casos absolutos

graph combine "casoscovid_nayarit_mun.gph" "casoscovid_mexico_mun.gph",     ///
	  plotregion(color(white))                                              ///
	  title("Nayarit y el resto de México: Casos confirmados (absolutos)",  ///
	  size(*.8))                                                            ///
	  subtitle("Desagregación por Municipios", size(*.8))                   ///
	  graphregion(margin(zero))                                             /// 
	  col(2)                                                                ///
	  ysize(5)                                                              ///
	  xsize(8)                                                              ///
	  iscale(*1.1)                                                          ///
      note("Fuente:  Base de datos dispuesta al público por la Secretaría de Salud de México.", size(*0.8))
graph export "casos_covid_mun.tif", as(tif) replace
graph export "casos_covid_mun.png", as(png) replace



* Casos en México (por cada 10000 habitantes)

spmap covid_pop using coordmuns, id(id)                                     ///
clmethod(custom) clbreaks(0 10 20 40 80 160 200 250 300)                    ///
osize(vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin)       ///
fcolor(Reds)                                                                ///
legenda(off)  
graph save "casoscovid_mexico_mun_pop.gph", replace
graph export "casoscovid_mexico_mun_pop.png", as(png) replace



* Casos Nayarit (por cada 10000 habitantes)

spmap covid_pop using coordmuns if edo==18, id(id)                          ///
clmethod(custom) clbreaks(0 10 20 40 80 160 200 250 300)                    ///
legtitle("Casos confirmados")                                               ///
legend(size(vsmall)) legorder(lohi) legend(position(7))                     ///
osize(vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin)       ///
fcolor(Reds)                                                                ///
label(data(maplabels_mun_nay) xcoord(x_c)  ycoord(y_c)                      ///
label(NOM_MUN) by(labtype)  size(*0.4 ..) pos(0 0) )                        ///
fysize(60)                                                                  ///
fxsize(60)                                                     
graph save "casoscovid_nayarit_mun_pop.gph",  replace 
graph export "casoscovid_nayarit_mun_pop.png", as(png) replace 


* Combine casos covid por cada 10000 habitantes

graph combine "casoscovid_nayarit_mun_pop.gph" "casoscovid_mexico_mun_pop.gph",                        ///
	  plotregion(color(white))                                                                         ///
	  title("Nayarit y el resto de México: Casos confirmados por c/ 10,000 habitantes", size(*.8))     ///
	  subtitle("Desagregación por Municipios", size(*.8))                                              ///
	  graphregion(margin(zero))                                                                        /// 
	  col(2)                                                                                           ///
	  ysize(5)                                                                                         ///
	  xsize(8)                                                                                         ///
	  iscale(*1)                                                                                       ///
      note("Fuente:  Base de datos dispuesta al público por la Secretaria de Salud de México.", size(*0.8))
graph export "casos_covid_mun_pop.tif", as(tif) replace
graph export "casos_covid_mun_pop.png", as(png) replace



* Decesos en México (por cada 10000 habitantes)

spmap deceso_pop using coordmuns, id(id)                                    ///
clmethod(custom) clbreaks(0 2 3 6 9 12 15 30 70)                            ///
osize(vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin)       ///
fcolor(Reds)                                                                ///
legenda(off)  
                                                          
graph save "decesoscovid_mexico_mun_pop.gph",  replace 
graph export "decesoscovid_mexico_mun_pop.png", as(png) replace



* Decesos en Nayarit (por cada 10000 habitantes)

spmap deceso_pop using coordmuns if edo==18, id(id)                         ///
clmethod(custom) clbreaks(0 2 3 6 9 12 15 30 70)                            ///
osize(vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin)       ///
legtitle("Decesos confirmados")                                             ///
legend(size(vsmall)) legorder(lohi) legend(position(7))                     ///
fcolor(Reds)                                                                ///
label(data(maplabels_mun_nay) xcoord(x_c)  ycoord(y_c)                      ///
label(NOM_MUN) by(labtype)  size(*0.4 ..) pos(0 0) )                        ///
fysize(60)                                                                  ///
fxsize(60)                                             
graph save "decesoscovid_nayarit_mun_pop.gph",  replace 
graph export "decesoscovid_nayarit_mun_pop.png", as(png) replace


* Combine decesos por cada 10000 habitantes
graph combine "decesoscovid_nayarit_mun_pop.gph" "decesoscovid_mexico_mun_pop.gph",                    ///
      plotregion(color(white))                                                                         ///
	  title("Nayarit y el resto de México: Decesos confirmados por c/ 10,000 habitantes",              ///
	  size(*.8))                                                                                       ///
	  subtitle("Desagregación por Municipios", size(*.8))                                              ///
	  graphregion(margin(zero))                                                                        /// 
	  col(2)                                                                                           ///
	  ysize(5)                                                                                         ///
	  xsize(8)                                                                                         ///
	  iscale(*1)                                                                                       ///
      note("Fuente:  Base de datos dispuesta al público por la Secretaría de Salud de México.", size(*0.8))
graph export "decesos_covid_mun_pop.tif", as(tif) replace
graph export "decesos_covid_mun_pop.png", as(png) replace
