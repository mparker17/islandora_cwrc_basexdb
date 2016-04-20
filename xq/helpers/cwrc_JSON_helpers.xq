(: purpose: various JSON output helper functions shared with other XQueries :)

xquery version "3.0" encoding "utf-8";

module namespace cwJSON = "cwJSONHelpers";

(: **** helper functions :)

(: escape double quotes (") within a JSON value :)
declare function cwJSON:escapeJSON ($str as xs:string?)
{
  (: XQuery 3.1 doesn't support look-behinds so need extra replace for case where " is the first character :)
  (: missed the "" case of an empty attribute :)
  (: fn:replace( fn:replace($str, '^["]', '\\"') , '([^\\])["]', '$1\\"') :)
  (: if " starts a string, or two consecutive, or one alone. :)
  fn:replace( fn:replace( fn:replace($str, '^["]', '\\"'), '["]{2,2}', '\\"\\"') , '([^\\])["]', '$1\\"')
};


(: if value is empty then do not output JSON key/value :)
declare function cwJSON:outputJSONNotNull ($key as xs:string?, $value as xs:string?)
as xs:string?
{
  (
  if ($value != "") then
    cwJSON:outputJSON ($key, $value)
  else
    ()
  )
};

declare function cwJSON:outputJSON ($key as xs:string?, $value as xs:string?)
as xs:string?
{
  let $tmp := string('"'||$key||'": "'||cwJSON:escapeJSON($value)||'"')
  return $tmp
};

declare function cwJSON:outputJSONArrayGivenString ($key as xs:string?, $value as xs:string?)
as xs:string?
{
  let $tmp := string('"'||$key||'": ['||$value||']')
  return $tmp
};

declare function cwJSON:outputJSONArray ($key as xs:string?, $sequence as xs:string*)
as xs:string?
{
  let $tmp_value :=
      if ( not(fn:empty($sequence)) ) then 
          '"' || fn:string-join($sequence,'","') || '"'
      else
          ''
  let $tmp := string('"'||$key||'": ['||$tmp_value||']')
  return $tmp
};
