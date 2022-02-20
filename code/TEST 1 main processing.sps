* Encoding: windows-1252.
* 1. define folder and files.
DEFINE basefolder () 'C:\github\osmbe\play\traffic_signs_project\' !ENDDEFINE.
DEFINE oldshape () 'Verkeersborden-Borden-20111002-xy.dbf' !ENDDEFINE.
DEFINE newshape () 'Verkeersborden-Borden-20111106-xy.dbf' !ENDDEFINE.

* 2. load and limit source datasets.
GET TRANSLATE
  FILE=basefolder + oldshape
  /TYPE=DBF /MAP .
DATASET NAME v1 WINDOW=FRONT.
match files
/file=*
/keep=objectid bordId code parameters actief datumPlaat aanzichtid opstelling copyDatum xcoord ycoord.

* Remove traffic signs of the future.
FILTER OFF.
USE ALL.
SELECT IF (datumPlaat<=copyDatum).
EXECUTE.

rename variables (objectid code parameters actief datumPlaat aanzichtid opstelling copyDatum xcoord ycoord
= objectid_v1 code_v1 parameters_v1 actief_v1 datumPlaat_v1 aanzichtid_v1 opstelling_v1 copyDatum_v1 xcoord_v1 ycoord_v1).
sort cases bordId (a).

GET TRANSLATE
  FILE=basefolder + newshape
  /TYPE=DBF /MAP .

DATASET NAME v2 WINDOW=FRONT.
* Remove traffic signs of the future.
FILTER OFF.
USE ALL.
SELECT IF (datumPlaat<=copyDatum).
EXECUTE.

match files
/file=*
/keep=objectid bordId code parameters actief datumPLaat aanzichtid opstelling copyDatum xcoord ycoord.
rename variables (objectid code parameters actief datumPlaat aanzichtid opstelling copyDatum xcoord ycoord
= objectid_v2 code_v2 parameters_v2 actief_v2 datumPlaat_v2 aanzichtid_v2 opstelling_v2 copyDatum_v2 xcoord_v2 ycoord_v2).
sort cases bordId (a).



* 3. merge datasets.
DATASET ACTIVATE v1.
MATCH FILES /FILE=*
  /FILE='v2'
  /BY bordId.
EXECUTE.
dataset close v2.


* 4. keep recent additions and removals"
* ERROR IN DATA PROVIDED: the automatic update on their side is NOT working.

* shortcut: let's just keep recent additions.
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