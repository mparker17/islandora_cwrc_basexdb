(: 
* run Xquery through the Islandora/Fedora XACML access control stored with
* Fedora Object
*
* eg.
* declare namespace rdf =  "http://www.w3.org/1999/02/22-rdf-syntax-ns#";declare namespace islandora =  "http://islandora.ca/ontology/relsext#";/obj[RELS-EXT/rdf:RDF/rdf:Description[(not(islandora:isViewableByUser) and not(islandora:isViewableByRole)) or islandora:isViewableByUser/text()='adminU' or islandora:isViewableByRole/text() = ('asdf','administrator')]]/name()
*
:)


xquery version "3.0" encoding "utf-8";

module namespace cwAccess = "cwAccessibility";

declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace tei =  "http://www.tei-c.org/ns/1.0";
declare namespace dc =  "http://purl.org/dc/elements/1.1/";
declare namespace rdf =  "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace fedora =  "info:fedora/fedora-system:def/relations-external#";
declare namespace fedora-model =  "info:fedora/fedora-system:def/model#";
declare namespace islandora =  "http://islandora.ca/ontology/relsext#";

declare variable $cwAccess:user_external external := "anonymous";
declare variable $cwAccess:role_external external := ( "anonymous" );


(:
*
* * return only those object that are accessbible based on the username or role
* *
:)
declare function cwAccess:queryAccessControl($context, $user_external, $role_external)
{
let $accessible_sequence := ( $context/obj[RELS-EXT/rdf:RDF/rdf:Description[(not(islandora:isViewableByUser) and not(islandora:isViewableByRole)) or islandora:isViewableByUser/text()=$cwAccess:user_external or islandora:isViewableByRole/text() = $cwAccess:role_external ]] )

return
  $accessible_sequence
};


