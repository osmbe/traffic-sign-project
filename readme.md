**Main logic**

1. Download weekly file at
https://wegenenverkeer.be/sites/default/files/uploads/documenten/Verkeersborden-Borden.zip

2. Download road signs plugin data
https://wiki.openstreetmap.org/wiki/Road_signs_in_Belgium/Road_signs_plugin

3. In order to make things work in non-geo software, add x-y to data
Done in QGIS with built-in QGIS vector tool "add geometry attributes"

4. Keep interesting traffic signs
- recent removal
- recent addition
- of a traffic sign that we find interesting

5. Geographic clustering?
Open csv in qgis reproject to 4326.


**Tips**
Several ad hoc decisions were made in the processing scripts (SPSS .sps files that you can read with a regular text editor):
- use only signs that are not from the future and are from the last 30 days (should be replaced with "new since last dump")
- fixed a missing cyclestreet sign and added a personal "relevancy for osm" scale to the data

See [the processing of the traffic sign plugin data](https://github.com/osmbe/play/blob/master/traffic_signs_project/select%20interesting%20codes.sps) and the [main processing of the dumps](https://github.com/osmbe/play/blob/master/traffic_signs_project/main%20processing.sps).

Make variants of 
https://nl.wikipedia.org/wiki/Bestand:Belgian_road_sign_C5.svg
to see your traffic sign

**Issues**

The weekly update provided by Vlaanderen isn't updating.
MapRoulette fails when loading the json, in weird ways. It chooses "name" to populate the unique ID. That "name" cannot have duplicates! But it stops for other reasons as well...


**Try it out**

At https://maproulette.org/browse/challenges/23548
Please leave comments if you see weird stuff in the source data!
