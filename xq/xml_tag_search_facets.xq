(: 
*
* Provide a list of faceted elements based on the context of the
* results from the XQuery based full-text search with the ability 
* to limit the elements in which the text is searched 
*
* Return a list of bin identifiers representing the facets and thier counts
* 
*
:)


xquery version "3.0" encoding "utf-8";

import module namespace cwAccessibility="cwAccessibility" at "./islandora_access_control.xq";

declare namespace mods = "http://www.loc.gov/mods/v3";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "json";
declare option output:encoding "UTF-8";
declare option output:indent   "no";


declare variable $FEDORA_PID external := "";
declare variable $BASE_URL external := "";
declare variable $MARK_NAME := "zzzMARKzzz"; (: search hit marker :)
declare variable $QRY_ELEMENTS external := ""; (: e.g. P | DIV :)
declare variable $QRY_TERMS external := ""; (: e.g. "Saturday", "Night" :)
declare variable $config_map external := ""; (: e.g. "Saturday", "Night" :)

(:
* for a given object $obj determine the XPath components for each hit
* defined by an introduced XML element by the XQuery search named $MARK_NAME
* and add each component of the path to a map data structure. 
* The resulting map data structure built based on the binning rules
* defined in the $config_map - i.e. how multiple elements are combined
* into one bin e.g. like a histogram. 
:)
declare function local:getDocMap($obj, $config_map, $MARK_NAME)
{
  
  (: do not return all ancestors - avoid the "obj" element :)
  return
    map:merge(
      for $elm in $qry//$MARK_NAME/ancestor::*[not(last()-position()<2)]/node-name()
        group by $elm
        let $bin :=
          if ($config_map and map:contains($config_map, $elm)) then
            (: put value in bin defined by the $config_map :)
            map:get($config_map, $elm)
          else
            (: put value in bin defined by the element name:)
            $elm
        return
          if ( !map:contains($res_map, $bin)) then
            map:entry($bin, 1)
    )
}

(:
* for a given object $obj determine the XPath components for each hit
* defined by an introduced XML element by the XQuery search named $MARK_NAME
* and add each component of the path to a map data structure. 
* The resulting sequenc data structure built based on the binning rules
* defined in the $config_map - i.e. how multiple elements are combined
* into one bin e.g. like a histogram. 
* If a bin occurs at least once in the object then it is added to the sequence
* once.
:)

declare function local:getDocBinsAsSequence($obj, $config_map, $MARK_NAME)
{
  
  (: do not return all ancestors - avoid the "obj" element :)
  return
      for $elm in $qry//$MARK_NAME/ancestor::*[not(last()-position()<2)]/node-name()
        let $bin :=
          if ($config_map and map:contains($config_map, $elm)) then
            (: put value in bin defined by the $config_map :)
            map:get($config_map, $elm)
          else
            (: put value in bin defined by the element name:)
            $elm
        group by $bin
        return
          $bin
}

(: the main section: :)

let $qry_terms_str := $QRY_TERMS
let $qry_elements_str := 
  if ($QRY_ELEMENTS!="") then 
    concat("(",$QRY_ELEMENTS,")") 
  else 
    ""

(: query needs to be equivalent to the xml_tag_search.xq equivalent :)
let $qry := ft:mark(cwAccessibility:queryAccessControl(/)[[./$qry_elements_str/text() contains text {$qry_terms_str} using stemming using diacritics insensitive window 6 sentences], $MARK_NAME)
(: for each object :)
let $bin_seq :=
  for $obj in $qry
  return
    getDocBinsAsSequence($obj, $config_map, $MARK_NAME)

(: 
* given a sequence of sequences use group by to elimiate duplicates and count
* instances
 :)
for $bin in ($bin_seq) 
  let $tmp := $bin 
  group by $tmp
  return element { $tmp } { count($bin) }



