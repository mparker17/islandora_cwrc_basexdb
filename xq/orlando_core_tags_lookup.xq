(: 
*
* core tags within documents  - biography/writing/events 
*
*
:)


xquery version "3.0" encoding "utf-8";

import module namespace cwAccessibility="cwAccessibility" at "./islandora_access_control.xq";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "xml";
declare option output:encoding "UTF-8";
declare option output:indent   "no";


declare variable $FEDORA_PID external := "";
declare variable $BASE_URL external := "";


(: convert to Orlando standard name :)

declare function local:convertStandardName($str)
{
  if (contains($str, ' ')) then
    fn:concat(substring-after($str,' '), ', ', substring-before($str,' '))
  else
    $str
};

(: the main section: :)
let $accessible_seq := cwAccessibility:queryAccessControl(/)[@pid=$FEDORA_PID]
let $doc_href := fn:concat($BASE_URL,'/',$accessible_seq/@pid/data())
let $doc_label := fn:string-join( ($accessible_seq/@label/data(),  $accessible_seq/@pid/data()), ' - ')
return
  <div>
    <h2 class="xquery_result">
      <a href="{$doc_href}">{$doc_label}</a>
    </h2>
    <div class="xquery_result_list">
      <ul>
      {
        (: find the researchnote elements and output  :)
        for $item in $accessible_seq/CWRC_DS//(PLACE|NAME|ORGNAME|TITLE|DATE|DATERANGE|DATESTRUCT)[not(parent::RESPONSIBILITY)]
        let $str := fn:string-join($item//text())
        return
          <li>{$item/name()} - text: {$str}
            {
              if ( $item/name() = ('NAME', 'ORGNAME')) then
                (: lookup standard name :)
                let $standard_name :=
                  if ($item/@STANDARD) then
                    $item/@STANDARD/data()
                  else
                    local:convertStandardName($str)
                return
                  (: query standard name :)
                  let $target := cwAccessibility:queryAccessControl(/)[@pid/data()=$item/@REF/data() or (PERSON_DS | ORGANIZATION_DS)/entity/person/identity/variantForms/variant[variantType/text()=orlandoStandardName]/namePart/text() = $standard_name]
                  return
                    if (not($target)) then
                      <d class="error"> - {$standard_name} - no matching entity item found </d>
                    else
                      ()
              else
                ()
            }
            {
              for $attr in $item//@*
              return
                <ul>
                  <li>{$attr/name()} : {$attr/data()}</li>
                </ul>
            }
          </li>
      }
      </ul>
    </div>
  </div>


