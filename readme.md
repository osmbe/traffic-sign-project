**Imperfect data put to use**

The Flemish government has [a traffic sign database](https://www.verkeersborden.vlaanderen/). They use it to keep track of which exact traffic signs are where. But Flanders only manages the data of the roads they manage themselves. This is just the "regional roads", not the municipal roads. Municipalities however *can* manage the data for the signs on their own roads. And some do. At first glance, the data may look complete, because of a data collection project over a decade ago. But in many places, signs haven't been touched since. Some municipalities on the other hand are doing a stellar job. 

This means the data cannot be used to map everywhere. But it *can* be used to detect new traffic signs. These are quite interesting, since we are pretty sure they will actually exist. And often these are newly placed signs, so it is quite likely the effect in OpenStreetMap is still missing. 

If we use this data, in a way, we thank the people who do manage their local traffic signs. The road managers have an almost direct impact on people's choices, as long as they use an OpenStreetMap based route planner.

This is not an import project. We do *not* aim to add the traffic signs themselves to OpenStreetMap. We just filter interesting new signs and turn them into MapRoulette tasks. There, you can map **their effects**, like for example a new speed limit or a new one-way street. 

Over time, this could be expanded to other datasources, like Mapillary object detections. At some point, we will also start filtering out traffic signs whose effects are probably already mapped. 

[More context via the OSM.be project page](https://openstreetmap.be/en/projects/traffic-sign.html).


**Main logic**

1. Download the data through [the WFS service](https://www.vlaanderen.be/datavindplaats/catalogus/verkeersbordenvlaanderenborden#downloadservices)
2. Download road signs plugin data from https://wiki.openstreetmap.org/wiki/Road_signs_in_Belgium/Road_signs_plugin and add information about the meaning of the traffic sign code.
3. Filter interesting traffic signs
- [planned] recent removal
- recent addition
- of a traffic sign that we find interesting
4. Merge traffic signs on the same location into a single task


**Note**
Several ad hoc decisions were made in the processing, for example:
- use only signs that are not from the future and are from the last 30 days (should be replaced with "new since last dump")
- fixed a missing cyclestreet sign and added a personal "relevancy for osm" scale to the data

See [the processing of the traffic sign plugin data](https://github.com/osmbe/play/blob/master/traffic_signs_project/select%20interesting%20codes.sps) and the [main processing of the dumps](https://github.com/osmbe/play/blob/master/traffic_signs_project/main%20processing.sps).


**Issues / planned improvements**
* The current open tasks were still processed the old way, using a Python Notebook, QGIS and SPSS.
@feleir rebuilt the entire processing flow in Python and built an automation so that the MapRoulette task can be updated weekly. This will be put in practice soon.
* The amount of tasks can be a little daunting. We will experiment with the priority of tasks to make sure the most important signs are more visible than the less important ones.

**Try it out**
At https://maproulette.org/browse/challenges/23550. Detailed mapping instructions and resources there!
Please leave comments if you see weird stuff in the source data!

