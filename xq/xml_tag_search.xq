(: 
*
* An XQuery full-text search with the ability to limit the elements 
* in which the text is searched 
*
*
* 
*
:)


xquery version "3.0" encoding "utf-8";

import module namespace cwAccessibility="cwAccessibility" at "./islandora_access_control.xq";

declare namespace mods = "http://www.loc.gov/mods/v3";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "xml";
declare option output:encoding "UTF-8";
declare option output:indent   "no";


(: parameters passed into the query :)
declare variable $BASE_URL external := "";
declare variable $MARK_NAME := "zzzMARKzzz"; (: search hit marker :)
declare variable $QRY_FACETS as xs:string* external := (); (: e.g. ('P','DIV0') :)
declare variable $QRY_ELEMENTS as xs:string* external := (); (: e.g. ('P','DIV0') :)
declare variable $QRY_TERMS external := "{'Pauline', 'Pauline'}"; (: e.g. "Saturday", "Night" :)


(: 
  * define how to extract a snippet given the varity of schemas 
  * $i = node
  * $qry_facets_seq sequence of element names to restrict results 
  * $qry_elements_seq sequence of element names to restrict results
:)
declare function local:getSnippets($i,$qry_facets_seq, $qry_elements_seq)
{
  for $hit in $i//*[name()=$qry_elements_seq or not($qry_elements_seq)]//*[name()=$qry_facets_seq or empty($qry_facets_seq)]//*[name()=$MARK_NAME]
  return
    <hit>
    {
    if ($hit/(ancestor::P|ancestor::FILEDESC)) then
        $hit/(ancestor::P|ancestor::FILEDESC)
    else if ($hit/(ancestor::HEADING|ancestor::STANDARD|ancestor::AUTHORSUMMARY)) then
        $hit/(ancestor::HEADING|ancestor::STANDARD|ancestor::AUTHORSUMMARY)
    else if ($hit/(ancestor::DIV2)) then
        $hit/(ancestor::DIV2)
    else if ($hit/(ancestor::DIV1|ancestor::WORKSCITED)) then
        $hit/(ancestor::DIV1|ancestor::WORKSCITED)
    else if ($hit/(ancestor::RESEARCHNOTE)) then
        $hit/(ancestor::RESEARCHNOTE)
    else
        $hit/ancestor::*[parent::*/parent::obj]
    }
    </hit> 
};

(: the main section: :)
let $qry_terms_str := $QRY_TERMS
(:
  * assume input in the form ELEMENT,ELEMENT e.g. WRITING,STANDARD
  * passing in "('WRITING')" within the map data struct left the type
  * as a string as opposed to a sequence e.g. xs:string()* See the difference
  * in the two following methods
  *   let $qry_facets_seq as item()* := "('WRITING')" 
  *   let $qry_facets_seq as item()* := ('WRITING') 
  * a more advanced method
  *   http://www.oxygenxml.com/archives/xsl-list/200702/msg00629.html
  *   http://www.xqueryfunctions.com/xq/fn_tokenize.html
 :)
let $qry_facets_seq as item()* := fn:tokenize($QRY_FACETS,',')
let $qry_elements_seq as item()* := fn:tokenize($QRY_ELEMENTS,',')



let $typeQry :=
  if ( empty($qry_elements_seq) and empty($qry_facets_seq) ) then
"no element and no facet"
  else if ( ($qry_elements_seq) and empty($qry_facets_seq) ) then
"element and no facet"
  else if ( empty($qry_elements_seq) and not(empty($qry_facets_seq)) ) then
"no element and facet"
  else
"element and facet"

(: query needs to be equivalent to the xml_tag_search_facet.xq equivalent :)
let $qry :=
  if ( empty($qry_elements_seq) and empty($qry_facets_seq) ) then
    ft:mark(cwAccessibility:queryAccessControl(/)[.//text() contains text {$qry_terms_str} all words using stemming using diacritics insensitive window 6 sentences], $MARK_NAME)
  else if ( not(empty($qry_elements_seq)) and empty($qry_facets_seq) ) then
    ft:mark(cwAccessibility:queryAccessControl(/)[.//*[name()=$qry_elements_seq]//text() contains text {$qry_terms_str} all words using stemming using diacritics insensitive window 6 sentences], $MARK_NAME)
  else if ( empty($qry_elements_seq) and not(empty($qry_facets_seq)) ) then
    ft:mark(cwAccessibility:queryAccessControl(/)[.//*[name()=$qry_facets_seq ]//text() contains text {$qry_terms_str} all words using stemming using diacritics insensitive window 6 sentences], $MARK_NAME)
  else
    ft:mark(cwAccessibility:queryAccessControl(/)[.//*[name()=$qry_elements_seq]//*[name()=$qry_facets_seq ]//text() contains text {$qry_terms_str} all words using stemming using diacritics insensitive window 6 sentences], $MARK_NAME)

return
  <results>
    <query>
      <qry_type>{$typeQry}</qry_type>
      <qry_terms>{$QRY_TERMS}</qry_terms>
      <qry_facets>{$QRY_FACETS}</qry_facets>
      <qry_facets_seq>{$qry_facets_seq}</qry_facets_seq>
      <qry_elements>{$QRY_ELEMENTS}</qry_elements>
      <qry_elements_seq>{$qry_elements_seq}</qry_elements_seq>
    </query>
    {
      for $i score $score in $qry
      return
      <result_item pid="{$i/@pid/data()}">
        <score>{$score}</score>
        <hits>{local:getSnippets($i,$qry_facets_seq, $qry_elements_seq)}</hits>
      </result_item>
    }
  </results>

