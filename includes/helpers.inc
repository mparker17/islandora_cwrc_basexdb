<?php


/**
* @file
* helper functions for interacting with BaseX.org XML Database
*
* http://docs.basex.org/wiki/Clients
* https://github.com/BaseXdb/basex/tree/master/basex-api/src/main/php
* http://docs.basex.org/wiki/Query_Mode
* http://docs.basex.org/wiki/Standard_Mode
* http://docs.basex.org/wiki/Commands
* http://docs.basex.org/wiki/Options
**/


define('ISLANDORA_CWRC_BASEXDB_LIB', 'basex-api');



/**
 * @param string @name
 *  Drupal variable indicating a password which is stored encrypted/obfuscated
 *
 *
 **/
function islandora_cwrc_basexdb_get_password($name)
{
  $encrypted = &drupal_static(__FUNCTION__);
  if (NULL == $encrypted) {
    $encrypted = module_exists('encrypt');
  }

  $var = variable_get($name);
  $unserialized = @unserialize($var);
  if ($unserialized === FALSE || !isset($unserialized['method']) || !isset($unserialized['key_provider'])) {
    return $var;
  }

  return decrypt($var);
}


