**Imperfect data put to use**

The Flemish government has a traffic sign database. They use it to keep track of which exact traffic signs are where. But Flanders only manages the data of the roads they manage themselves. This is just the "regional roads", not the municipal roads. Municipalities however *can* manage the data for the signs on their own roads. And some do. The data looks complete, because of a data collection project over a decade ago. But in many places, signs haven't been touched since. Some municipalities on the other hand are doing a stellar job. 

This means the data cannot be used to map everywhere. But it *can* be used to detect new traffic signs. These are quite interesting, since we are pretty sure they will actually exist. And often these are newly placed signs, so perhaps the effect in OpenStreetMap is still missing. 

In this way, we thank the people who do manage their local traffic signs, by making it easier for routing software to take in account what the road manager wanted. 

We do *not* aim to map the traffic signs themselves. We just filter interesting new signs and turn them into MapRoulette tasks. There, you can map their effects, like for example a new speed limit or one-way street. 

Over time, this could be expanded to other datasources, like Mapillary object detections. At some point, we will also start filtering out traffic signs whose effects are probably already mapped. 




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

**Issues / planned improvements**

* The weekly update provided by Vlaanderen isn't updating > added a script to generate a CSV file from the WFS server, which seems to actually work! Sometimes!
* Signs like https://maproulette.org/challenge/23548/task/120115468 should be joined with their "onderbord" > added a note that there are "relevant signs on the same place"
* Maybe try and get some images in the task? > doesn't seem possible in maproulette, but simply use URLs like https://nl.wikipedia.org/wiki/Bestand:Belgian_road_sign_F113.svg to get the svg for the sign!

**Try it out**

At https://maproulette.org/browse/challenges/23550. Detailed mapping instructions and resources there!
Please leave comments if you see weird stuff in the source data!

