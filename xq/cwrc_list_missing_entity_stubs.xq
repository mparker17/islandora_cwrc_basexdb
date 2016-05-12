(: output external URIs that don't have a local stub entity :)

xquery version "3.0" encoding "utf-8";

(: declare namespaces used in the content :)
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace tei =  "http://www.tei-c.org/ns/1.0";
declare namespace fedora =  "info:fedora/fedora-system:def/relations-external#";
declare namespace fedora-model="info:fedora/fedora-system:def/model#"; 
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare option output:method "json";
declare option output:encoding "UTF-8";

(: find all the 'person' entities defined by a list of URIs to external sources that don't have local stubs :)
let $personExternalURIs := 
  (
    /obj/CWRC_DS//(tei:persName/@ref|NAME/@REF)
    |
    /obj/MODS_DS/mods:mods/mods:subject/(mods:name[not(@type) or @type='personal']|mods:topic)/@valueURI
    |
    /obj/MODS_DS/mods:mods/mods:name[not(@type) or @type='personal']/@valueURI
    |
    /obj/MODS_DS/mods:mods/mods:relatedItem/mods:name[not(@type) or @type='personal']/@valueURI
  )[not(fn:matches(data(),'cwrc.ca'))]/data()
let $personStubs := /obj/PERSON_DS/entity/person/recordInfo[entityId=$personExternalURIs and orginInfo/projectId = 'VIAF']/entityId/text()
let $personNoExistStubs := $personExternalURIs[not(.=$personStubs)] 


(: find all the 'organization' entities defined by a list of URIs to external sources that don't have local stubs :)
let $orgExternalURIs := 
  (
    /obj/CWRC_DS//(tei:orgName/@ref|ORGNAME/@REF)
    |
    /obj/MODS_DS/mods:mods/mods:subject/(mods:name[@type='corperate']|mods:topic)/@valueURI
    |
    /obj/MODS_DS/mods:mods/mods:name[@type='corperate']/@valueURI
    |
    /obj/MODS_DS/mods:mods/mods:relatedItem/mods:name[@type='corperate']/@valueURI    
  )[not(fn:matches(data(),'cwrc.ca'))]/data()
let $orgStubs := /obj/ORGANIZATION_DS/entity/organization/recordInfo[entityId=$orgExternalURIs and orginInfo/projectId = 'VIAF']/entityId/text()
let $orgNoExistStubs := $orgExternalURIs[not(.=$orgStubs)] 


(: find all the 'place' entities defined by a list of URIs to external sources that don't have local stubs :)
let $placeExternalURIs := 
  (
    /obj/CWRC_DS//(tei:placeName/@ref|PLACE/@REF)
    |
    /obj/MODS_DS/mods:mods/mods:subject/(mods:geographic|mods:topic)/@valueURI
    |
    /obj/MODS_DS/mods:mods/mods:originInfo/mods:place/mods:placeTerm/@valueURI
    |
    /obj/MODS_DS/mods:mods/mods:relatedItem/mods:originInfo/mods:place/mods:placeTerm/@valueURI    
  )[not(fn:matches(data(),'cwrc.ca'))]/data()
(: assume that don't need to spearate by geonames and google Maps:)  
let $placeStubs := /obj/PLACE_DS/entity/place/recordInfo[entityId=$placeExternalURIs and orginInfo/projectId = ('GeoNames', 'Google Maps')]/entityId/text()
let $placeNoExistStubs := $placeExternalURIs[not(.=$placeStubs)] 


(: find all the 'title' entities defined by a list of URIs to external sources that don't have local stubs :)
let $titleExternalURIs := 
  (
    /obj/CWRC_DS//(tei:title/@ref|tei:note/tei:bibl/@ref|TITLE/@REF|BIBCITS/BIBCIT/@REF|TEXTSCOPE/@REF)
    |
    /obj/MODS_DS/mods:mods/mods:subject/(mods:name|mods:topic|mods:titleInfo)/@valueURI
    |
    /obj/MODS_DS/mods:mods/mods:titleInfo/@valueURI
    |
    /obj/MODS_DS/mods:mods/mods:relatedItem/mods:titleInfo/@valueURI
  )[not(fn:matches(data(),'cwrc.ca'))]/data()
let $titleStubs := /obj/MODS_DS/mods:mods[mods:recordInfo/mods:recordContentSource='VIAF']/mods:identifier[text()=$titleExternalURIs]/text()
let $titleNoExistStubs := $titleExternalURIs[not(.=$titleStubs)] 




return 
<json type='object' objects='missingStubs'>
<missingStubs type='array'>
{
  for $i in ($personNoExistStubs, $orgNoExistStubs, $placeNoExistStubs, $titleNoExistStubs)
  return
  <_>
  {$i}
  </_>
}
</missingStubs>
</json>
