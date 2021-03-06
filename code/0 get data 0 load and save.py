# the script works, but seems to prefer running outside of business hours. It seems changes in the data on the server, make the download process crash.
from owslib.wfs import WebFeatureService

def remove_linebreaks(data):
    print("start cleaning")
    replace1 = data.replace(b'\n',b' ')
    replace2 = replace1.replace(b'\r ',b'\r\n')
    print("stop cleaning")
    return replace2

url = "https://opendata.apps.mow.vlaanderen.be/opendata-geoserver/awv/wfs?version=2.0.0" #&service=wfs&request=GetCapabilities"

wfs = WebFeatureService(url=url, version="2.0.0", timeout=3600)


vb_type_name = "awv:Verkeersborden.Vlaanderen_Borden"
# vb_max = 1511546
vb_output_format = "csv"
#vb_startindex = 0 #starts at 0 cfr. WFS 2.0 spec

print("start")
# response = wfs.getfeature(typename=vb_type_name, maxfeatures=vb_max, outputFormat=vb_output_format, startindex=vb_startindex)
response = wfs.getfeature(typename=vb_type_name, outputFormat=vb_output_format)
print("stop")

r = remove_linebreaks(response.read())
test = r.decode('UTF-8')

with open(file="output.csv", encoding='UTF-8', mode='w', newline='') as csvfile:
    csvfile.write(test)
