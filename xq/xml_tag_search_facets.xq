(: 
*
* Provide a list of faceted elements based on the context of the
* results from the XQuery based full-text search with the ability 
* to limit the elements in which the text is searched 
*
* Return a list of bin identifiers representing the facets and thier counts
* 
*
* test:
*   from XML database client
*   set querypath "http://cwrc-dev-01.srv.ualberta.ca/sites/all/modules/islandora_cwrc_basexdb/xq/"
*   open cwrc_main
*   
:)


xquery version "3.0" encoding "utf-8";

import module namespace cwAccessibility="cwAccessibility" at "./islandora_access_control.xq";


declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "json";
declare option output:encoding "UTF-8";
declare option output:indent   "no";

(: parameters passed into the query :)
declare variable $BASE_URL external := "";
declare variable $MARK_NAME := "zzzMARKzzz"; (: search hit marker :)
declare variable $FACET_ELEMENTS external := ('P','DIV0'); (: e.g. P | DIV :)
declare variable $QRY_ELEMENTS external := (); (: e.g. P | DIV :)
declare variable $QRY_TERMS external := "{'Pauline', 'Pauline'}"; (: e.g. "Saturday", "Night" :)
declare variable $config_map external := ""; (: e.g. "Saturday", "Night" :)

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

(: add in the limit for context - $FACET_ELEMENTS :)
(: ToDo: prevent going farther down the tree than the passed in elements when determine facets :)
(: do not return all ancestors - avoid the "obj" element - ancestor::*[not(last()-position()<2) 
:)

declare function local:getDocBinsAsSequence($obj, $config_map, $MARK_NAME)
{
  
  for $elm in $obj//*[name()=$QRY_ELEMENTS or empty($QRY_ELEMENTS)]//*[name()=$FACET_ELEMENTS or empty($FACET_ELEMENTS)]//*[name()=$MARK_NAME]/ancestor::*[not(last()-position()<2)]/node-name()
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
};

(: the main section: :)

let $qry_terms_str := $QRY_TERMS

(: not sure how to write in a better way without the repetition :)
(: * note: mark are added based on the context not on the XPath within
the predicate
 
 xquery ft:mark((obj[.//STANDARD//text() contains text {'Pauline'} all words using stemming using diacritics insensitive window 6 sentences]) )//mark[ancestor::STANDARD]/ancestor::*/fn:node-name()
:)
(: 
* facet_elements are added via the facets selected at the current state 
* query_elements are elements defined outside of the current facet selection
*   these with be ancestors of the current hits may overlap with facet_elements
:)


(: query needs to be equivalent to the xml_tag_search.xq equivalent :)
let $qry :=
  if ( empty($QRY_ELEMENTS) and empty($FACET_ELEMENTS) ) then
    ft:mark(cwAccessibility:queryAccessControl(/)[.//text() contains text {$qry_terms_str} all words using stemming using diacritics insensitive window 6 sentences], $MARK_NAME)
  else if ( empty($QRY_ELEMENTS)=false and empty($FACET_ELEMENTS) ) then
    ft:mark(cwAccessibility:queryAccessControl(/)[.//*[name()=$QRY_ELEMENTS]//text() contains text {$qry_terms_str} all words using stemming using diacritics insensitive window 6 sentences], $MARK_NAME)
  else if ( empty($QRY_ELEMENTS) and empty($FACET_ELEMENTS)=false ) then
    ft:mark(cwAccessibility:queryAccessControl(/)[.//*[name()=$QRY_ELEMENTS]//*[name()=$FACET_ELEMENTS]//text() contains text {$qry_terms_str} all words using stemming using diacritics insensitive window 6 sentences], $MARK_NAME)
  else
    ft:mark(cwAccessibility:queryAccessControl(/)[.//*[name()=$FACET_ELEMENTS]//text() contains text {$qry_terms_str} all words using stemming using diacritics insensitive window 6 sentences], $MARK_NAME)


(: for each object :)
let $bin_seq :=
  for $obj in $qry
  return
    local:getDocBinsAsSequence($obj, $config_map, $MARK_NAME)
(:
    $obj//*[name()=$MARK_NAME]/../name()
    $obj/@pid
:)

(: 
* given a sequence of sequences use group by to elimiate duplicates and count
* instances
 :)
(: 
  * ToDo: prevent addition of the last ',' group by does 
  * weird things if use $bin[position()=1] as the first
  * may not be in the first position after the grouping
  * Could wrap with
  * fn:string-join(for..., ",")
:)

return
  (
  '{'
  ,
  for $bin at $posn in ($bin_seq) 
    let $tmp := $bin 
    group by $tmp
    (: 
      return element { "x" } { $tmp }
      return element { $tmp } { count($bin) } 
    :)
    return
      ('"' || $tmp || '" : "' || count($bin) || '",')
  ,
  '}'
  )



