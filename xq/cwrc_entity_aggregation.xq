(: output JSON used to build an Entity Aggregation page :)

xquery version "3.0" encoding "utf-8";

(: import helper modules :)
import module namespace cwAccessibility="cwAccessibility" at "./islandora_access_control.xq"; (: Fedora XACML permissions :)
import module namespace cwJSON="cwJSON" at "./cwrc_JSON_helpers.xq"; (: common JSON functions :)


(: declare namespaces used in the content :)
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace tei =  "http://www.tei-c.org/ns/1.0";
declare namespace fedora =  "info:fedora/fedora-system:def/relations-external#";
declare namespace fedora-model="info:fedora/fedora-system:def/model#"; 
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";

(: options :)
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
(: declare option output:method   "xml"; :)
declare option output:method "adaptive";
declare option output:encoding "UTF-8";
declare option output:indent   "no";

(: declare boundary-space preserve; :)
(: database must be imported with the following option otherwise text nodes have the begining and ending whitespace "chopped off" which is undesireable for mixed content:)
declare option db:chop 'false';

(: external variables :)
declare variable $FEDORA_PID external := "";
declare variable $BASE_URL external := "";
declare variable $ENTITY_URI external := ();

(: internal constants :)
declare variable $ENTITY_SOURCE_CWRC as xs:string := 'CWRC';
declare variable $ENTITY_SOURCE_VIAF as xs:string := 'VIAF';
declare variable $ENTITY_SOURCE_GEONAMES as xs:string := 'GEONAMES';
declare variable $CMODEL_MULTIMEDIA := ("info:fedora/islandora:sp_basic_image", "info:fedora/islandora:sp_large_image_cmodel", "info:fedora/islandora:sp-audioCModel", "info:fedora/islandora:sp_videoCModel");

(: 
* Helper functions  
:)


(: given an URI, determine the source e.g. cwrc, viaf, geonames, etc. :)
declare function local:getEntitySource($query_uri) as xs:string?
{
    if ( matches($query_uri,'cwrc.ca') ) then
        ( $ENTITY_SOURCE_CWRC )
    else if ( matches($query_uri,'viaf.org') ) then
        ( $ENTITY_SOURCE_VIAF )
    else if ( matches($query_uri,'www.geonames.org') ) then
        ( $ENTITY_SOURCE_GEONAMES )
    else
        ( '' )
};

(: given a PERSON object XML node, fill out the Profile section of the JSON return :)
declare function local:populateProfilePerson($obj,$objCModel)
{
  ',&#10;'
  || "profile: {"
  || 
  fn:string-join(
    (
      cwJSON:outputJSON("label", $obj/@label/data() )

      , cwJSON:outputJSONNotNull("factuality", $obj/PERSON_DS//entity/person/description/factuality/text() )
      , cwJSON:outputJSONArray("genders", $obj/PERSON_DS//entity/person/description/gender/genders/text() )
      , cwJSON:outputJSONArray("activities", $obj/PERSON_DS//entity/person/description/activities/activity/text() )
      , cwJSON:outputJSONArray("interests", $obj/PERSON_DS//entity/person/description/researchInterests/interest/text() )
      , cwJSON:outputJSONArray("occupations", $obj/PERSON_DS//entity/person/description/occupations/occupation/text() )
      , cwJSON:outputJSONArray("resources", $obj/PERSON_DS//entity/person/description/relatedResources/resource/text() )
      , cwJSON:outputJSONArray("personTypes", $obj/PERSON_DS//entity/person/relatedInfor/personTypes/personType/text() )
      , cwJSON:outputJSONArray ("projectIDs", $obj/PERSON_DS//entity/person/recordInfo/originInfo/projectId/text() )      
      , cwJSON:outputJSONNotNull("pid", $obj/@pid/data() )
      , cwJSON:outputJSONNotNull("createDate", $obj/@createDate/data() )
      , cwJSON:outputJSONNotNull("modifiedDate", $obj/@modifiedDate/data() )      
      , cwJSON:outputJSONNotNull("modifiedDate", $obj/@modifiedDate/data() )      
      , cwJSON:outputJSONNotNull("cModel", $objCModel )      
    )
  )
  || '}'
};


(: given an ORGANIZATION object XML node, fill out the Profile section of the JSON return :)
declare function local:populateProfileOrganization($obj,$objCModel)
{
  ',&#10;'
  || "profile: {"
  || 
  fn:string-join(
    (
      cwJSON:outputJSON("label", $obj/@label/data() )
      , cwJSON:outputJSONArray ("projectIDs", $obj/ORGANIZATION_DS/entity/person/recordInfo/originInfo/projectId/text() )
      , cwJSON:outputJSONNotNull("factuality", $obj/ORGANIZATION_DS/entity/person/description/factuality/text() )
      , cwJSON:outputJSONArray("genders", $obj/ORGANIZATION_DS/entity/person/description/gender/genders/text() )
      , cwJSON:outputJSONNotNull("pid", $obj/@pid/data() )
      , cwJSON:outputJSONNotNull("createDate", $obj/@createDate/data() )
      , cwJSON:outputJSONNotNull("modifiedDate", $obj/@modifiedDate/data() )
      , cwJSON:outputJSONNotNull("cModel", $objCModel )      
    )
  )
  || '}'
};


(: given an PLACE object XML node, fill out the Profile section of the JSON return :)
declare function local:populateProfilePlace($obj,$objCModel)
{
  ',&#10;'
  || "profile: {"
  || 
  fn:string-join(
    (
      cwJSON:outputJSON("label", $obj/@label/data() )
      , cwJSON:outputJSONArray ("projectIDs", $obj/PLACE_DS/entity/person/recordInfo/originInfo/projectId/text() )
      , cwJSON:outputJSONNotNull("factuality", $obj/PLACE_DS/entity/person/description/factuality/text() )
      , cwJSON:outputJSONNotNull("pid", $obj/@pid/data() )
      , cwJSON:outputJSONNotNull("createDate", $obj/@createDate/data() )
      , cwJSON:outputJSONNotNull("modifiedDate", $obj/@modifiedDate/data() )
      , cwJSON:outputJSONNotNull("cModel", $objCModel )      
    )
  )
  || '}'
};


(: given an TITLE object XML node, fill out the Profile section of the JSON return :)
declare function local:populateProfileTitle($obj,$objCModel)
{
  ',&#10;'
  || "profile: {"
  || 
  fn:string-join(
    (
      cwJSON:outputJSON("label", $obj/@label/data() )
      , cwJSON:outputJSONArray ("projectIDs", $obj/PERSON_DS/entity/person/recordInfo/originInfo/projectId/text() )
      , cwJSON:outputJSONNotNull("factuality", $obj/PERSON_DS/entity/person/description/factuality/text() )
      , cwJSON:outputJSONArray("genders", $obj/PERSON_DS/entity/person/description/gender/genders/text() )
      , cwJSON:outputJSONArray("occupations", $obj/PERSON_DS/entity/person/description/occupations/occupation/text() )
      , cwJSON:outputJSONArray("activities", $obj/PERSON_DS/entity/person/description/activities/activity/text() )      
      , cwJSON:outputJSONArray("interests", $obj/PERSON_DS/entity/person/description/researchInterests/interest/text() )      
      , cwJSON:outputJSONNotNull("pid", $obj/@pid/data() )
      , cwJSON:outputJSONNotNull("createDate", $obj/@createDate/data() )
      , cwJSON:outputJSONNotNull("modifiedDate", $obj/@modifiedDate/data() )
      , cwJSON:outputJSONNotNull("cModel", $objCModel )      
    )
  )
  || '}'
};




(: 
* Build the entity profile components for a given entity URI and return a JSON result
* E.G. name, gender, etc.
* base on the cModel of the given URI
:)
declare function local:buildEntityProfile($entityObj, $entityCModel) as xs:string?
{

        switch ( $objCModel )
            case "info:fedora/cwrc:person-entityCModel" 
                return local:populateProfilePerson($obj,$objCModel)
            case "info:fedora/cwrc:organization-entityCModel"
                return local:populateProfileOrganization($obj,$objCModel)
            case "info:fedora/cwrc:organization-entityCModel"
                return local:populateProfilePlace($obj,$objCModel)
            case "info:fedora/cwrc:organization-entityCModel"
                return local:populateProfileTitle($obj,$objCModel)                
            default 
                return ''
};


(: **************** Material section ********************** :)

(:
* given a sequence of URIs, find all the material that reference that entity
* e.g., use one of the URIs as a reference target in a given context
:)
declare function local:populateMaterialPerson($query_uri_seq) as xs:string
{
      
    (: Entries about a given person :)
    (: cModel = cwrc:documentCModel & mods:genre = ("Biography", "Born digital") & mods:subject/mods:name/@valueURI :)
    let $entries_about :=
        cwJSON:outputJSONArray ("entries_about", cwAccessibility:queryAccessControl(/)[
            RELS-EXT_DS/rdf:RDF/rdf:Description/fedora-model:hasModel/@rdf:resource/data()="info:fedora/cwrc:documentCModel" 
            and MODS_DS/mods:mods/mods:genre/text() = ("Biography", "Born digital") 
            and MODS_DS/mods:mods/mods:subject/mods:name/@valueURI = $query_uri_seq
            ]/@pid/data() 
            )
            
    (: Works of the given person :)
    (: mods:name/@valueURI :)
    let $works :=
        cwJSON:outputJSONArray ("works", cwAccessibility:queryAccessControl(/)[
            MODS_DS/mods:mods/mods:name/@valueURI=$query_uri_seq
            ]/@pid/data() 
            )
            
            
    (: Mentions of a given person (excluding about the given person) :)    
    (: cModel = cwrc:documentCModel & mods:genre = ("Biography", "Born digital") & NOT(mods:subject/mods:name/@valueURI) :)
    (: TEI ==> /persName/@ref or CWRC entry ==>/NAME/@REF or Orlando ==> /NAME/@REF or /subject/topic/@valueURI :)
    (: QUESTION: does look into the "content" datastream i.e. TEI/CWRC/Orlando schemas? :)
    let $entries_mentioning :=
        cwJSON:outputJSONArray ("entries_mentioning", cwAccessibility:queryAccessControl(/)[
            RELS-EXT_DS/rdf:RDF/rdf:Description/fedora-model:hasModel/@rdf:resource/data()="info:fedora/cwrc:documentCModel" 
            and MODS_DS/mods:mods/mods:genre/text() = ("Biography", "Born digital") 
            and MODS_DS/mods:mods/mods:subject/mods:name/@valueURI != $query_uri_seq
            and (
                CWRC_DS//(persName/@ref|NAME/@REF)=$query_uri_seq
                or
                MODS_DS/mods:mods/mods:subject/mods:topic/@valueURI=$query_uri_seq
                )
            ]/@pid/data()
            )
            
    (: bibliographic about the given person :) 
    (: mods:subject/mods:name/@valueURI :)
    let $bibliographic_about :=
        cwJSON:outputJSONArray ("bibliographic_about", cwAccessibility:queryAccessControl(/)[
            MODS_DS/mods:mods/mods:subject/mods:name/@valueURI = $query_uri_seq]/@pid/data() 
            )
            
            
    (: multimedia objects about the given person :)
    (: cModel = ("info:fedora/islandora:sp_basic_image", "info:fedora/islandora:sp_large_image_cmodel",     
        "info:fedora/islandora:sp-audioCModel", "info:fedora/islandora:sp_videoCModel") and mods:subject/mods:name/@valueURI  :)
    let $multimedia :=
        cwJSON:outputJSONArray ("multimedia", cwAccessibility:queryAccessControl(/)[
            RELS-EXT_DS/rdf:RDF/rdf:Description/fedora-model:hasModel/@rdf:resource/data() = $CMODEL_MULTIMEDIA 
            and 
               (
                MODS_DS/mods:mods/mods:subject/(mods:subject|mods:topic)/@valueURI = $query_uri_seq
                or 
                MODS_DS/mods:mods/name/@valueURI = $query_uri_seq
                or 
                MODS_DS/mods:mods/mods:relatedItem/mods:name/@valueURI = $query_uri_seq
                )
            ]/@pid/data()
            )        
    
    return 
        string-join(
            (
            cwJSON:outputJSONArray ("entries_about", $entries_about )
            , cwJSON:outputJSONArray ("bilbiographic_about", $works )
            , cwJSON:outputJSONArray ("entries_other", $entries_mentioning )
            , cwJSON:outputJSONArray ("bibliographic_related", $bibliographic_about )
            , cwJSON:outputJSONArray ("multimedia", $multimedia )        
            )
            , ','
        )    
    
};

declare function local:populateMaterialOrganization($query_uri_seq) as xs:string
{

    (: Entries about a given person :)     
    (: cModel = cwrc:documentCModel & mods:genre = ("Biography", "Born digital") & mods:subject/mods:name/@valueURI :)
    (: same as person "entries_about" :)
    let $entries_about :=
        cwJSON:outputJSONArray ("entries_about", cwAccessibility:queryAccessControl(/)[
            RELS-EXT_DS/rdf:RDF/rdf:Description/fedora-model:hasModel/@rdf:resource/data()="info:fedora/cwrc:documentCModel" 
            and MODS_DS/mods:mods/mods:genre/text() = ("Biography", "Born digital") 
            and MODS_DS/mods:mods/mods:subject/mods:name/@valueURI = $query_uri_seq
            ]/@pid/data() 
            )
            
    (: bibliographic about a given organization :)    
    (: mods:subject/topic/@valueURI :)
    let $bibliographic_about :=
        cwJSON:outputJSONArray ("bibliographic_about", cwAccessibility:queryAccessControl(/)[
            MODS_DS/mods:mods/mods:subject/mods:topic/@valueURI=$query_uri_seq
            ]/@pid/data() 
            )
            
    (: bibliographic mentioning the given organization - author/editor ( :)    
    (: unfortunately, the LC has not defined a @valueURI attribute for the /originInfo/publisher element :)
    (: mods:name/@valueURI or mods:relatedItem/name :)
    let $bibliographic_related :=
        cwJSON:outputJSONArray ("bibliographic_related", cwAccessibility:queryAccessControl(/)[
            MODS_DS/mods:mods/mods:name/@valueURI=$query_uri_seq
            or
            MODS_DS/mods:mods/mods:relatedItem/mods:name/@valueURI=$query_uri_seq
            ]/@pid/data() 
            )
         
 
    (: Mentions of a given org (excluding about the given or) :)    
    (: cModel = cwrc:documentCModel & mods:genre = ("Biography", "Born digital") & NOT(mods:subject/mods:name/@valueURI) :)
    (: TEI ==> /persName/@ref or CWRC entry ==>/NAME/@REF or Orlando ==> /NAME/@REF or /subject/topic/@valueURI :)
    (: QUESTION: does look into the "content" datastream i.e. TEI/CWRC/Orlando schemas? :)
    let $entries_mentioning :=
        cwJSON:outputJSONArray ("entries_mentioning", cwAccessibility:queryAccessControl(/)[
            RELS-EXT_DS/rdf:RDF/rdf:Description/fedora-model:hasModel/@rdf:resource/data()="info:fedora/cwrc:documentCModel" 
            and MODS_DS/mods:mods/mods:genre/text() = ("Biography", "Born digital") 
            and MODS_DS/mods:mods/mods:subject/mods:name/@valueURI != $query_uri_seq
            and (
                CWRC_DS//(tei:orgName/@ref|ORGNAME/@REF)=$query_uri_seq
                or
                MODS_DS/mods:mods/mods:subject/mods:topic/@valueURI=$query_uri_seq
                )
            ]/@pid/data()
            )
            
    
    (: multimedia objects about the given organization :)
    (: cModel = ("info:fedora/islandora:sp_basic_image", "info:fedora/islandora:sp_large_image_cmodel",  
    info:fedora/islandora:sp-audioCModel", "info:fedora/islandora:sp_videoCModel") and mods:subject/mods:name/@valueURI  :)
    let $multimedia :=
        cwJSON:outputJSONArray ("multimedia", cwAccessibility:queryAccessControl(/)[
            RELS-EXT_DS/rdf:RDF/rdf:Description/fedora-model:hasModel/@rdf:resource/data() = $CMODEL_MULTIMEDIA 
            and 
               (
                MODS_DS/mods:mods/mods:subject/(mods:subject|mods:topic)/@valueURI = $query_uri_seq
                or 
                MODS_DS/mods:mods/name/@valueURI = $query_uri_seq
                or 
                MODS_DS/mods:mods/mods:relatedItem/mods:name/@valueURI = $query_uri_seq
                )
            ]/@pid/data()
            )
    
    return 
        string-join(
            (
            cwJSON:outputJSONArray ("entries_about", $entries_about )
            , cwJSON:outputJSONArray ("bilbiographic_about", $bibliographic_about )
            , cwJSON:outputJSONArray ("entries_other", $entries_mentioning )
            , cwJSON:outputJSONArray ("bibliographic_related", $bibliographic_related )
            , cwJSON:outputJSONArray ("multimedia", $multimedia )        
            )
            , ','
        )
};

declare function local:populateMaterialPlace($query_uri_seq) as xs:string
{
    (: Entries about a given place :)     
    (: cModel = cwrc:documentCModel & mods:genre = ("Biography", "Born digital") & mods:subject/mods:geographic/@valueURI :)
    let $entries_about :=
        cwJSON:outputJSONArray ("entries_about", cwAccessibility:queryAccessControl(/)[
            RELS-EXT_DS/rdf:RDF/rdf:Description/fedora-model:hasModel/@rdf:resource/data()="info:fedora/cwrc:documentCModel" 
            and MODS_DS/mods:mods/mods:genre/text() = ("Biography", "Born digital") 
            and MODS_DS/mods:mods/mods:subject/mods:geographic/@valueURI = $query_uri_seq
            ]/@pid/data() 
            )
            
    (: bibliographic about a given place :)    
    (: mods:subject/topic/@valueURI :)
    let $bibliographic_about :=
         cwJSON:outputJSONArray ("bibliographic_about", cwAccessibility:queryAccessControl(/)[
            MODS_DS/mods:mods/mods:subject/mods:topic/@valueURI=$query_uri_seq
            ]/@pid/data() 
            )

    (: Mentions of a given place (excluding about the given or) :)    
    (: cModel = cwrc:documentCModel & mods:genre = ("Biography", "Born digital") & NOT(mods:subject/mods:geogrpahic/@valueURI) :)
    (: TEI ==> /persName/@ref or CWRC entry ==>/NAME/@REF or Orlando ==> /NAME/@REF or /subject/(geographic|topic)/@valueURI :)
    let $entries_mentioning :=
        cwJSON:outputJSONArray ("entries_mentioning", cwAccessibility:queryAccessControl(/)[
            RELS-EXT_DS/rdf:RDF/rdf:Description/fedora-model:hasModel/@rdf:resource/data()="info:fedora/cwrc:documentCModel" 
            and MODS_DS/mods:mods/mods:genre/text() = ("Biography", "Born digital") 
            and MODS_DS/mods:mods/mods:subject/mods:geographic/@valueURI != $query_uri_seq
            and (
                CWRC_DS//(tei:placeName/@ref|PLACE/@REF)=$query_uri_seq
                or
                MODS_DS/mods:mods/mods:subject/mods:topic/@valueURI=$query_uri_seq
                )
            ]/@pid/data()
            )

    (: bibliographic mentioning the givenplace ( :)    
    (:  :)
    (:  :)
    let $bibliographic_related :=
        cwJSON:outputJSONArray ("bibliographic_related", cwAccessibility:queryAccessControl(/)[
            MODS_DS/mods:mods/mods:originInfo/mods:place/@valueURI=$query_uri_seq
            or
            MODS_DS/mods:mods/mods:relatedItem/mods:orginInfo/mods:place/@valueURI=$query_uri_seq
            ]/@pid/data() 
            )
         

    (: multimedia objects about the given ploace :)
    (: cModel = ("info:fedora/islandora:sp_basic_image", "info:fedora/islandora:sp_large_image_cmodel",  
    info:fedora/islandora:sp-audioCModel", "info:fedora/islandora:sp_videoCModel") and mods:subject/mods:name/@valueURI  :)
    let $multimedia :=
        cwJSON:outputJSONArray ("multimedia", cwAccessibility:queryAccessControl(/)[
            RELS-EXT_DS/rdf:RDF/rdf:Description/fedora-model:hasModel/@rdf:resource/data() = $CMODEL_MULTIMEDIA 
            and 
               (
                MODS_DS/mods:mods/mods:subject/(mods:geographic|mods:topic)/@valueURI = $query_uri_seq
                or 
                MODS_DS/mods:mods/mods:originInfo/place/placeTerm/@valueURI = $query_uri_seq
                or 
                MODS_DS/mods:mods/mods:relatedItem/mods:originInfo/place/placeTerm/@valueURI = $query_uri_seq                
                )
            ]/@pid/data()
            )
            
    return 
        string-join(
            (
            cwJSON:outputJSONArray ("entries_about", $entries_about )
            , cwJSON:outputJSONArray ("bilbiographic_about", $bibliographic_about )
            , cwJSON:outputJSONArray ("entries_other", $entries_mentioning )
            , cwJSON:outputJSONArray ("bilbiographic_related", $bibliographic_about )
            , cwJSON:outputJSONArray ("multimedia", $multimedia )        
            )
            , ','
        )
};

declare function local:populateMaterialTitle($query_uri_seq) as xs:string
{

    (: Entries about a given title :)     
    (: cModel = cwrc:documentCModel & mods:genre = ("Biography", "Born digital") & mods:subject/mods:geographic/@valueURI :)
    let $entries_about :=
        cwJSON:outputJSONArray ("entries_about", cwAccessibility:queryAccessControl(/)[
            RELS-EXT_DS/rdf:RDF/rdf:Description/fedora-model:hasModel/@rdf:resource/data()="info:fedora/cwrc:documentCModel" 
            and MODS_DS/mods:mods/mods:genre/text() = ("Biography", "Born digital") 
            and MODS_DS/mods:mods/mods:subject/mods:titleInfo/@valueURI = $query_uri_seq
            ]/@pid/data() 
            )
            
    (: bibliographic about a given place :)    
    (: mods:subject/topic/@valueURI :)
    let $bibliographic_about :=
         cwJSON:outputJSONArray ("bibliographic_about", cwAccessibility:queryAccessControl(/)[
            MODS_DS/mods:mods/mods:subject/mods:topic/@valueURI=$query_uri_seq
            ]/@pid/data() 
            )
            
    (: Mentions of a given title (excluding about the given or) :)    
    (: cModel = cwrc:documentCModel & mods:genre = ("Biography", "Born digital") & NOT(mods:subject/mods:geogrpahic/@valueURI) :)
    (:  :)
    let $entries_mentioning :=
        cwJSON:outputJSONArray ("entries_mentioning", cwAccessibility:queryAccessControl(/)[
            RELS-EXT_DS/rdf:RDF/rdf:Description/fedora-model:hasModel/@rdf:resource/data()="info:fedora/cwrc:documentCModel" 
            and MODS_DS/mods:mods/mods:genre/text() = ("Biography", "Born digital") 
            and MODS_DS/mods:mods/mods:subject/mods:geographic/@valueURI != $query_uri_seq
            and (
                CWRC_DS//(tei:title/@ref/data()|TITLE/@REF)=$query_uri_seq
                or
                CWRC_DS//(tei:note/tei:bibl/@ref|BIBCIT/@REF)=$query_uri_seq
                or                
                MODS_DS/mods:mods/mods:subject/mods:topic/@valueURI=$query_uri_seq
                )
            ]/@pid/data()
            )

    (: multimedia objects about the given title :)
    (: cModel = ("info:fedora/islandora:sp_basic_image", "info:fedora/islandora:sp_large_image_cmodel",  
    info:fedora/islandora:sp-audioCModel", "info:fedora/islandora:sp_videoCModel") and mods:subject/mods:name/@valueURI  :)
    let $multimedia :=
        cwJSON:outputJSONArray ("multimedia", cwAccessibility:queryAccessControl(/)[
            RELS-EXT_DS/rdf:RDF/rdf:Description/fedora-model:hasModel/@rdf:resource/data() = $CMODEL_MULTIMEDIA 
            and 
               (
                MODS_DS/mods:mods/mods:subject/mods:topic/@valueURI = $query_uri_seq
                or 
                MODS_DS/mods:mods/mods:subject/mods:titleInfo/mods:title/@valueURI = $query_uri_seq
                or
                MODS_DS/mods:mods/name/@valueURI = $query_uri_seq
                or 
                MODS_DS/mods:mods/mods:relatedItem/mods:name/@valueURI = $query_uri_seq
                )
            ]/@pid/data()
            )
        
    return 
        string-join(
            (
            cwJSON:outputJSONArray ("entries_about", $entries_about )
            , cwJSON:outputJSONArray ("bilbiographic_about", $bibliographic_about )
            , cwJSON:outputJSONArray ("entries_other", $entries_mentioning )
            , cwJSON:outputJSONArray ("multimedia", $multimedia )        
            )
            , ','
        )
};



(: 
* Build the entity material components ( for a given entity URI and return a JSON result
* E.G., entires, oeuvre, multimedia, etc.)
:)
declare function local:buildEntityMaterial($query_uri_seq, $entityCModel) as xs:string?
{
  ',&#10;'
  || "material: {"
  ||
    (
    switch ( $entityCModel )
            case "info:fedora/cwrc:person-entityCModel" 
                return local:populateMaterialPerson($query_uri_seq)
            case "info:fedora/cwrc:organization-entityCModel"
                return local:populateMaterialOrganization($query_uri_seq)
            case "info:fedora/cwrc:organization-entityCModel"
                return local:populateMaterialPlace($query_uri_seq)
            case "info:fedora/cwrc:organization-entityCModel"
                return local:populateMaterialTitle($query_uri_seq)                
            default 
                return ''
    )
};


(: ************ Assocations ******************* :)

(:
Co-mentions (associations) logic: (i.e. definition of co-mentions)
Main entity (entity for which the EAP is being built) → mentioned in the MODS datastream of an object
List all the other entities referenced in that MODS datastream
Entity mentioned in the object datastream of a CWRCDocument cModel object
If:
CWRC Document cModel object meets the criteria to be labeled as the entry associated with the main entity → list all entities referenced in that entry
Else:
→ list only the entities referenced in the same chronstruct (CWRC, orlando)/tei:event/p/tei:note/ with the main entity

:)


(: given a person URI - find co-mentions of person  - see above for general definition of "co-mention":)
declare function local:populatePersonCoMentioningPerson($query_uri_seq)
{
    let $uris_mods :=
        cwAccessibility:queryAccessControl(/)[
            MODS_DS/mods:mods/mods:subject/mods:name/@valueURI=$query_uri_seq
            or
            MODS_DS/mods:mods/mods:subject/mods:topic/@valueURI=$query_uri_seq 
            ]/(
                MODS_DS/mods:mods/mods:subject/(mods:name|mods:topic)/@valueURI[data()!=$query_uri_seq]/data()
                |
                MODS_DS/mods:mods/name/@valueURI[data()!=$query_uri_seq]/data()
                | 
                MODS_DS/mods:mods/mods:relatedItem/mods:name/@valueURI[data()!=$query_uri_seq]/data()
            )
    let $uris_entries_about :=
        cwAccessibility:queryAccessControl(/)[
            RELS-EXT_DS/rdf:RDF/rdf:Description/fedora-model:hasModel/@rdf:resource/data()="info:fedora/cwrc:documentCModel" 
            and MODS_DS/mods:mods/mods:genre/text() = ("Biography", "Born digital") 
            and MODS_DS/mods:mods/mods:subject/mods:name/@valueURI = $query_uri_seq
            ]/(
                CWRC_DS//(tei:persName/@ref/data()|NAME/@REF/data())
            )
    let $uris_entries_context :=
        cwAccessibility:queryAccessControl(/)/(
                CWRC_DS//tei:persName[
                    (ancestor::tei:event|ancestor::tei:note|ancestor::tei:p)/descendant::tei:persName/@ref/data()=$query_uri_seq
                    ]/@ref
                |
                CWRC_DS//NAME[(ancestor::CHRONSTRUCT|ancestor::P)/descendant::NAME/@REF/data()=$query_uri_seq]/@REF
                )/data()
      
      
    return
        ( distinct-values( ($uris_mods, $uris_entries_about, $uris_entries_context) ) )     
        
};

(: given a person URI - find co-mentions of organization  - see above for general definition of "co-mention":)
declare function local:populatePersonCoMentioningOrganization($query_uri_seq)
{
    let $uris_mods :=
        cwAccessibility:queryAccessControl(/)[
            MODS_DS/mods:mods/mods:subject/mods:name/@valueURI=$query_uri_seq
            or
            MODS_DS/mods:mods/mods:subject/mods:topic/@valueURI=$query_uri_seq 
            ]/(
                MODS_DS/mods:mods/mods:subject/(mods:name|mods:topic)/@valueURI[data()!=$query_uri_seq]/data()
                |
                MODS_DS/mods:mods/name/@valueURI[data()!=$query_uri_seq]/data()
                | 
                MODS_DS/mods:mods/mods:relatedItem/mods:name/@valueURI[data()!=$query_uri_seq]/data()
            )
    let $uris_entries_about :=
        cwAccessibility:queryAccessControl(/)[
            RELS-EXT_DS/rdf:RDF/rdf:Description/fedora-model:hasModel/@rdf:resource/data()="info:fedora/cwrc:documentCModel" 
            and MODS_DS/mods:mods/mods:genre/text() = ("Biography", "Born digital") 
            and MODS_DS/mods:mods/mods:subject/mods:name/@valueURI = $query_uri_seq
            ]/(
                CWRC_DS//(tei:orgName/@ref/data()|ORGNAME/@REF/data())
            )
    let $uris_entries_context :=
        cwAccessibility:queryAccessControl(/)/(
                CWRC_DS//tei:orgName[
                    (ancestor::tei:event|ancestor::tei:note|ancestor::tei:p)/descendant::tei:persName/@ref/data()=$query_uri_seq
                    ]/@ref
                |
                CWRC_DS//ORGNAME[(ancestor::CHRONSTRUCT|ancestor::P)/descendant::NAME/@REF/data()=$query_uri_seq]/@REF
                )/data()
      
      
    return
        ( distinct-values( ($uris_mods, $uris_entries_about, $uris_entries_context) ) )     
        
};

(: given a person URI - find co-mentions of places  - see above for general definition of "co-mention":)
declare function local:populatePersonCoMentioningPlace($query_uri_seq)
{
    let $uris_mods :=
        cwAccessibility:queryAccessControl(/)[
            MODS_DS/mods:mods/mods:subject/mods:name/@valueURI=$query_uri_seq
            or
            MODS_DS/mods:mods/mods:subject/mods:topic/@valueURI=$query_uri_seq 
            ]/(
                MODS_DS/mods:mods/mods:subject/(mods:geographic|mods:topic)/@valueURI = $query_uri_seq
                | 
                MODS_DS/mods:mods/mods:originInfo/place/placeTerm/@valueURI = $query_uri_seq
                | 
                MODS_DS/mods:mods/mods:relatedItem/mods:originInfo/place/placeTerm/@valueURI = $query_uri_seq            
            )
    let $uris_entries_about :=
        cwAccessibility:queryAccessControl(/)[
            RELS-EXT_DS/rdf:RDF/rdf:Description/fedora-model:hasModel/@rdf:resource/data()="info:fedora/cwrc:documentCModel" 
            and MODS_DS/mods:mods/mods:genre/text() = ("Biography", "Born digital") 
            and MODS_DS/mods:mods/mods:subject/mods:name/@valueURI = $query_uri_seq
            ]/(
                CWRC_DS//(tei:placeName/@ref/data()|PLACE/@REF/data())
            )
    let $uris_entries_context :=
        cwAccessibility:queryAccessControl(/)/(
                CWRC_DS//tei:placeName[
                    (ancestor::tei:event|ancestor::tei:note|ancestor::tei:p)/descendant::tei:persName/@ref/data()=$query_uri_seq
                    ]/@ref
                |
                CWRC_DS//PLACE[(ancestor::CHRONSTRUCT|ancestor::P)/descendant::NAME/@REF/data()=$query_uri_seq]/@REF
                )/data()
      
      
    return
        ( distinct-values( ($uris_mods, $uris_entries_about, $uris_entries_context) ) )     
};












(: *** ORGANIZATION *** :)


(: given an organization URI - find co-mentions of person  - see above for general definition of "co-mention":)
declare function local:populateOrganizationCoMentioningPerson($query_uri_seq)
{
    let $uris_mods :=
        cwAccessibility:queryAccessControl(/)[
            MODS_DS/mods:mods/mods:subject/mods:name/@valueURI=$query_uri_seq
            or
            MODS_DS/mods:mods/mods:subject/mods:topic/@valueURI=$query_uri_seq 
            ]/(
                MODS_DS/mods:mods/mods:subject/(mods:name|mods:topic)/@valueURI[data()!=$query_uri_seq]/data()
                |
                MODS_DS/mods:mods/name/@valueURI[data()!=$query_uri_seq]/data()
                | 
                MODS_DS/mods:mods/mods:relatedItem/mods:name/@valueURI[data()!=$query_uri_seq]/data()
            )
    let $uris_entries_about :=
        cwAccessibility:queryAccessControl(/)[
            RELS-EXT_DS/rdf:RDF/rdf:Description/fedora-model:hasModel/@rdf:resource/data()="info:fedora/cwrc:documentCModel" 
            and MODS_DS/mods:mods/mods:genre/text() = ("Biography", "Born digital") 
            and MODS_DS/mods:mods/mods:subject/mods:name/@valueURI = $query_uri_seq
            ]/(
                CWRC_DS//(tei:persName/@ref/data()|NAME/@REF/data())
            )
    let $uris_entries_context :=
        cwAccessibility:queryAccessControl(/)/(
                CWRC_DS//tei:persName[
                    (ancestor::tei:event|ancestor::tei:note|ancestor::tei:p)/descendant::tei:orgName/@ref/data()=$query_uri_seq
                    ]/@ref
                |
                CWRC_DS//NAME[(ancestor::CHRONSTRUCT|ancestor::P)/descendant::ORGNAME/@REF/data()=$query_uri_seq]/@REF
                )/data()
      
      
    return
        ( distinct-values( ($uris_mods, $uris_entries_about, $uris_entries_context) ) )     
        
};

(: given an organization URI - find co-mentions of organization  - see above for general definition of "co-mention":)
declare function local:populateOrganizationCoMentioningOrganization($query_uri_seq)
{
    let $uris_mods :=
        cwAccessibility:queryAccessControl(/)[
            MODS_DS/mods:mods/mods:subject/mods:name/@valueURI=$query_uri_seq
            or
            MODS_DS/mods:mods/mods:subject/mods:topic/@valueURI=$query_uri_seq 
            ]/(
                MODS_DS/mods:mods/mods:subject/(mods:name|mods:topic)/@valueURI[data()!=$query_uri_seq]/data()
                |
                MODS_DS/mods:mods/name/@valueURI[data()!=$query_uri_seq]/data()
                | 
                MODS_DS/mods:mods/mods:relatedItem/mods:name/@valueURI[data()!=$query_uri_seq]/data()
            )
    let $uris_entries_about :=
        cwAccessibility:queryAccessControl(/)[
            RELS-EXT_DS/rdf:RDF/rdf:Description/fedora-model:hasModel/@rdf:resource/data()="info:fedora/cwrc:documentCModel" 
            and MODS_DS/mods:mods/mods:genre/text() = ("Biography", "Born digital") 
            and MODS_DS/mods:mods/mods:subject/mods:name/@valueURI = $query_uri_seq
            ]/(
                CWRC_DS//(tei:orgName/@ref/data()|ORGNAME/@REF/data())
            )
    let $uris_entries_context :=
        cwAccessibility:queryAccessControl(/)/(
                CWRC_DS//tei:orgName[
                    (ancestor::tei:event|ancestor::tei:note|ancestor::tei:p)/descendant::tei:orgName/@ref/data()=$query_uri_seq
                    ]/@ref
                |
                CWRC_DS//ORGNAME[(ancestor::CHRONSTRUCT|ancestor::P)/descendant::ORGNAME/@REF/data()=$query_uri_seq]/@REF
                )/data()
      
      
    return
        ( distinct-values( ($uris_mods, $uris_entries_about, $uris_entries_context) ) )     
        
};

(: given organization URI - find co-mentions of places  - see above for general definition of "co-mention":)
declare function local:populateOrganizationCoMentioningPlace($query_uri_seq)
{
    let $uris_mods :=
        cwAccessibility:queryAccessControl(/)[
            MODS_DS/mods:mods/mods:subject/mods:name/@valueURI=$query_uri_seq
            or
            MODS_DS/mods:mods/mods:subject/mods:topic/@valueURI=$query_uri_seq 
            ]/(
                MODS_DS/mods:mods/mods:subject/(mods:geographic|mods:topic)/@valueURI = $query_uri_seq
                | 
                MODS_DS/mods:mods/mods:originInfo/place/placeTerm/@valueURI = $query_uri_seq
                | 
                MODS_DS/mods:mods/mods:relatedItem/mods:originInfo/place/placeTerm/@valueURI = $query_uri_seq            
            )
    let $uris_entries_about :=
        cwAccessibility:queryAccessControl(/)[
            RELS-EXT_DS/rdf:RDF/rdf:Description/fedora-model:hasModel/@rdf:resource/data()="info:fedora/cwrc:documentCModel" 
            and MODS_DS/mods:mods/mods:genre/text() = ("Biography", "Born digital") 
            and MODS_DS/mods:mods/mods:subject/mods:name/@valueURI = $query_uri_seq
            ]/(
                CWRC_DS//(tei:placeName/@ref/data()|PLACE/@REF/data())
            )
    let $uris_entries_context :=
        cwAccessibility:queryAccessControl(/)/(
                CWRC_DS//tei:placeName[
                    (ancestor::tei:event|ancestor::tei:note|ancestor::tei:p)/descendant::tei:orgName/@ref/data()=$query_uri_seq
                    ]/@ref
                |
                CWRC_DS//PLACE[(ancestor::CHRONSTRUCT|ancestor::P)/descendant::ORGNAME/@REF/data()=$query_uri_seq]/@REF
                )/data()
      
      
    return
        ( distinct-values( ($uris_mods, $uris_entries_about, $uris_entries_context) ) )     
};











(: *** PLACE *** :)


(: given a place URI - find co-mentions of person  - see above for general definition of "co-mention":)
declare function local:populatePlaceCoMentioningPerson($query_uri_seq)
{
    let $uris_mods :=
        cwAccessibility:queryAccessControl(/)[
            MODS_DS/mods:mods/mods:subject/(mods:geographic|mods:topic)/@valueURI = $query_uri_seq
            or 
            MODS_DS/mods:mods/mods:originInfo/place/placeTerm/@valueURI = $query_uri_seq
            or 
            MODS_DS/mods:mods/mods:relatedItem/mods:originInfo/place/placeTerm/@valueURI = $query_uri_seq
            ]/(
                MODS_DS/mods:mods/mods:subject/(mods:name|mods:topic)/@valueURI[data()!=$query_uri_seq]/data()
                |
                MODS_DS/mods:mods/name/@valueURI[data()!=$query_uri_seq]/data()
                | 
                MODS_DS/mods:mods/mods:relatedItem/mods:name/@valueURI[data()!=$query_uri_seq]/data()
            )
    let $uris_entries_about :=
        cwAccessibility:queryAccessControl(/)[
            RELS-EXT_DS/rdf:RDF/rdf:Description/fedora-model:hasModel/@rdf:resource/data()="info:fedora/cwrc:documentCModel" 
            and MODS_DS/mods:mods/mods:genre/text() = ("Biography", "Born digital") 
            and MODS_DS/mods:mods/mods:subject/mods:geograpahic/@valueURI = $query_uri_seq
            ]/(
                CWRC_DS//(tei:persName/@ref/data()|NAME/@REF/data())
            )
    let $uris_entries_context :=
        cwAccessibility:queryAccessControl(/)/(
                CWRC_DS//tei:persName[
                    (ancestor::tei:event|ancestor::tei:note|ancestor::tei:p)/descendant::tei:placeName/@ref/data()=$query_uri_seq
                    ]/@ref
                |
                CWRC_DS//NAME[(ancestor::CHRONSTRUCT|ancestor::P)/descendant::PLACE/@REF/data()=$query_uri_seq]/@REF
                )/data()
      
      
    return
        ( distinct-values( ($uris_mods, $uris_entries_about, $uris_entries_context) ) )     
        
};

(: given a place URI - find co-mentions of organization  - see above for general definition of "co-mention":)
declare function local:populatePlaceCoMentioningOrganization($query_uri_seq)
{
    let $uris_mods :=
        cwAccessibility:queryAccessControl(/)[
            MODS_DS/mods:mods/mods:subject/(mods:geographic|mods:topic)/@valueURI = $query_uri_seq
            or 
            MODS_DS/mods:mods/mods:originInfo/place/placeTerm/@valueURI = $query_uri_seq
            or 
            MODS_DS/mods:mods/mods:relatedItem/mods:originInfo/place/placeTerm/@valueURI = $query_uri_seq 
            ]/(
                MODS_DS/mods:mods/mods:subject/(mods:name|mods:topic)/@valueURI[data()!=$query_uri_seq]/data()
                |
                MODS_DS/mods:mods/name/@valueURI[data()!=$query_uri_seq]/data()
                | 
                MODS_DS/mods:mods/mods:relatedItem/mods:name/@valueURI[data()!=$query_uri_seq]/data()
            )
    let $uris_entries_about :=
        cwAccessibility:queryAccessControl(/)[
            RELS-EXT_DS/rdf:RDF/rdf:Description/fedora-model:hasModel/@rdf:resource/data()="info:fedora/cwrc:documentCModel" 
            and MODS_DS/mods:mods/mods:genre/text() = ("Biography", "Born digital") 
            and MODS_DS/mods:mods/mods:subject/mods:geograpahic/@valueURI = $query_uri_seq
            ]/(
                CWRC_DS//(tei:orgName/@ref/data()|ORGNAME/@REF/data())
            )
    let $uris_entries_context :=
        cwAccessibility:queryAccessControl(/)/(
                CWRC_DS//tei:orgName[
                    (ancestor::tei:event|ancestor::tei:note|ancestor::tei:p)/descendant::tei:placeName/@ref/data()=$query_uri_seq
                    ]/@ref
                |
                CWRC_DS//ORGNAME[(ancestor::CHRONSTRUCT|ancestor::P)/descendant::PLACE/@REF/data()=$query_uri_seq]/@REF
                )/data()
      
      
    return
        ( distinct-values( ($uris_mods, $uris_entries_about, $uris_entries_context) ) )     
        
};

(: given organization URI - find co-mentions of places  - see above for general definition of "co-mention":)
declare function local:populatePlaceCoMentioningPlace($query_uri_seq)
{
    let $uris_mods :=
        cwAccessibility:queryAccessControl(/)[
            MODS_DS/mods:mods/mods:subject/(mods:geographic|mods:topic)/@valueURI = $query_uri_seq
            or 
            MODS_DS/mods:mods/mods:originInfo/place/placeTerm/@valueURI = $query_uri_seq
            or 
            MODS_DS/mods:mods/mods:relatedItem/mods:originInfo/place/placeTerm/@valueURI = $query_uri_seq 
            ]/(
                MODS_DS/mods:mods/mods:subject/(mods:geographic|mods:topic)/@valueURI = $query_uri_seq
                | 
                MODS_DS/mods:mods/mods:originInfo/place/placeTerm/@valueURI = $query_uri_seq
                | 
                MODS_DS/mods:mods/mods:relatedItem/mods:originInfo/place/placeTerm/@valueURI = $query_uri_seq            
            )
    let $uris_entries_about :=
        cwAccessibility:queryAccessControl(/)[
            RELS-EXT_DS/rdf:RDF/rdf:Description/fedora-model:hasModel/@rdf:resource/data()="info:fedora/cwrc:documentCModel" 
            and MODS_DS/mods:mods/mods:genre/text() = ("Biography", "Born digital") 
            and MODS_DS/mods:mods/mods:subject/mods:geograpahic/@valueURI = $query_uri_seq
            ]/(
                CWRC_DS//(tei:placeName/@ref/data()|PLACE/@REF/data())
            )
    let $uris_entries_context :=
        cwAccessibility:queryAccessControl(/)/(
                CWRC_DS//tei:placeName[
                    (ancestor::tei:event|ancestor::tei:note|ancestor::tei:p)/descendant::tei:placeName/@ref/data()=$query_uri_seq
                    ]/@ref
                |
                CWRC_DS//PLACE[(ancestor::CHRONSTRUCT|ancestor::P)/descendant::PLACE/@REF/data()=$query_uri_seq]/@REF
                )/data()
      
      
    return
        ( distinct-values( ($uris_mods, $uris_entries_about, $uris_entries_context) ) )     
};














(: *** TITLE *** :)

(: given a title URI - find co-mentions of person  - see above for general definition of "co-mention":)
declare function local:populateTitleCoMentioningPerson($query_uri_seq)
{
    let $uris_mods :=
        cwAccessibility:queryAccessControl(/)[
            @pid/data()=$query_uri_seq 
            ]/(
                MODS_DS/mods:mods/mods:subject/(mods:name|mods:topic)/@valueURI[data()!=$query_uri_seq]/data()
                |
                MODS_DS/mods:mods/name/@valueURI[data()!=$query_uri_seq]/data()
                | 
                MODS_DS/mods:mods/mods:relatedItem/mods:name/@valueURI[data()!=$query_uri_seq]/data()
            )
    let $uris_entries_about :=
        cwAccessibility:queryAccessControl(/)[
            RELS-EXT_DS/rdf:RDF/rdf:Description/fedora-model:hasModel/@rdf:resource/data()="info:fedora/cwrc:documentCModel" 
            and MODS_DS/mods:mods/mods:genre/text() = ("Biography", "Born digital") 
            and @pid/data()=$query_uri_seq
            ]/(
                CWRC_DS//(tei:persName/@ref/data()|NAME/@REF/data())
            )
    let $uris_entries_context :=
        cwAccessibility:queryAccessControl(/)/(
                CWRC_DS//tei:persName[
                    (ancestor::tei:event|ancestor::tei:note|ancestor::tei:p)/descendant::tei:title/@ref/data()=$query_uri_seq
                    ]/@ref
                |
                CWRC_DS//NAME[(ancestor::CHRONSTRUCT|ancestor::P)/descendant::TITLE/@REF/data()=$query_uri_seq]/@REF
                |
                CWRC_DS//tei:persName[
                    (ancestor::tei:event|ancestor::tei:note|ancestor::tei:p)/descendant::tei:note/bibl/@ref/data()=$query_uri_seq
                    ]/@ref
                |
                CWRC_DS//NAME[(ancestor::CHRONSTRUCT|ancestor::P)/descendant::BIBCIT/@REF/data()=$query_uri_seq]/@REF
                )/data()
      
      
    return
        ( distinct-values( ($uris_mods, $uris_entries_about, $uris_entries_context) ) )     
        
};

(: given a person URI - find co-mentions of organization  - see above for general definition of "co-mention":)
declare function local:populateTitleCoMentioningOrganization($query_uri_seq)
{
    let $uris_mods :=
        cwAccessibility:queryAccessControl(/)[
            @pid/data()=$query_uri_seq 
            ]/(
                MODS_DS/mods:mods/mods:subject/(mods:name|mods:topic)/@valueURI[data()!=$query_uri_seq]/data()
                |
                MODS_DS/mods:mods/name/@valueURI[data()!=$query_uri_seq]/data()
                | 
                MODS_DS/mods:mods/mods:relatedItem/mods:name/@valueURI[data()!=$query_uri_seq]/data()
            )
    let $uris_entries_about :=
        cwAccessibility:queryAccessControl(/)[
            RELS-EXT_DS/rdf:RDF/rdf:Description/fedora-model:hasModel/@rdf:resource/data()="info:fedora/cwrc:documentCModel" 
            and MODS_DS/mods:mods/mods:genre/text() = ("Biography", "Born digital") 
            and @pid/data()=$query_uri_seq
            ]/(
                CWRC_DS//(tei:orgName/@ref/data()|ORGNAME/@REF/data())
            )
    let $uris_entries_context :=
        cwAccessibility:queryAccessControl(/)/(
                CWRC_DS//tei:orgName[
                    (ancestor::tei:event|ancestor::tei:note|ancestor::tei:p)/descendant::tei:title/@ref/data()=$query_uri_seq
                    ]/@ref
                |
                CWRC_DS//ORGNAME[(ancestor::CHRONSTRUCT|ancestor::P)/descendant::TITLE/@REF/data()=$query_uri_seq]/@REF
                |
                CWRC_DS//tei:orgName[
                    (ancestor::tei:event|ancestor::tei:note|ancestor::tei:p)/descendant::tei:note/tei:bibl/@ref/data()=$query_uri_seq
                    ]/@ref
                |
                CWRC_DS//ORGNAME[(ancestor::CHRONSTRUCT|ancestor::P)/descendant::BIBCIT/@REF/data()=$query_uri_seq]/@REF                
                )/data()
      
      
    return
        ( distinct-values( ($uris_mods, $uris_entries_about, $uris_entries_context) ) )     
        
};

(: given a title URI - find co-mentions of places  - see above for general definition of "co-mention":)
declare function local:populateTitleCoMentioningPlace($query_uri_seq)
{
    let $uris_mods :=
        cwAccessibility:queryAccessControl(/)[
            @pid/data()=$query_uri_seq 
            ]/(
                MODS_DS/mods:mods/mods:subject/(mods:geographic|mods:topic)/@valueURI = $query_uri_seq
                | 
                MODS_DS/mods:mods/mods:originInfo/place/placeTerm/@valueURI = $query_uri_seq
                | 
                MODS_DS/mods:mods/mods:relatedItem/mods:originInfo/place/placeTerm/@valueURI = $query_uri_seq            
            )
    let $uris_entries_about :=
        cwAccessibility:queryAccessControl(/)[
            RELS-EXT_DS/rdf:RDF/rdf:Description/fedora-model:hasModel/@rdf:resource/data()="info:fedora/cwrc:documentCModel" 
            and MODS_DS/mods:mods/mods:genre/text() = ("Biography", "Born digital") 
            and @pid/data()=$query_uri_seq
            ]/(
                CWRC_DS//(tei:placeName/@ref/data()|PLACE/@REF/data())
            )
    let $uris_entries_context :=
        cwAccessibility:queryAccessControl(/)/(
                CWRC_DS//tei:placeName[
                    (ancestor::tei:event|ancestor::tei:note|ancestor::tei:p)/descendant::tei:title/@ref/data()=$query_uri_seq
                    ]/@ref
                |
                CWRC_DS//PLACE[(ancestor::CHRONSTRUCT|ancestor::P)/descendant::TITLE/@REF/data()=$query_uri_seq]/@REF
                |
                CWRC_DS//tei:placeName[
                    (ancestor::tei:event|ancestor::tei:note|ancestor::tei:p)/descendant::tei:note/tei:bibl/@ref/data()=$query_uri_seq
                    ]/@ref
                |
                CWRC_DS//PLACE[(ancestor::CHRONSTRUCT|ancestor::P)/descendant::TITLE/@REF/data()=$query_uri_seq]/@REF
                )/data()
      
      
    return
        ( distinct-values( ($uris_mods, $uris_entries_about, $uris_entries_context) ) )     
};





(: ***********  ********** :)


declare function local:populationsAssociationsPerson($query_uri_seq) as xs:string?
{
    fn:string-join(
        (
        cwJSON:outputJSONArray("coMentionPerson", local:populatePersonCoMentioningPerson($query_uri_seq)  )
        , cwJSON:outputJSONArray("coMentionOrganization", local:populatePersonCoMentioningOrganization($query_uri_seq)  )
        , cwJSON:outputJSONArray("coMentionPlace",  local:populatePersonCoMentioningPlace($query_uri_seq) )
        )
        , ','
        )
};

declare function local:populationsAssociationsOrganization($query_uri_seq) as xs:string?
{
    fn:string-join(
        (
        cwJSON:outputJSONArray("coMentionPerson", local:populateOrganizationCoMentioningPerson($query_uri_seq)  )
        , cwJSON:outputJSONArray("coMentionOrganization", local:populateOrganizationCoMentioningOrganization($query_uri_seq)  )
        , cwJSON:outputJSONArray("coMentionPlace",  local:populateOrganizationCoMentioningPlace($query_uri_seq) )
        )
        , ','
        )
};


declare function local:populationsAssociationsPlace($query_uri_seq) as xs:string?
{
    fn:string-join(
        (
        cwJSON:outputJSONArray("coMentionPerson", local:populatePlaceCoMentioningPerson($query_uri_seq)  )
        , cwJSON:outputJSONArray("coMentionOrganization", local:populatePlaceCoMentioningOrganization($query_uri_seq)  )
        , cwJSON:outputJSONArray("coMentionPlace",  local:populatePlaceCoMentioningPlace($query_uri_seq) )
        )
        , ','
        )
};

declare function local:populationsAssociationsTitle($query_uri_seq) as xs:string?
{
    fn:string-join(
        (
        cwJSON:outputJSONArray("coMentionPerson", local:populateTitleCoMentioningPerson($query_uri_seq)  )
        , cwJSON:outputJSONArray("coMentionOrganization", local:populateTitleCoMentioningOrganization($query_uri_seq)  )
        , cwJSON:outputJSONArray("coMentionPlace",  local:populateTitleCoMentioningPlace($query_uri_seq) )
        )
        , ','
        )
};



(: 
* Build the entity association components ( for a given entity URI and return a JSON result
* E.G., entires, oeuvre, multimedia, etc.)
:)
declare function local:buildEntityAssociations($query_uri_seq, $entityCModel) as xs:string?
{
  ',&#10;'
  || "material: {"
  ||
    (
        switch ( $entityCModel )
            case "info:fedora/cwrc:person-entityCModel" 
                return local:populateAssociationsPerson($query_uri_seq)
            case "info:fedora/cwrc:organization-entityCModel"
                return local:populateProfileOrganization($query_uri_seq)
            case "info:fedora/cwrc:organization-entityCModel"
                return local:populateProfilePlace($query_uri_seq)
            case "info:fedora/cwrc:organization-entityCModel"
                return local:populateProfileTitle($query_uri_seq)                
            default 
                return ''
    )
  || "}"
             
};



(: 
* Main functions  
:)

let $uri_source := local:getEntitySource($query_uri)
    
(: given a URI, find the PID to use for the profile detials :)
(: zap trailing '/' in the uri :)
let $query_pid := 
    switch ($uri_source)
        case $ENTITY_SOURCE_CWRC
            return 
                ( tokenize(replace($query_uri,'/$',''),'/')[last()] )
        default
            return
                (
                (/obj[(PERSON_DS|ORG_DS)/(person|organization)/identity/sameAs/text()="$query_uri"])[1]/@pid/data() 
                ) 
        
let $entityObj := cwAccessibility:queryAccessControl(/)[@pid=$query_pid]
let $entityCModel := $obj/RELS-EXT_DS/rdf:RDF/fedora-model:hasModel/@rdf:resource/data()
  


(
  '{&#10;'
  ,
  cwJSON:outputJSON("query_URI", $ENTITY_URI) 
  ,
  local:buildEntityProfile($entityObj,$entityCModel)
  ,
  
  local:buildEntityMaterial($ENTITY_URI, $entityCModel)
  ,
  local:buildEntityAssociations($ENTITY_URI, $entityCModel)
  ,
'}'
)
