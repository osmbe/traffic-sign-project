* Encoding: windows-1252.

* The CSV format comes from the WFS server.
* The DBF can be downloaded as part of a shapefile.
* However the DBF is not updated by the provider.
* To compare "old" to "new" data, we transform (this one time only, hopefully) the DBF to the expected CSV format, so that we can pretend we have two versions around.


* Load old DBF from shapefile.
GET TRANSLATE
  FILE='C:\Users\plu3532\Documents\niet-werkgerelateerd\OSM\verkeersborden\dumps for '+
    'traffic_sing_project\Verkeersborden-Borden-20111002-xy.dbf'
  /TYPE=DBF /MAP .
dataset name dbf.

* make the DBF look like an old CSV.

rename variables bordid=FID.
alter type FID (a50).
compute FID=concat("Verkeersborden.Vlaanderen_Borden.",ltrim(rtrim(FID))).
string UUID (a50).
string externe_id_bord (a50).
rename variables code=bordcode.
compute opstelhoogte=$sysmis.
rename variables (xcoord
ycoord = locatie_x
locatie_y).
rename variables fabricageT=fabricage_type.
rename variables fabricageJ=fabricage_jaar.
compute fabricage_maand = $sysmis.
rename variables besteknumm=besteknummer.
string opmerkingen (a50).
rename variables aanzichtid=id_aanzicht.
rename variables datumPlaat=datum_plaatsing.
rename variables opstelling=id_opstelling.
rename variables leverancie=leverancier.
string geometry (a100).
compute geometry=concat("POINT (",string(locatie_x,f12.6)," ",string(locatie_y,f12.6),")").
compute bevestigingsProfielen=$sysmis.
compute beugels=$sysmis.
string type_bevestiging (a50).

alter type datum_plaatsing (EDATE10).

match files
/file=*
/keep=FID
UUID
externe_id_bord
locatie_x
locatie_y
bordcode
opstelhoogte
breedte
hoogte
folietype
leverancier
vorm
fabricage_type
fabricage_jaar
fabricage_maand
besteknummer
opmerkingen
beheerder
datum_plaatsing
parameters
bevestigingsProfielen
beugels
type_bevestiging
id_opstelling
id_aanzicht
geometry.


SAVE TRANSLATE OUTFILE='C:\github\osmbe\traffic-sign-project\raw-output\20211102_road_signs.csv'
  /TYPE=CSV
  /ENCODING='UTF8'
  /MAP
  /REPLACE
  /FIELDNAMES
  /CELLS=VALUES
/replace.
