(: output "events" in the PLOT-IT JSON format from different schemas :)

xquery version "3.0" encoding "utf-8";

(: import helper modules :)
import module namespace cwPH="cwPlaceHelpers" at "./helpers/cw_place_helpers.xq";
import module namespace cwOH="cwOrlandoHelpers" at "./helpers/cw_orlando_helpers.xq";
import module namespace cwAccessibility="cwAccessibility" at "./islandora_access_control.xq";


(: declare namespaces used in the content :)
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace tei =  "http://www.tei-c.org/ns/1.0";
declare namespace fedora =  "info:fedora/fedora-system:def/relations-external#";
declare namespace fedora-model="info:fedora/fedora-system:def/model#"; 
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";

(: options :)
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
(: declare option output:method   "xml"; :)
declare option output:method "adaptive";
declare option output:encoding "UTF-8";
declare option output:indent   "no";

(: declare option output:parameter-document "file:///home/me/serialization-parameters.xml"; :)

(: declare boundary-space preserve; :)
(: database must be imported with the following option otherwise text nodes have the begining and ending whitespace "chopped off" which is undesireable for mixed content:)
declare option db:chop 'false';

(: external variables :)
declare variable $FEDORA_PID external := "";
declare variable $BASE_URL external := "";
declare variable $PID_LIST external := ();
declare variable $PID_COLLECTION external := "";

(: internal constants :)
declare variable $TYPE_ORLANDO_CWRC := "CWRC / Orlando";
declare variable $TYPE_TEI := "TEI";
declare variable $TYPE_MODS := "MODS";


(: **** helper functions :)

(: escape double quotes (") within a JSON value :)
declare function local:escapeJSON ($str as xs:string?)
{
  (: XQuery 3.1 doesn't support look-behinds so need extra replace for case where " is the first character :)
  fn:replace( fn:replace($str, '^["]', '\\"') , '([^\\])["]', '$1\\"')
};


(: if value is empty then do not output JSON key/value :)
declare function local:outputJSONNotNull ($key as xs:string?, $value as xs:string?)
as xs:string?
{
  (
  if ($value != "") then
    local:outputJSON ($key, $value)
  else
    ()
  )
};

declare function local:outputJSON ($key as xs:string?, $value as xs:string?)
as xs:string?
{
  let $tmp := string('"'||$key||'": "'||local:escapeJSON($value)||'"')
  return $tmp
};

declare function local:outputJSONArray ($key as xs:string?, $value)
as xs:string?
{
  let $tmp := string('"'||$key||'": ['||$value||']')
  return $tmp
};


declare function local:modsBiblType($src)
{
  if ( $src/mods:originInfo/mods:issuance/text() eq "monographic" ) then
    "monographic"
  else if ( $src/mods:relatedItem/mods:originInfo/mods:issuance/text() eq "monographic" ) then
    "monographic part"
  else if ( $src/mods:relatedItem/mods:originInfo/mods:issuance/text() eq "continuing" ) then
    "continuing"
  else
    ()
};

declare function local:modsFormatDescription($src) 
{
  "<div>Author: "||fn:string-join($src/mods:name/mods:namePart, " ")||"</div>"
  ||
  "<div>Title: "||fn:string-join($src/mods:titleInfo/mods:title, " ")||"</div>"
  ||
  "<div>Place: "||fn:string-join($src/mods:originInfo/mods:place/mods:placeTerm[not(@authority eq "marccountry")], " ")||"</div>"
  ||
  "<div>Publisher: "||fn:string-join($src/mods:originInfo/mods:publisher, " ")||"</div>"
  ||
  "<div>Year: "||fn:string-join($src/(mods:originInfo/mods:dateIssued|mods:part/mods:date), " ")||"</div>"
};


(: ***** collect JSON values ******* :)

(: build the "date" attribute from the different schemas: Orlando, TEI, MODS, and CWRC :)
declare function local:get_start_date ($src, $type)
as xs:string?
{
  let $tmp :=
  (
    if ( $type eq $TYPE_ORLANDO_CWRC) then
      (: Orlando XML :)
    ( 
      (: To do: If DATERANCE has not attribute value, determine how to interpret the decendant tags and test. :)
      let $dateAttr := ($src/descendant-or-self::CHRONSTRUCT/((DATE|DATERANGE|DATESTRUCT)[1]/(@VALUE|@FROM)))
      let $dateTxt := ($src/descendant-or-self::CHRONSTRUCT/((DATE|DATERANGE)[1]/text()))
      return
        if ($dateAttr) then
          fn:replace( ($dateAttr), '\-{1,2}$', '') (: Fix Orlando date format :)
        else if ( $dateTxt )  then
          fn:string-join(cwOH:parse-orlando-narrative-date($dateTxt),"-")
        else
          ()
    )
    else if ($type eq $TYPE_TEI) then
      (: TEI XML :)
      ( $src/descendant-or-self::tei:date[1]/(@when|@from|@notBefore) )
    else if ($type eq $TYPE_MODS) then
      (: MODS XML :)
      ( 
        let $dateTxt :=
          switch ( local:modsBiblType($src) )
            case "monographic" return $src/mods:originInfo/(mods:dateIssued|mods:copyrightDate)/text()
            case "monographic part" return $src/mods:relatedItem/mods:originInfo/(mods:dateIssued|mods:copyrightDate)/text()
            case "continuing" return $src/mods:relatedItem/mods:part/mods:date/text()
            default return $src/mods:originInfo/mods:dateIssued/text()
        return
          fn:string-join(cwOH:parse-orlando-narrative-date($dateTxt),"-")
      )
    else
      ( )
    )
  return fn:normalize-space(fn:string-join($tmp , ""))
};



(: build the "end date" attribute from the different schemas: Orlando, TEI, MODS, and CWRC :)
declare function local:get_end_date ($src, $type)
as xs:string?
{
  let $tmp :=
  (
    if ( $type eq $TYPE_ORLANDO_CWRC) then
    (: Orlando XML :)
    ( 
      fn:replace( ($src/descendant-or-self::CHRONSTRUCT/(DATERANGE[1]/@TO)) , '\-{1,2}$','') (: Fix Orlando date format :)
    )
    else if ($type eq $TYPE_TEI) then
    (: TEI XML :)
    ( $src/descendant-or-self::tei:date[1]/(@to|@notAfter) )
    else if ($type eq $TYPE_MODS) then
    (: MODS XML :)
      ()
    else
      ()
    )
  return fn:normalize-space(fn:string-join($tmp , ""))
};


(: build the "latLng" (latitude/Longitude) attribute from the different schemas: Orlando, TEI, MODS, and CWRC :)
declare function local:get_lat_lng ($src, $type)
as xs:string?
{
  let $placeSeq :=
  (
    if ( $type eq $TYPE_ORLANDO_CWRC) then
    (: Orlando XML :)
    ( 
      (: Orlando Place :)
      for $placeNode in $src//CHRONPROSE//PLACE
      return
        cwPH:get_geo_code($placeNode/@LAT/data(),$placeNode/@LONG/data(),$placeNode/@REF/data(),fn:normalize-space(cwPH:getOrlandoPlaceString($placeNode)))
    )
    else if ($type eq $TYPE_TEI) then
    (: TEI XML :)
    ( 
      (: TEI Place :)
      for $placeNode in $src/tei:desc[1]/tei:placeName
      return 
        cwPH:get_geo_code("","",$placeNode/@ref/data(),fn:normalize-space($placeNode/text()))
    )
    else if ($type eq $TYPE_MODS) then
    (: MODS XML :)
    ( 
      (: MODS Place :)
      let $tmp :=
      (
          switch ( local:modsBiblType($src) )
          case "monographic" return $src/mods:originInfo/mods:place
          case "monographic part" return $src/mods:relatedItem/mods:originInfo/mods:place
          case "continuing" return $src/mods:originInfo/mods:place
          default return ()
      )
      for $placeNode in $tmp
      return
        cwPH:get_geo_code("","",$placeNode/@ref/data(),fn:normalize-space(fn:string-join($placeNode/mods:placeTerm[not(@authority eq "marccountry")]/text(), " ")) )
    )
    else
      ( fn:name($src) )
  )
  let $latLngStr :=
    (
    for $placeMap at $i in $placeSeq
        return
          (
            try {
              if ($placeMap('lat')) then
                '"' || local:escapeJSON($placeMap('lat') || "," || $placeMap('lng')) || '"'
              else
                ''
            }
            catch *
            {
              (: if issue in lookup then return North Pole :)
              ""
            }
          )
  )
  let $placeNameStr :=
    (
    for $placeMap at $i in $placeSeq
        return
          (
            try {
              '"' || local:escapeJSON($placeMap('placeStr')) || '"'
            }
            catch *
            {
              ""
            }
          )
  ) 
  let $placeRefStr :=
    (
    for $placeMap at $i in $placeSeq
        return
          (
            try {
              '"' || local:escapeJSON($placeMap('countryName')) || '"'
            }
            catch *
            {
              ""
            }
          )
  ) 
  return 
    local:outputJSONArray( "latLng", fn:string-join($latLngStr, ","))
    ||
    ","
    ||
    local:outputJSONArray( "location", fn:string-join($placeNameStr, ","))
    ||
    ","
    ||
    local:outputJSONArray( "countryName", fn:string-join($placeRefStr, ","))
};

(: build the "eventType" (event type) attribute from the different schemas: Orlando, TEI, MODS, and CWRC :)
declare function local:get_event_type ($src, $type)
as xs:string?
{
  let $tmp :=
  (
    if ( $type eq $TYPE_ORLANDO_CWRC) then
    (: Orlando XML :)
    ( 
      switch ( $src/descendant-or-self::CHRONSTRUCT/@CHRONCOLUMN/data() )
        case "NATIONALINTERNATIONAL" return "political"
        case "BRITISHWOMENWRITERS" return "literary"
        case "WRITINGCLIMATE" return "literary"
        case "SOCIALCLIMATE" return "social"                 
        default return "unspecified"
    )
    else if ($type eq $TYPE_TEI) then
    (: TEI XML :)
    ( 
      let $eventType := $src/@type/data()
      return 
        if ($eventType) then
          $eventType
        else
          "unspecified"
    )
    else if ($type eq $TYPE_MODS) then
    (: MODS XML :)
    ( "literary" )
    else
      ( fn:name($src) )
    )
  return fn:normalize-space(fn:string-join($tmp , ""))
};




(: build the "label" attribute from the different schemas: Orlando, TEI, MODS, and CWRC :)
declare function local:get_label ($src, $type)
as xs:string?
{
  let $label_max_length := 40
  let $tmp := normalize-space($src/descendant-or-self::CHRONSTRUCT/CHRONPROSE)
  let $label :=
  (
    if ( $type eq $TYPE_ORLANDO_CWRC) then
    (: Orlando XML :)
    ( 
      fn:concat(
        (: MRB: Thu 09-Apr-2015: uncommented JCA's code to prepend date for Orlando event labels :)
        fn:string-join($src/descendant-or-self::CHRONSTRUCT/(DATE|DATERANGE|DATESTRUCT/descendant-or-self::*)/text())
        , ": ",
        substring($tmp, 1, $label_max_length + string-length(substring-before(substring($tmp, $label_max_length+1),' '))) 
        , '...'
      )
    )
    else if ($type eq $TYPE_TEI) then
      (: TEI XML :)
      ( $src//tei:label )
    else if ($type eq $TYPE_MODS) then
    (: MODS XML :)
    (
      switch ( local:modsBiblType($src) )
      case "monographic" return $src/mods:titleInfo/mods:title/text() 
      case "monographic part" return $src/mods:relatedItem/mods:titleInfo/mods:title/text() 
      case "continuing" return $src/mods:titleInfo/mods:title/text() 
      default return $src/mods:titleInfo/mods:title/text()
    )
    else
      ( )
    )
  return fn:normalize-space(fn:string-join($label , ""))
};


(: build the "description" attribute from the different schemas: Orlando, TEI, MODS, and CWRC :)
declare function local:get_description ($src, $type)
as xs:string?
{
  let $tmp :=
  (
    if ( $type eq $TYPE_ORLANDO_CWRC) then
    (: Orlando XML :)
    (
      let $shortprose := 
      (
        if ($src/descendant-or-self::SHORTPROSE) then
        (
        "<p>"
        ||
        fn:serialize($src/descendant-or-self::SHORTPROSE)
        ||
        "</p>"
        )
        else
        ()
      )
      return
        "<p>"
        ||
        fn:serialize($src/descendant-or-self::CHRONSTRUCT/CHRONPROSE)
        ||
        "</p>"
        ||
        $shortprose
    )
    else if ($type eq $TYPE_TEI) then
    (: TEI XML :)
    ( 
      for $tmp in $src//tei:desc
      return 
        fn:serialize(<p>{$tmp}</p>) 
    )
    else if ($type eq $TYPE_MODS) then
    (: MODS XML :)
    (
      switch ( local:modsBiblType($src) )
      case "monographic" return local:modsFormatDescription($src) 
      case "monographic part" return local:modsFormatDescription($src/mods:relatedItem) 
      case "continuing" return local:modsFormatDescription($src)       
      default return local:modsFormatDescription($src)
    )
    else
      ( fn:name($src) )
    )
  return fn:normalize-space(fn:string-join($tmp , ""))
};


(: build the "citation" attribute from the different schemas: Orlando, TEI, MODS, and CWRC :)
declare function local:get_citations ($src, $type)
as xs:string?
{

  let $tmp :=
  (
    switch ( $type )
      (: Orlando or CWRC XML :)
      case $TYPE_ORLANDO_CWRC 
        return cwOH:build_citation_sequence($src//BIBCITS/BIBCIT | $src/following-sibling::BIBCITS[position()=1]/BIBCIT)
      (: TEI XML :)
      case $TYPE_TEI 
        return 
          for $item in $src//tei:listBibl/tei:bibl
          return 
            ( "<div>"||fn:string-join($item, " ")||"</div>" )
      (: MODS XML :)
      case $TYPE_MODS
        return ()
      default
        return
          ( "ERROR: " || fn:name($src) )
  )
  return fn:normalize-space(fn:string-join($tmp , ""))
};


(: build the "contributors" attribute from the different schemas: Orlando, TEI, MODS, and CWRC :)
declare function local:get_contributors ($src, $type)
as xs:string?
{

  let $tmp :=
  (
    switch ( $type )
      (: Orlando or CWRC XML :)
      case $TYPE_ORLANDO_CWRC 
        return cwOH:build_contributors_sequence($src/ancestor-or-self::*/ORLANDOHEADER/FILEDESC/PUBLICATIONSTMT/AUTHORITY)
      (: TEI XML :)
      case "TEI"
        return cwOH:build_contributors_sequence($src/ancestor-or-self::*/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/(tei:persName || tei:name | tei:orgName))
      (: MODS XML :)
      case $TYPE_MODS 
        return cwOH:build_contributors_sequence($src/ancestor-or-self::*/mods:recordInfo/mods:recordContentSource)
      default
        return
          ( "ERROR: " || fn:name($src) )
  )
  return fn:normalize-space(fn:string-join($tmp , ""))
};


(: build the "citation" attribute from the different schemas: Orlando, TEI, MODS, and CWRC :)
declare function local:determineSchemaByRootElement($src)
as xs:string?
{
    if ( fn:name($src) eq 'EVENT' or fn:name($src) eq 'CHRONSTRUCT') then
      ( $TYPE_ORLANDO_CWRC )
    else if (fn:namespace-uri($src) eq 'http://www.tei-c.org/ns/1.0') then
      ( $TYPE_TEI )
    else if (fn:namespace-uri($src) eq 'http://www.loc.gov/mods/v3') then
      ( $TYPE_MODS )
    else
      ( "ERROR: " || fn:name($src) )
};



(: the main section: define the set of elements that constitute an "event" and output as JSON :)
let $qry_pid_seq as item()* := fn:tokenize($PID_LIST,',')
let $ac := 
  if (not(empty($qry_pid_seq))) then
    cwAccessibility:queryAccessControl(/)[@pid=$qry_pid_seq]
  else if (not(empty($PID_COLLECTION))) then
    cwAccessibility:queryAccessControl(/)[RELS-EXT_DS/rdf:RDF/rdf:Description/fedora:isMemberOfCollection/@rdf:resource=$PID_COLLECTION]
  else
    ()
(:
return
  fn:string-join($ac/@pid/data())
:)
let $events_sequence := ($ac//tei:event | $ac/*/EVENT | $ac/*/EVENTS//((FREESTANDING_EVENT|HOSTED_EVENT)/CHRONSTRUCT) | $ac/*/(WRITING|BIOGRAPHY)//CHRONSTRUCT | $ac/*/mods:mods)
return
(
'{ "items": [&#10;'
,
(
  let $retSeq :=
    for $event_item as element() at $n in $events_sequence
      let $type := local:determineSchemaByRootElement($event_item)
      return
        "{"
        ||
        (: build sequence and join as a string therefore no need to deal with "," in JSON :)
        fn:string-join( 
          (
          local:outputJSON( "schemaType", string( $type ) )
          (: , local:outputJSON( "schema", string(fn:node-name($event_item)) ) :)
          , local:outputJSON("startDate", local:get_start_date($event_item,$type) ) 
          , local:outputJSONNotNull("endDate", local:get_end_date($event_item,$type) )
          , local:get_lat_lng($event_item, $type) 
          , local:outputJSON("group", fn:substring-after($event_item/ancestor::obj/RELS-EXT_DS/rdf:RDF/rdf:Description/fedora:isMemberOfCollection/@rdf:resource/data(), '/') )
          , local:outputJSON("eventType", local:get_event_type($event_item, $type) )
          , local:outputJSON("label", local:get_label($event_item, $type) )
          , local:outputJSON("description", local:get_description($event_item, $type) )
          , local:outputJSONNotNull( "citations", local:get_citations($event_item, $type) )
          , local:outputJSONNotNull( "contributors", local:get_contributors($event_item, $type) )
          , local:outputJSONNotNull( "link", $BASE_URL||'/'||$event_item/ancestor::obj/@pid/data() )
          )
          , ","
        )
        || "}&#10;"
  return
    fn:string-join($retSeq, ',')  
)
,
']}'
)


