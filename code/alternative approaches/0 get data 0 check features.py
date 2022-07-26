from owslib.wfs import WebFeatureService
from datetime import datetime
import time
import json


def printGreen(skk): print("\033[92m {}\033[00m" .format(skk))

url = "https://opendata.apps.mow.vlaanderen.be/opendata-geoserver/awv/wfs?version=2.0.0" #&service=wfs&request=GetCapabilities"
wfs = WebFeatureService(url=url, version="2.0.0")

while 1 :
    response = wfs.getfeature(typename="awv:Verkeersborden.Vlaanderen_Borden", outputFormat="json", maxfeatures=1)
    r = response.read()
    d = r.decode('UTF-8')
    j = json.loads(d)
    total_features = j['totalFeatures']
    printGreen(str(datetime.now()) + " --  #features: " + str(total_features))
    time.sleep(120)







