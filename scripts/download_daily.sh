#!/bin/bash

echo -e "\n Inicia descarga y descompresión\n"
PATH='covid-data/datos_abiertos/raw'
cd ..
cd $PATH
name_file='datos_abiertos_covid19.zip'
URL='http://datosabiertos.salud.gob.mx/gobmx/salud/datos_abiertos/'$name_file
/usr/local/bin/wget $URL
/usr/bin/tar -xf ar -xf $name_file
/bin/rm $name_file
echo -e "\nTerminó descarga y descompresión\n"
