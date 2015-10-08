(: a set of helper functions to manipulate Orlando XML :)

xquery version "3.0" encoding "utf-8";

module namespace cwOH = "cwOrlandoHelpers";

declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace tei =  "http://www.tei-c.org/ns/1.0";


(: map to help converting dates to ISO8601 (YYYY-MM-DD) dates that use month numbers :)
declare variable $cwOH:monthMap as map(*) := 
  map {
    "January": "01" 
    , "February": "02" 
    , "March": "03" 
    , "April": "04" 
    , "May": "05" 
    , "June": "06" 
    , "July": "07" 
    , "August": "08" 
    , "September": "09" 
    , "October": "10" 
    , "November": "11" 
    , "December": "12" 
    , "janvier": "01" 
    , "février": "02" 
    , "mars": "03" 
    , "avril": "04" 
    , "mai": "05" 
    , "juin": "06" 
    , "juillet": "07" 
    , "août": "08" 
    , "september": "09" 
    , "octobre": "10" 
    , "novembre": "11" 
    , "décembre": "12" 
  };

(: 
* Given an Orlando normalized narrative date
* in the form of day month year - e.g. 6 June 1994
* convert to ISO8601 (YYYY-MM-DD) date
 :)
declare function cwOH:parse-orlando-narrative-date($dateStr)
{
    try
    {
      for $str at $i in fn:reverse(fn:tokenize($dateStr, " "))
      return
      (
        if ( fn:matches($str, "\d\d\d\d") and $i eq 1 ) then
          $str
        else if ( $cwOH:monthMap($str) and $i eq 2 ) then
          $cwOH:monthMap($str)
        else if ( fn:matches($str, "\d{1,2}") and $i eq 3 ) then
          fn:format-number(xs:double($str),"#00")
        else
          ()
      )
    }
    catch * {
      ()
    }
};


(: 
* Given an Orlando citation sequence
* build a seqence of displayable results
* ToDo: 2015-05-04 - improve - entire XML citation and client renders XML/html
 :)
declare function cwOH:build_citation_sequence($src)
{

  for $str at $i in $src 
    return 
    try
    {
      (
        "<div>" 
        ||
        (
        if ( $str/@DBREF and $str/@PLACEHOLDER ) then
          ( "<a target='_blank' href='http://orlando.cambridge.org/protected/wheel?f=frame&amp;bi_id="||$str/@DBREF||"'>"||$str/@PLACEHOLDER||"</a>" )
        else if ( $src/@PLACEHOLDER ) then
          ( $src/@PLACEHOLDER )
        else
          ( $src/text() )
        )
        ||
        "</div>"  
      )
    }
    catch * {
      '<div>ERROR</div>'
    }
  
};

(: 
* Given an Orlando schema
* build a seqence of displayable results representing a contributor
 :)
declare function cwOH:build_contributors_sequence($src)
{
    try
    {
      for $node at $i in $src 
      let $tmp := fn:normalize-space(fn:string-join($node))
      return
      (
        if ( $tmp ) then
          "<div>" 
          ||
          ( $tmp )
          ||
          "</div>"  
        else
          ( )
      )
    }
    catch * {
      ()
    }
};

