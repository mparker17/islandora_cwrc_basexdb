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


declare variable $FEDORA_PID external := "";
declare variable $BASE_URL external := "";
declare variable $QRY_ELEMENTS external := ""; (: e.g. P | DIV :)
declare variable $QRY_TERMS external := ""; (: e.g. "Saturday", "Night" :)
declare variable $MARK_NAME external := "zzMARKzz"; (: element to mark hit :)


(: define how to extract a snippet given the varity of schemas :)
declare function local:getSnippets($i)
{
  for $hit in $i//$MARK_NAME
  return
    <hit>
    {
    if ($hit/anscestor::P) then
      return 
        $hit/anscestor::P
    else
      return 
        $hit/anscestor::obj
    }
    </hit> 
};

(: the main section: :)
let $qry_terms_str := $QRY_TERMS
let $qry_elements_str := 
  if ($QRY_ELEMENTS!="") then 
    concat("(",$QRY_ELEMENTS,")") 
  else 
    ""
let $qry := ft:mark(cwAccessibility:queryAccessControl(/)[[./$qry_elements_str/text() contains text {$qry_terms_str} using stemming using diacritics insensitive window 6 sentences], $MARK_NAME)
for $i score $score in $qry
return
<result_item pid="{$i/@pid/data()}">
  <score>{$score}</score>
  <hits>{local:getSnippets($i)}</hits>
</result_item>


