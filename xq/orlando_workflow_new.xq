(: 
* 
* A test template that follows the Islandora/Fedora access control  
*
* eg.
*
:)


xquery version "3.0" encoding "utf-8";

import module namespace cwAccessibility="cwAccessibility" at "./islandora_access_control.xq";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "xml";
declare option output:encoding "UTF-8";
declare option output:indent   "no";


declare variable $FEDORA_PID external := "cwrc:johnp2-w";
declare variable $BASE_URL external := "";


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
      for $wfItem in $accessible_seq/WORKFLOW/cwrc/workflow
      return
          <li>
            {data($wfItem/@date)} 
            - {data($wfItem/@time)}
            - {data($wfItem/activity/@category)}
            - {data($wfItem/activity/@stamp)}
            - {data($wfItem/activity/@status)}
          </li>
      }
      </ul>
    </div>
  </div>
