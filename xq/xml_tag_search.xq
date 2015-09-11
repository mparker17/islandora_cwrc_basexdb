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
declare variable $FACET_ELEMENTS external := (); (: e.g. P | DIV :)
declare variable $QRY_ELEMENTS external := (); (: e.g. P | DIV :)
declare variable $QRY_TERMS external := "{'Pauline', 'Pauline'}"; (: e.g. "Saturday", "Night" :)


(: define how to extract a snippet given the varity of schemas :)
declare function local:getSnippets($i)
{
  for $hit in $i//*[name()=$QRY_ELEMENTS or empty($QRY_ELEMENTS)]//*[name()=$FACET_ELEMENTS or empty($FACET_ELEMENTS)]//*[name()=$MARK_NAME]
  return
    <hit>
    {
    if ($hit/ancestor::P) then
        $hit/ancestor::P
    else
        $hit/ancestor::*[parent::*/parent::obj]
    }
    </hit> 
};

(: the main section: :)
let $qry_terms_str := $QRY_TERMS


(: query needs to be equivalent to the xml_tag_search_facet.xq equivalent :)
let $qry :=
  if ( empty($QRY_ELEMENTS) and empty($FACET_ELEMENTS) ) then
    ft:mark(cwAccessibility:queryAccessControl(/)[.//text() contains text {$qry_terms_str} all words using stemming using diacritics insensitive window 6 sentences], $MARK_NAME)
  else if ( empty($QRY_ELEMENTS)=false and empty($FACET_ELEMENTS) ) then
    ft:mark(cwAccessibility:queryAccessControl(/)[.//*[name()=$QRY_ELEMENTS]//text() contains text {$qry_terms_str} all words using stemming using diacritics insensitive window 6 sentences], $MARK_NAME)
  else if ( empty($QRY_ELEMENTS) and empty($FACET_ELEMENTS)=false ) then
    ft:mark(cwAccessibility:queryAccessControl(/)[.//*[name()=$FACET_ELEMENTS]//text() contains text {$qry_terms_str} all words using stemming using diacritics insensitive window 6 sentences], $MARK_NAME)
  else
    ft:mark(cwAccessibility:queryAccessControl(/)[.//*[name()=$QRY_ELEMENTS]//*[name()=$FACET_ELEMENTS]//text() contains text {$qry_terms_str} all words using stemming using diacritics insensitive window 6 sentences], $MARK_NAME)



for $i score $score in $qry
return
<result_item pid="{$i/@pid/data()}">
  <score>{$score}</score>
  <hits>{local:getSnippets($i)}</hits>
</result_item>


