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
  module_load_include('inc', 'islandora_cwrc_basexdb', 'includes/helpers');

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
  //$session->execute("SET AUTOOPTIMIZE true;"); //ToDo check if required - speed
  $session->execute("SET UPDINDEX true;");// ToDo: check if required - spped

  $session->execute("SET TEXTINDEX true;");
  $session->execute("SET ATTRINDEX true;");
  $session->execute("SET FTINDEX true;");

  // stemming
  $session->execute("SET STEMMING true;");

  return $session;
}

/**
 * @param string @name
 *  Drupal variable indicating a password which is stored encrypted/obfuscated
 *
 *
 **/
/*
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
 */

/**
 * given a Fedora object PID, read the object, extract content and 
 * and datastreams with XML mime/type and add create and entry
 * in an XML database
 *
 * https://github.com/Islandora/islandora/wiki/Working-With-Fedora-Objects-Programmatically-Via-Tuque
 *
 * @param string $pid
 *  PID of the Fedora object 
 *
 * @param string $fedoraConnection 
 *  connection object to Fedora repository 
 **/
/*
function islandora_cwrc_basexdb_add_content($pid, $basexSession)
{
  $obj = islandora_object_load($pid);
  if (!$obj)
  {
    $date = new DateTime('now');
    $date->setTimezone(new DateTimeZone('UTC'));
    $str_server_now = $date->format('Y-m-d\TH:i:s\Z');

    return 'Error: failed to load - ['.$pid. '] ' . $str_server_now ;
  }

  // enable user error handling
  libxml_use_internal_errors(true);

  $dom = new DomDocument("1.0", "UTF-8");
  // create the relative root node for this object
  // and its attribute values
  $rootNode = $dom->createElement("obj");
  $tmpAttr = $dom->createAttribute("pid");
  $tmpAttr->value = $obj->id;
  $rootNode->appendChild($tmpAttr);
  $tmpAttr = $dom->createAttribute("label");
  $tmpAttr->value = $obj->label;
  $rootNode->appendChild($tmpAttr);
  $tmpAttr = $dom->createAttribute("lastModifiedDate");
  $tmpAttr->value = $obj->lastModifiedDate;
  $rootNode->appendChild($tmpAttr);
  $tmpAttr = $dom->createAttribute("createdDate");
  $tmpAttr->value = $obj->createdDate;
  $rootNode->appendChild($tmpAttr);

  // add content from datastreams 
  $tmpDom = null;
  foreach ($obj as $datastream) {
    if ($datastream->id !== 'POLICY')
    {
      if  ($datastream->mimetype==='text/xml' or $datastream->mimetype==='application/xml' or $datastream->id==='RELS-EXT' )
      {  
        // create DOM from datastream content
        $tmpDom = new DomDocument("1.0", "UTF-8");
        $tmpDom->loadXML($datastream->content);

        // import content from datastream and  add to root node
        $tmpNode = $dom->createElement($datastream->id);
        $importNode = $dom->importNode($tmpDom->documentElement, TRUE);
        $tmpNode->appendChild($importNode);
        $rootNode->appendChild($tmpNode);
      }
    }
  }
  
  $dom->appendChild($rootNode);

  // add to the XML database (or replace if exists)
  $basexSession->replace("/cwrc/obj[@pid='$obj->id']", $dom->saveXML());
  //print($dom->saveXML());


  $ret = null;
  foreach (libxml_get_errors() as $error) {
    // handle errors here
    $ret += $error;

  }

  libxml_clear_errors();

  return ($ret);

 */
  // http://php.net/manual/en/book.simplexml.php
  // add encoding so as to prevent UTF-8 character conversion into 
  // numerical entities
  // http://php.net/manual/en/simplexmlelement.addchild.php#114971
  /*
  $xmlObj = new SimpleXMLElement('<?xml version="1.0" encoding="UTF-8"?><obj/>');
  $xmlObj->addAttribute('label',$obj->label);
  $xmlObj->addAttribute('lastModifiedDate',$obj->lastModifiedDate);
  $xmlObj->addAttribute('createdDate',$obj->createdDate);

  foreach ($obj as $datastream) {
    if ($datastream->id !== 'POLICY')
    {
      if  ($datastream->mimetype==='text/xml' or $datastream->mimetype==='application/xml' )
      {  
        //$xmlObj->addChild($datastream->content);
        //$xmlObj->addChild($datastream->id, $datastream->content);
        //print($datastream->content);
      }
    }
  }

  //print ($xmlObj->asXML());
  */


/*

}

 */
