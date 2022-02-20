* Encoding: windows-1252.
* 1. define folder and files.
DEFINE basefolder () 'C:\github\osmbe\traffic-sign-project\' !ENDDEFINE.
DEFINE newshape () 'raw-output\20220218_road_signs.csv' !ENDDEFINE.

DEFINE olddate () '01.11.2021' !ENDDEFINE.
DEFINE newdate () '18.02.2022' !ENDDEFINE.


* 2. load and limit source datasets.
PRESERVE.
 SET DECIMAL DOT.

GET DATA  /TYPE=TXT
  /FILE=basefolder + newshape
  /DELCASE=LINE
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /DATATYPEMIN PERCENTAGE=51.0
  /VARIABLES=
  FID a50
  UUID a50
  externe_id_bord A50
  locatie_x A15
  locatie_y A15
  bordcode a60
  opstelhoogte f10.0
  breedte f10.0
  hoogte f10.0
  folietype a10
  leverancier a50
  vorm a10
  fabricage_type a50
  fabricage_jaar f4.0
  fabricage_maand f2.0
  besteknummer a50
  opmerkingen a50
  beheerder a50
  datum_plaatsing A10
  parameters a250
  bevestigingsProfielen f2.0
  beugels f2.0
  type_bevestiging a50
  id_opstelling f10.0
  id_aanzicht f10.0
  geometry a100
  /MAP.
RESTORE.

CACHE.
EXECUTE.
DATASET NAME data WINDOW=FRONT.

* silly cleaning of CSV to fit SPSS datatypes.
compute locatie_x=replace(locatie_x,".",",").
compute locatie_y=replace(locatie_y,".",",").
compute datum_plaatsing=replace(datum_plaatsing,"/",".").
alter type locatie_x locatie_y (F12.2).
alter type datum_plaatsing (EDATE10).

match files
/file=*
/keep=FID bordcode parameters  datum_plaatsing id_aanzicht id_opstelling  locatie_x locatie_y.
string versiondate (a10).
compute versiondate=newdate.
alter type versiondate (EDATE10).

string olddatevar (a10).
compute olddatevar=olddate.
alter type olddatevar (EDATE10).
if datum_plaatsing>versiondate fromthefuture=1.
if datum_plaatsing>olddatevar newsign=1.

* 4.  Remove traffic signs of the future (bad date entry, one supposes).
* Keep only traffic signs created since the last run.
FILTER OFF.
USE ALL.
SELECT IF (misisng(fromthefuture) & newsign=1).
EXECUTE.


* 5. Keep only interesting traffic signs.

* 5A. Load traffic sign info: from seperateley prepared file.

PRESERVE.
 SET DECIMAL COMMA.

GET DATA  /TYPE=TXT
  /FILE=basefolder + "find-interesting-signs\road_signs_cleaned.csv"
  /ENCODING='Locale'
  /DELCASE=LINE
  /DELIMITERS=";"
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /DATATYPEMIN PERCENTAGE=95.0
  /VARIABLES=
  bordcode A60
  name AUTO
  help AUTO
  wiki AUTO
  key AUTO
  value AUTO
  confusion_possible AUTO
  opinion AUTO
  /MAP.
RESTORE.

CACHE.
EXECUTE.
DATASET NAME signmetadata WINDOW=FRONT.


DATASET ACTIVATE data.

* Z signs are not in our external data, so let's just give them an extra flag "this is a zonal thing".
if char.index(bordcode,"Z")=1 zone=1.
if char.index(bordcode,"Z")=1 bordcode=char.substr(bordcode,2,59).

* remove trailing /.
compute bordcode=replace(bordcode,"/","").
EXECUTE.

sort cases bordcode (a).


* added signs background info.
MATCH FILES /FILE=*
  /TABLE='signmetadata'
  /BY bordcode.
EXECUTE.
dataset close signmetadata.

* keep only signs with metadata.
FILTER OFF.
USE ALL.
SELECT IF (name ~= "").
EXECUTE.

* keep only signs deemed important.
FILTER OFF.
USE ALL.
SELECT IF (opinion>0).
EXECUTE.

* maproulette likes the name "id" for an external identifier.
rename variables FID=id.
compute id=replace(id,"Verkeersborden.Vlaanderen_Borden.","").
EXECUTE.
rename variables bordcode=traffic_sign_code.
rename variables parameters=extra_text.
rename variables datum_plaatsing=date_installed.


DATASET ACTIVATE data.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=id_aanzicht
  /multiple_views=N.
recode multiple_views (1=0) (2 thru highest =1). 
alter type multiple_views (a100).
compute multiple_views=ltrim(rtrim(multiple_views)).
recode multiple_views
('0'='no')
('1'='more than one traffic sign added here').
rename variables name=traffic_sign_description.
if zone=1 traffic_sign_description=concat(ltrim(rtrim(traffic_sign_description))," (zonal sign)").


**** eerst eens zien welke versie uiteindelijk in MapRoulette paste.
match files
/file=*
/keep=id
traffic_sign_code
extra_text
traffic_sign_description
date_installed
multiple_views
locatie_x
locatie_y.
EXECUTE.

SAVE TRANSLATE OUTFILE=basefolder + 'maproulette-readables\\road_signs_selection_lambert72.csv'
  /TYPE=CSV
  /ENCODING='Locale'
  /MAP
  /REPLACE
  /FIELDNAMES
  /CELLS=VALUES.

* open in QGIS, save as GeoJSON in ESPG:4326

