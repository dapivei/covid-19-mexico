#============================================================================

# DOWNLOADS DATA FROM DIRECCION GENERAL DE EPIDEMIOLOGIA RELATED TO COVID-19

#============================================================================

def download(days_ago):
    """
    Retrieves data published by the mexican government, related to covid -19,
    from as many days ago, till current day.
    --------------------------
    input: integer that correspondes to number of days we want to go back
    output: csv files with data published by the mexican government
    """

    import datetime
    import os.path
    from datetime import date, timedelta
    import zipfile
    import requests
    import os
    PATH = 'covid-data/datos_abiertos/raw'
    os.chdir("..")
    os.chdir(PATH)
    for i in range(1, days_ago+1):
        yesterday = date.today() - timedelta(i)
        year_yesterday= yesterday.strftime("%Y")[:2]
        month_yesterday = yesterday.strftime("%m")
        date_yesterday = yesterday.strftime("%d.%m.%Y")

        # url
        URL = 'http://datosabiertos.salud.gob.mx/gobmx/salud/datos_abiertos/historicos/' + month_yesterday + '/datos_abiertos_covid19_' + date_yesterday + '.zip'

        r = requests.get(URL)
        name_file = 'datos_abiertos_covid19_' + date_yesterday + '.zip'

        #retrieving data from the URL using get method
        with open(name_file, 'wb') as f:
            f.write(r.content)
        zip = zipfile.ZipFile(name_file)
        zip.extractall()
        os.remove(name_file)

        date_yesterday_list = date_yesterday.split(".")
        date_yesterday_newformat = year_yesterday + date_yesterday_list[1] + date_yesterday_list[0]
        csv_file_name = date_yesterday_newformat + 'COVID19MEXICO.csv'

        if os.path.isfile(csv_file_name) == True:

            print("Successfully downloaded " + csv_file_name)
        else:
            print("Error in download of " + csv_file_name)

        return("Download finished")

def download_latest():
    """
    Retrieves latest data published by the mexican government, related to covid -19
    --------------------------
    input: integer that correspondes to number of days we want to go back
    output: csv files with data published by the mexican government
    """
    import zipfile
    import requests
    import os
    PATH = 'covid-data/datos_abiertos/raw'
    os.chdir("..")
    os.chdir(PATH)
    name_file = 'datos_abiertos_covid19.zip'
    URL = 'http://datosabiertos.salud.gob.mx/gobmx/salud/datos_abiertos/' + name_file
    r = requests.get(URL)
    #retrieving data from the URL using get method
    with open(name_file, 'wb') as f:
        f.write(r.content)
    zip = zipfile.ZipFile(name_file)
    zip.extractall()
    os.remove(name_file)

download_latest()
