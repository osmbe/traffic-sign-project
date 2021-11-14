* Encoding: windows-1252.
PRESERVE.
 SET DECIMAL COMMA.

GET DATA  /TYPE=TXT
  /FILE="C:\github\osmbe\play\traffic_signs_project\road_signs.csv"
  /ENCODING='UTF8'
  /DELCASE=LINE
  /DELIMITERS=";"
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /DATATYPEMIN PERCENTAGE=95.0
  /VARIABLES=
  country AUTO
  ref AUTO
  useful AUTO
  name AUTO
  nl.name AUTO
  fr.name AUTO
  help AUTO
  nl.help AUTO
  wiki AUTO
  traffic_sign_tag AUTO
  nl.wiki AUTO
  id AUTO
  supplementary AUTO
  name.nl AUTO
  icon AUTO
  key AUTO
  value AUTO
  ident AUTO
  input AUTO
  name2 AUTO
  nl.name3 AUTO
  type AUTO
  ident4 AUTO
  default AUTO
  suffix AUTO
  field_width AUTO
  editable AUTO
  text AUTO
  nl.text AUTO
  values AUTO
  id5 AUTO
  /MAP.
RESTORE.

CACHE.
EXECUTE.
DATASET NAME trafficsigninfo WINDOW=FRONT.

string bordcode (a60).
compute bordcode = char.substr(ref,4).
EXECUTE.


* Identify Duplicate Cases.
SORT CASES BY bordcode(A).
MATCH FILES
  /FILE=*
  /BY bordcode
  /FIRST=PrimaryFirst
  /LAST=PrimaryLast.
DO IF (PrimaryFirst).
COMPUTE  MatchSequence=1-PrimaryLast.
ELSE.
COMPUTE  MatchSequence=MatchSequence+1.
END IF.
LEAVE  MatchSequence.
FORMATS  MatchSequence (f7).
COMPUTE  InDupGrp=MatchSequence>0.
SORT CASES InDupGrp(D).
MATCH FILES
  /FILE=*
  /DROP=PrimaryFirst InDupGrp MatchSequence.
VARIABLE LABELS  PrimaryLast 'Indicator of each last matching case as Primary'.
VALUE LABELS  PrimaryLast 0 'Duplicate Case' 1 'Primary Case'.
VARIABLE LEVEL  PrimaryLast (ORDINAL).
FREQUENCIES VARIABLES=PrimaryLast.
EXECUTE.


if lag(bordcode)=bordcode id5=concat(ltrim(rtrim(lag(id5))),",",ltrim(rtrim(id5))).
EXECUTE.

FILTER OFF.
USE ALL.
SELECT IF (PrimaryLast=1).
EXECUTE.
sort cases bordcode (a).


* OPTIONAL: to add frequency data.

GET TRANSLATE
  FILE=basefolder + newshape
  /TYPE=DBF /MAP .
DATASET NAME v2 WINDOW=FRONT.
match files
/file=*
/keep=objectid bordId code parameters actief datumPLaat aanzichtid opstelling copyDatum xcoord ycoord.
DATASET ACTIVATE v2.


* create Z signs.
string bordcode (a60).
compute bordcode=code.
if char.index(code,"Z")=1 zone=1.
if char.index(code,"Z")=1 bordcode=char.substr(code,2,59).

* remove trailing /.
compute bordcode=replace(bordcode,"/","").
EXECUTE.



DATASET DECLARE codefreq.
AGGREGATE
  /OUTFILE='codefreq'
  /BREAK=bordcode
  /codefreq=N.



DATASET ACTIVATE trafficsigninfo.
MATCH FILES /FILE=*
  /FILE='codefreq'
  /BY bordcode.
EXECUTE.

* END optional part.

* manual fix for cyclestreets.
sort cases bordcode (a).
do if bordcode="F113".
compute name=lag(name).
compute nl.name=lag(nl.name).
compute key=lag(key).
compute value=lag(value).
compute country="BE".
end if.
EXECUTE.




FILTER OFF.
USE ALL.
SELECT IF (useful ~= "NO" & country="BE" & codefreq>0).
EXECUTE.

if length(ltrim(rtrim(id5)))>7 confusion_possible=1.
EXECUTE.

match files
/file=*
/keep=bordcode name help wiki key value confusion_possible.
EXECUTE.

sort cases bordcode (a).

* load opinion about relevance for OSM.


PRESERVE.
 SET DECIMAL COMMA.

GET DATA  /TYPE=TXT
  /FILE="C:\github\osmbe\play\traffic_signs_project\road_sign_opinion.csv"
  /ENCODING='Locale'
  /DELCASE=LINE
  /DELIMITERS=";"
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /DATATYPEMIN PERCENTAGE=95.0
  /VARIABLES=
  bordcode A60
  opinion AUTO
  /MAP.
RESTORE.

CACHE.
EXECUTE.
DATASET NAME opinion WINDOW=FRONT.
sort cases bordcode (a).


DATASET ACTIVATE trafficsigninfo.
sort cases bordcode (a).
MATCH FILES /FILE=*
  /TABLE='opinion'
  /BY bordcode.
EXECUTE.


SAVE TRANSLATE OUTFILE='C:\github\osmbe\play\traffic_signs_project\road_signs_cleaned.csv'
  /TYPE=CSV
  /ENCODING='Locale'
  /MAP
  /REPLACE
  /FIELDNAMES
  /CELLS=VALUES.

dataset close opinion.
dataset close v2.
dataset close codefreq.

