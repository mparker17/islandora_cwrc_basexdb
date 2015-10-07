<?php

/**
  * @file
  * Menu Callbacks.
  */

/**
*  Menu callback to building response 
*/
function islandora_cwrc_basexdb_test_endpoint ($xquery, $value = NULL) {
  module_load_include('inc', 'islandora_rest', 'includes/utilities');

  $request_method = islandora_rest_get_request_method();

  try {
    switch ($request_method) {
      case 'GET':
        $response = islandora_cwrc_exec_xquery($xquery, drupal_get_query_parameters($_GET)  );
        break;
      case 'POST':
        $response = islandora_cwrc_exec_xquery($xquery, drupal_get_query_parameters($_POST)  );
        break;
      default:
        throw new Exception('Not Implemented', 500);
    }
  }
  catch (Exception $e) {
    drupal_add_http_header('Status', $e->getCode());
    // CWRC-Writer currently ignores the response aside from the status code,
    // when an error occurs.
    $response = array('message' => $e->getMessage());
  }
  $encode = is_array($response) || is_object($response);
  if ($encode) {
    // Responses that don't generate objects or arrays, must set their own
    // content types. Not calling drupal_json_output because we are setting
    // encoding.
    drupal_add_http_header('Content-Type', 'application/json; utf-8');
    drupal_json_output($response);
  }
  else {
    echo $response;
  }
  drupal_exit();
}

/**
* send XQuery to the XML database and return response
*
* @param xquery
*   name of the file storing the XQuery
* @param valArray
*   array of key/values from request signifying other parameters 
*   that should be passed into the XQuery
* @return
*   the response for the XQuery - text/XML
*/ 
function islandora_cwrc_exec_xquery($xquery, $valArray )
{

  // Include modules.
  module_load_include('inc', 'islandora_cwrc_basexdb', 'includes/basexdb');
  include_once(libraries_get_path(ISLANDORA_CWRC_BASEXDB_LIB) . '/BaseXClient.php');

  // user information to pass to the XQuery for the access control restrictions
  global $user;
  $user_roles = "('".implode("','", $user->roles)."')";


  // connection to the BaseXDB
  $basexSession = null;
  $basexSession = islandora_cwrc_basexdb_init();

  // open XML Database
  $basexSession->execute("OPEN " . variable_get('islandora_cwrc_basexdb_database_main'));


  // base URL from XQuery includd modules
  Global $base_url;
  $base_xquery = $base_url . '/'. drupal_get_path('module','islandora_cwrc_basexdb') .  '/xq/';
  $basexSession->execute('SET QUERYPATH ' . $base_xquery );

  // whitelist query path
  $xquery =  islandora_cwrc_basexdb_whitelist_path($xquery);

  // map to hold access control elements and other report specifiy variables
  $tmp = "";
  // ToDo: need to excape single quotes
  //$tmp = $tmp . ", 'QRY_TERMS' : '{&#34;Pauline&#34;}'";
  foreach ( $valArray as $key=>$value)
  {
    $value = islandora_cwrc_basexdb_whitelist_xquery($value);
    $tmp = $tmp . ", '" . $key .  "' : '" . $value . "'";
  }
  $tmp = $tmp . ", 'BASE_URL' : '".$base_url."/islandora/object'";
  $xquery_bindings = "map { '{cwAccessibility}user_external' : '$user->name', '{cwAccessibility}role_external' : $user_roles $tmp }";

  //watchdog("xmldb",$xquery_bindings);

  // 2015-06-26
  // ToDo: using this syntax as the BaseX server is running on another
  // server and the 'RUN' command doesn't understand URIs
  $xqueryStr = 'xquery:eval(fetch:text("'.$base_xquery.$xquery.'"), '.$xquery_bindings.')';

  //$ret = $xqueryStr;
  $basexQuery = $basexSession->query($xqueryStr);
  $ret = $basexQuery->execute();


  $basexSession->close();

  return $ret;
}

/**
* Given input parameters, verify the parameter doesn't allow xQuery injection
*
* @param str
*
* @return string
*   null if error or empty if doesn't meet whitelist parameters
**/
function islandora_cwrc_basexdb_whitelist_xquery($str) {
  //return preg_replace("/[^\w:\-]/", "", $str);;
  return $str;
}

/**
* Given input parameters, verify the parameter doesn't 
*
* @param str
*
* @return string
*   null if error or empty if doesn't meet whitelist parameters
**/
function islandora_cwrc_basexdb_whitelist_path($str)
{
  //return preg_replace("/^[./]+/", "", $str);;
  return basename($str);
}

/**
* Access callback fo the XML db end-point
*
* @return bool
*  TRUE if the users can make XML db queries, FALSE otherwise
*/
//function islandora_rest_solr_access() {
  //return module_exists('islandora_cwrc_basexdb') && user_access(ISLANDORA_CWRC_BASEXDB_AC_QUERY);
//}
 
