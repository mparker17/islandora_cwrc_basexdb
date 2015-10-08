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
(: the main section: :)
let $tmp := 
'{
  "items": [
    {
      "label": "Riding Mountain National Park.",
      "longLabel": "Riding Mountain National Park",
      "group": "Test",
      "eventType": "Unknown",
      "startDate": "2013-09-18",
      "dateType": "Day",
      "images": ["https://upload.wikimedia.org/wikipedia/commons/4/4a/Manitoba_Escarpment.jpg"],
      "urls": ["https://en.wikipedia.org/wiki/Riding_Mountain_National_Park"],
      "location": "Manitoba",
      "latLng": "50.658289,-99.971455",
      "locationType": "Province/State",
      "pointType": "Point",
      "description": "Wikipedia. <i>Riding Mountain National Park</i>. Septemer 18, 2013"
    }
  ]
}
'
return $tmp
