* Encoding: windows-1252.
* 1. define folder and files.
DEFINE basefolder () 'C:\github\osmbe\traffic-sign-project\' !ENDDEFINE.
DEFINE oldshape () 'raw-output\20211102_road_signs.csv' !ENDDEFINE.
DEFINE newshape () 'raw-output\20220218_road_signs.csv' !ENDDEFINE.
.
DEFINE olddate () '02.11.2021' !ENDDEFINE.
DEFINE newdate () '18.02.2022' !ENDDEFINE.


* 2. load and limit source datasets.
PRESERVE.
 SET DECIMAL COMMA.

GET DATA  /TYPE=TXT
  /FILE=basefolder + oldshape
  /DELCASE=LINE
  /DELIMITERS=";"
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /DATATYPEMIN PERCENTAGE=51.0
  /VARIABLES=
  FID a50
  UUID a50
  externe_id_bord A50
  locatie_x F12.2
  locatie_y F12.2
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
  datum_plaatsing a10
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
DATASET NAME v1 WINDOW=FRONT.

* special case, the next line is normally needed.
*compute datum_plaatsing=replace(datum_plaatsing,"/",".").
alter type locatie_x locatie_y (F12.2).
* special case: this is normally EDATE.
alter type datum_plaatsing (ADATE10).

match files
/file=*
/keep=FID bordcode parameters  datum_plaatsing id_aanzicht id_opstelling  locatie_x locatie_y.
string versiondate (a10).
compute versiondate=olddate.
alter type versiondate (EDATE10).

* Remove traffic signs of the future (bad date entry, one supposes).
FILTER OFF.
USE ALL.
SELECT IF (datum_plaatsing<=versiondate).
EXECUTE.

rename variables (bordcode parameters  datum_plaatsing id_aanzicht id_opstelling  locatie_x locatie_y versiondate
= bordcode_v1 parameters_v1 datum_plaatsing_v1 id_aanzicht_v1 id_opstelling_v1  locatie_x_v1 locatie_y_v1 versiondate_v1).
sort cases FID (a).

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
DATASET NAME v2 WINDOW=FRONT.

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

* Remove traffic signs of the future (bad date entry, one supposes).
FILTER OFF.
USE ALL.
SELECT IF (datum_plaatsing<=versiondate).
EXECUTE.

rename variables (bordcode parameters  datum_plaatsing id_aanzicht id_opstelling  locatie_x locatie_y versiondate
= bordcode_v2 parameters_v2 datum_plaatsing_v2 id_aanzicht_v2 id_opstelling_v2 locatie_x_v2 locatie_y_v2 versiondate_v2).
sort cases FID (a).



* 3. merge datasets.
DATASET ACTIVATE v1.
MATCH FILES /FILE=*
  /FILE='v2'
  /BY FID.
EXECUTE.
dataset close v2.


* 4. keep recent additions and removals"

* SEEMS RATHER HARD TO UNIQUELY MATCH 

* shortcut: let's just keep additions since last processing.
FILTER OFF.
USE ALL.
SELECT IF (datumPlaat_v1>DATESUM(copyDatum_v1,-30,"days")).
EXECUTE.

* 5. Keep only interesting traffic signs.

* 5A. Load traffic sign info: from seperateley prepared file.

PRESERVE.
 SET DECIMAL COMMA.

GET DATA  /TYPE=TXT
  /FILE="C:\github\osmbe\play\traffic_signs_project\road_signs_cleaned.csv"
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


DATASET ACTIVATE v1.

* create Z signs.
string bordcode (a60).
compute bordcode=code_v2.
if char.index(code_v2,"Z")=1 zone=1.
if char.index(code_v2,"Z")=1 bordcode=char.substr(code_v2,2,59).

* remove trailing /.
compute bordcode=replace(bordcode,"/","").
EXECUTE.

sort cases bordcode (a).




DATASET ACTIVATE v1.
MATCH FILES /FILE=*
  /TABLE='signmetadata'
  /BY bordcode.
EXECUTE.

* keep only signs with metadata.
FILTER OFF.
USE ALL.
SELECT IF (name ~= "").
EXECUTE.

* keep only signs deemed important.
DATASET ACTIVATE v1.
FILTER OFF.
USE ALL.
SELECT IF (opinion>0).
EXECUTE.

match files
/file=*
/keep=bordid datumPlaat_v2 aanzichtid_v2
opstelling_v2 copyDatum_v2
xcoord_v2
ycoord_v2
bordcode
parameters_v2
name
help
wiki
key
value
confusion_possible.
EXECUTE.


SAVE TRANSLATE OUTFILE='C:\github\osmbe\play\traffic_signs_project\road_signs_selection_lambert72.csv'
  /TYPE=CSV
  /ENCODING='Locale'
  /MAP
  /REPLACE
  /FIELDNAMES
  /CELLS=VALUES.



match files
/file=*
/keep=bordid
xcoord_v2
ycoord_v2
bordcode
parameters_v2
name.
EXECUTE.
compute name=replace(name,",",";").
EXECUTE.


SAVE TRANSLATE OUTFILE='C:\github\osmbe\play\traffic_signs_project\road_signs_selection_lambert72_nocomma.csv'
  /TYPE=CSV
  /ENCODING='Locale'
  /MAP
  /REPLACE
  /FIELDNAMES
  /CELLS=VALUES.

PRESERVE.
 SET DECIMAL COMMA.

GET DATA  /TYPE=TXT
  /FILE="C:\github\osmbe\traffic-sign-project\raw-output\20220218_road_signs.csv"
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
  locatie_x F12.2
  locatie_y F12.2
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
  datum_plaatsing AUTO
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
DATASET NAME csv WINDOW=FRONT.


DATASET ACTIVATE v1.
DATASET COPY  removedsign.
DATASET ACTIVATE  removedsign.
FILTER OFF.
USE ALL.
SELECT IF (missin(datum_plaatsing_v2)).
EXECUTE.
DATASET ACTIVATE  v1.

DATASET COPY  newsign.
DATASET ACTIVATE  newsign.
FILTER OFF.
USE ALL.
SELECT IF (missin(datum_plaatsing_v1)).
EXECUTE.
DATASET ACTIVATE  v1.
