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
*
* @return session
*   A BaseX session object
**/

function islandora_cwrc_basexdb_init()
{
  //include(libraries_get_path(ISLANDORA_CWRC_BASEXDB_LIB) . '/BaseXclient.php');

  $session = new BaseXSession(
    variable_get('islandora_cwrc_basexdb_server_url')
    , variable_get('islandora_cwrc_basexdb_server_port')
    , variable_get('islandora_cwrc_basexdb_username')
    , islandora_cwrc_basexdb_get_password('islandora_cwrc_basexdb_password')
  );

  // prevent failure with Orlando named character references
  $session->execute("SET INTPARSE true;");

  // flag should be turned off if a document contains mixed content
  $session->execute("SET CHOP false;");

  // indexing
  $session->execute("SET AUTOOPTIMIZE true;"); //ToDo check if required - speed
  $session->execute("SET UPDINDEX true;");// ToDo: check if required - spped

  $session->execute("SET TEXTINDEX true;");
  $session->execute("SET ATTRINDEX true;");
  $session->execute("SET FTINDEX true;");

  // stemming
  $session->execute("SET STEMMING true;");

  return $session;
}

function islandora_cwrc_basexdb_get_password($name)
{
  $encrypted = &drupal_static(__FUNCTION__);
  if (NULL == $encrypted) {
    $encrypted = module_exists('encrypt');
  }

  $var = variable_get($name);
  $unserialized = @unserialize($var);
  if ($unserialized === FALSE || !isset($unserialized['method']) || !isset($unserialized['key_provider'])) {
    return 'xxxxx' . $var;
  }

  return decrypt($var);
}


