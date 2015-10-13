(: a set of helper functions work with "place" elements including geospatial lookups :)

xquery version "3.0" encoding "utf-8";

module namespace cwPH = "cwPlaceHelpers";

declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace tei =  "http://www.tei-c.org/ns/1.0";

declare variable $cwPH:XMLDB_CACHE_NAME external := "";

declare variable $cwPH:geonames_str := "geonames";
declare variable $cwPH:google_str := "google";
declare variable $cwPH:cwrc_str := "cwrc";

declare variable $cwPH:enable_string_lookup := fn:false();
declare variable $cwPH:enable_external_ref_lookup as xs:boolean := fn:false();

(:
: give either a latitude/longitude pair, a uri reference, or a string to lookup
: then return a map
: with the lat/long, uri, string, and some geo code info from the service
:)

declare function cwPH:get_geo_code($lat, $lng, $ref, $placeStr)
{
  let $ret := map {}
  return 
    (: 2015-03-30: lat/lng removed to allow capture of the countryName when "ref" is dereferenced :)
    (:
    if ( $lat and $lng ) then
      map { 'lat': $lat, 'lng': $lng, 'ref': $ref, 'placeStr': $placeStr}
    else 
    :) 
    if ( $ref ) then
      (: lookup reference and get lat/long geo location details :)
      cwPH:get_geo_code_by_ref($ref, $placeStr)
    else if ( $placeStr and $placeStr != '' and $cwPH:enable_string_lookup) then
      (: lookup string and get lat/long geo location details :)
      cwPH:get_geo_code_by_str($placeStr)
    else
      ()
};

declare function cwPH:placeRefType($ref)
{
  if ( fn:matches($ref, $cwPH:geonames_str) ) then
    $cwPH:geonames_str
  else if ( fn:matches($ref, $cwPH:cwrc_str) ) then
    $cwPH:cwrc_str
  else if ( fn:matches($ref, $cwPH:google_str) ) then
    $cwPH:google_str
  else
    ()
};

(: given a uri reference, lookup the geo code :)
declare function cwPH:get_geo_code_by_ref($ref, $placeStr)
{
  if ( fn:collection()/places/geonames/geoname[@geonameId/data() eq $ref][1] ) then
    cwPH:parse_geo_code_geonames($placeStr,fn:collection()/places/geonames/geoname[@geonameId/data() eq $ref][1])
  else if ( fn:collection()/places/cwrc_place_entities/entity[@uri/data() eq $ref][1] ) then
    cwPH:parse_geo_code_cwrc($placeStr,fn:collection()/places/cwrc_place_entities/entity[@uri/data() eq $ref][1]/place)
  else if ( fn:collection()/places/google_geocode/entity[@uri/data() eq $ref][1] ) then
    cwPH:parse_geo_code_google($placeStr,fn:collection()/places/google_geocode/entity[@uri/data() eq $ref][1])
  else if ($ref != '' and $cwPH:enable_external_ref_lookup) then
  (
          switch ( cwPH:placeRefType($ref) )
          case $cwPH:geonames_str 
             return 
             (
               let $tmp := cwPH:getGeoCodeByIDViaGeoNames($ref)
               return
                 cwPH:parse_geo_code_geonames($placeStr,$tmp/geoname[1])
             )
          case $cwPH:cwrc_str 
             return 
             (
               let $tmp := cwPH:getGeoCodeByIDViaCWRC($ref)
               return
                 cwPH:parse_geo_code_cwrc($placeStr,$tmp/entity/place[1])
             )
          case $cwPH:google_str 
             return 
             (
               let $tmp := cwPH:getGeoCodeByIDViaGoogle($ref)
               return
                 cwPH:parse_geo_code_google($placeStr,$tmp/GeocodeResponse/result[1])
             )
          default return ()
  
  
  )
  else
    map {
         'placeStr': 'ERROR 01'
    }

};

(:given only a string, lookup the geo code :)
declare function cwPH:get_geo_code_by_str($placeStr)
{
  if ($placeStr != '') then
    let $tmp := cwPH:getGeoCodeByStrViaGeoNames($placeStr)
    return
      cwPH:parse_geo_code_geonames($placeStr,$tmp/geonames/geoname[1])
  else
    ()
};


(: given the result of a GeoNames lookup, parse and place into a map :)
declare function cwPH:parse_geo_code_geonames($placeStr, $geoCodeResult)
{
   let $ret := 
     try {
          map { 
            'lat': $geoCodeResult/lat/text()
            , 'lng': $geoCodeResult/lng/text()
            , 'ref': ''
            , 'placeStr': $placeStr
            , 'geonameId': $geoCodeResult/geonameId/text()
            , 'countryName': $geoCodeResult/countryName/text()
            , 'placeName': $geoCodeResult/name/text()
          }
     } catch * {
       map {
         'placeStr': $placeStr
          , 'lat': '-90'
          , 'lng': '-90'
       }
   }
   return
     $ret
};
   
   
(: given the result of a CWRC Place entity, parse and place into a map :)
declare function cwPH:parse_geo_code_cwrc($placeStr, $geoCodeResult)
{
   let $ret := 
     try {
          map { 
            'lat': $geoCodeResult/description/latitude/text()
            , 'lng': $geoCodeResult/description/longitude/text()
            , 'ref': ''
            , 'placeStr': $placeStr
            , 'geonameId': ''
            , 'countryName': $geoCodeResult/description/countryName/text()
            , 'placeName': fn:string-join($geoCodeResult/identity/preferredform/namePart/text()) 
          }
     } catch * {
       map {
         'placeStr': $placeStr
       }
   }
   return
     $ret
};
      
  
(: given the result of a Google GeoCode Place entity, parse and place into a map :)
declare function cwPH:parse_geo_code_google($placeStr, $geoCodeResult)
{
   let $ret := 
     try {
          map { 
            'lat': $geoCodeResult/geometry/location/lat/text()
            , 'lng': $geoCodeResult/geometry/location/lng/text()
            , 'ref': ''
            , 'placeStr': $placeStr
            , 'geonameId': ''
            , 'countryName': $geoCodeResult/address_component[type/text()='country']/long_name/text()
            , 'admin_1': $geoCodeResult/address_component[type/text()='administrative_area_level_1']/long_name/text()
            , 'placeName':  $geoCodeResult/address_component[type/text()='locality']/long_name/text()
          }
     } catch * {
       map {
         'placeStr': $placeStr
       }
   }
   return
     $ret
};   
   

(: do the geo code lookup given a query string :)   
(: href="http://api.geonames.org/search?q=fn:encode-for-uri($country||', '||$placename)"> :)
(: href="http://www.google.com" :)
(: href="http://api.geonames.org/search?q=England,%20London&amp;username=brundin&amp;maxRows=1" :)
declare function cwPH:getGeoCodeByStrViaGeoNames ($qryStr as xs:string?)
{
  let $qryEncoded := fn:encode-for-uri(string($qryStr))
  let $tmp := http:send-request(
    <http:request 
      method='get'
      href="http://api.geonames.org/search?q={$qryEncoded}&amp;username=brundin&amp;maxRows=1"
      >
    </http:request>
  )[2]
  return 
    $tmp
};
  
(: do the geo code lookup given a GeoNames ID :)   
(: href="http://api.geonames.org/search?q=fn:encode-for-uri($country||', '||$placename)"> :)
(: href="http://www.google.com" :)
(: href="http://api.geonames.org/search?q=England,%20London&amp;username=brundin&amp;maxRows=1" :)
declare function cwPH:getGeoCodeByIDViaGeoNames ($ref as xs:string?)
{
  let $geonameId := fn:replace($ref, 'http://www.geonames.org/(\d*)[/]?','$1')
  let $tmp := http:send-request(
    <http:request 
      method='get'
      href="http://ws.geonames.org/get?geonameId={$geonameId}&amp;username=brundin"
      >
    </http:request>
  )[2]
  return 
    $tmp
};


  
(: do the geo code lookup given a CWRC Entity URI :)   
(: http://commons.cwrc.ca/{PID} :)
(: http://commons.cwrc.ca/{PID}/datastream/PLACE :)
(: :)
declare function cwPH:getGeoCodeByIDViaCWRC ($ref as xs:string?)
{
  let $geonameId := fn:replace($ref, 'http[s]?://commons.cwrc.ca/(\d*)[/]?','$1')
  let $tmp := http:send-request(
    <http:request 
      method='get'
      href="http://commons.cwrc.ca/{$geonameId}/datastream/PLACE"
      >
    </http:request>
  )[2]
  return 
    $tmp
};  

  
(: do the geo code lookup given a Google GeoCode ID :)   
(: https://www.google.ca/maps/place/Neepawa,%20MB%20R0J,%20Canada :)
(: http://maps.googleapis.com/maps/api/geocode/xml?address=Neepawa,%20MB%20R0J,%20Canada :)
(: :)
declare function cwPH:getGeoCodeByIDViaGoogle ($ref as xs:string?)
{
  let $geonameId := fn:replace($ref, 'http[s]?://www.google.ca/maps/place/([^/]*)[/]?','$1')

  let $tmp := http:send-request(
    <http:request 
      method='get'
      href="http://maps.googleapis.com/maps/api/geocode/xml?address={$geonameId}"
      >
    </http:request>
  )[2]/GeocodeResponse/result/*

  return 
    $tmp
};  
  
    
(: Orlando schema: build place string form GEOG, REGION, SETTLEMENT, PLACENAME:)
declare function cwPH:getOrlandoPlaceString($place)
{
   let $place_country := 
     if ($place/GEOG/@CURRENT) then
       $place/GEOG/@CURRENT/data()
     else if ($place/GEOG/@REG) then
       $place/GEOG/@REG/data()
     else  
       $place/GEOG/text()
       
   let $place_settlement := 
     if ($place/SETTLEMENT/@CURRENT) then
       $place/SETTLEMENT/@CURRENT/data()
     else if ($place/SETTLEMENT/@REG) then
       $place/SETTLEMENT/@REG/data()
     else if ($place/SETTLEMENT/text()) then
       $place/SETTLEMENT/text()
     else 
       ()
         
   let $place_placename :=
     if ($place/PLACENAME/@CURRENT) then
       $place/PLACENAME/@CURRENT/data()
     else if ($place/PLACENAME/@REG) then
       $place/PLACENAME/@REG/data()
     else if ($place/PLACENAME) then
       $place/PLACENAME/text()
     else
       ()
       
   let $place_region :=
     if ($place/REGION/@CURRENT) then
       $place/REGION/@CURRENT/data()
     else if ($place/REGION/@REG) then
       $place/REGION/@REG/data()
     else if ($place/REGION/text()) then
       $place/REGION/text()
     else 
       ()
       
   let $concatPlace :=  fn:string-join(($place_placename, $place_settlement, $place_region, $place_country), ', ')    
   
   return   
     $concatPlace
};

    
      
(: proof-of-concept :)
declare %updating function cwPH:addPlaceRefToCache($ref)
{
  let $tmp := cwPH:getGeoCodeByIDViaGeoNames($ref) 
  return 
    insert node $ref into /
};
