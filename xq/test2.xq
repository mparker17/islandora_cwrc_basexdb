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

(: the main section: :)
let $accessible_seq := cwAccessibility:queryAccessControl( / )
return
for $item in $accessible_seq
return

    <div>
    <h4>{data($item/@label)} - {data($item/@pid)}</h4>
    {
    for $wfItem in $item/WORKFLOW/cwrc/workflow
    return
      <ul>
        <li>
          {data($wfItem/@date)} - {data($wfItem/@time)}
        </li>
        <li>
          {data($wfItem/activity/@category)}
          -
          {data($wfItem/activity/@stamp)}
          -
          {data($wfItem/activity/@status)}
        </li>
      </ul>
    }
    </div>


