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


class xmldb_basex {

  function __construct($config, $db_name=null, $log=null)
  {
    $this->config = $config;
    $this->log = $log;
    $this->db_name = $db_name;
    $this->basexSession = $this->basexdb_init();
    $this->open();
  }

  function __destruct() {
    if ( isset($this->basexSession) )
    {
      $this->basexSession->close();
    }
  }

  function open() {
    if (isset($this->db_name) and isset($this->basexSession))
    {
      // open XML Database 
      $this->basexSession->execute("OPEN " . $this->db_name);      
    }
  }

  function close() {
    $this->basexSession->close();
    unset($this->basexSession);
  }

  /**
  *
  * @return session
  *   A BaseX session object
  **/

  function basexdb_init()
  {
    //include(libraries_get_path(ISLANDORA_CWRC_BASEXDB_LIB) . '/BaseXclient.php');

    $this->basexSession = new BaseXSession(
      (string)$this->config->basexdb_server_url
      , (string)$this->config->basexdb_server_port
      , (string)$this->config->basexdb_username
      , (string)$this->config->basexdb_password
    );

    // prevent failure with Orlando named character references
    $this->basexSession->execute("SET INTPARSE true;");

    // flag should be turned off if a document contains mixed content
    $this->basexSession->execute("SET CHOP false;");

    // indexing
    //$this->basexSession->execute("SET AUTOOPTIMIZE true;"); //ToDo check if required - speed
    $this->basexSession->execute("SET UPDINDEX true;");// ToDo: check if required - spped

    $this->basexSession->execute("SET TEXTINDEX true;");
    $this->basexSession->execute("SET ATTRINDEX true;");
    $this->basexSession->execute("SET FTINDEX true;");

    // stemming
    $this->basexSession->execute("SET STEMMING true;");

    return $this->basexSession;
  }


  /**
  * given a Fedora object , read the object, extract content and 
  * and datastreams with XML mime/type and add create and entry
  * in an XML database
  *
  * https://github.com/Islandora/islandora/wiki/Working-With-Fedora-Objects-Programmatically-Via-Tuque
  *
  * @param string $fedora_object
  *  the Fedora object as a Tuque object
  *
  **/
  function basexdb_add_content($fedora_object, $msgDateTime=null)
  {
    //$obj = islandora_object_load($pid);

    if (!$fedora_object)
    {
      $date = new DateTime('now');
      $date->setTimezone(new DateTimeZone('UTC'));
      $str_server_now = $date->format('Y-m-d\TH:i:s\Z');

      return 'Error: failed to load obj - ['.'] ' . $str_server_now ;
    }

    // if the Feodra object has a start of 'deleted' or 'inactive'
    // the delete the object from the XML database
    if ($fedora_object->state !== 'A')
    {
      $this->basexdb_do_delete($fedora_object->id);
      return "Info: Object state: $fedora_object->state";
    }
    else
    {
      // Otherwise add the content to the XML database
      $basex_time_str = $this->basexdb_last_modified_time($fedora_object->id);
      $fedora_time_str = $fedora_object->lastModifiedDate;
      $message_time = (isset($msgDateTime)) ? strtotime($msgDateTime) : null;
      $basex_time = (isset($basex_time_str)) ? strtotime($basex_time_str) : null;
      $fedora_time = (isset($fedora_time_str)) ? strtotime($fedora_time_str) : null;
      print($basex_time_str . " - " . $fedora_time_str);
      if ( 
        (!isset($basex_time) && isset($fedora_object)) // new fedora obj 
        or 
        (isset($basex_time) && isset($fedora_time) && $basex_time<$fedora_time)
        // 2015-07-06 - attempt to use the message time to limit number of 
        // updates if ActiveMQ messages are handles out-of-order given threading
        //or 
        //(isset($basex_time) && isset($fedora_time) && isset($message_time) && $basex_time<$message_time))
      )
      {
        return $this->basexdb_do_replace($fedora_object);
      }
    }
  }


  /**
  * given a Fedora object , read the object, extract content and 
  * and datastreams with XML mime/type and add create and entry
  * in an XML database
  *
  * https://github.com/Islandora/islandora/wiki/Working-With-Fedora-Objects-Programmatically-Via-Tuque
  *
  * @param string $fedora_object
  *  the Fedora object as a Tuque object
  *
  **/
  protected function basexdb_do_replace($fedora_object)
  {
    // enable user error handling
    libxml_use_internal_errors(true);

    $dom = new DomDocument("1.0", "UTF-8");
    // create the relative root node for this object
    // and its attribute values
    $rootNode = $dom->createElement("obj");
    $tmpAttr = $dom->createAttribute("pid");
    $tmpAttr->value = $fedora_object->id;
    $rootNode->appendChild($tmpAttr);
    $tmpAttr = $dom->createAttribute("label");
    $tmpAttr->value = $fedora_object->label;
    $rootNode->appendChild($tmpAttr);
    $tmpAttr = $dom->createAttribute("lastModifiedDate");
    $tmpAttr->value = $fedora_object->lastModifiedDate;
    $rootNode->appendChild($tmpAttr);
    $tmpAttr = $dom->createAttribute("createdDate");
    $tmpAttr->value = $fedora_object->createdDate;
    $rootNode->appendChild($tmpAttr);

    // add content from datastreams 
    $tmpDom = null;
    foreach ($fedora_object as $datastream) {
      if ($datastream->id !== 'POLICY')
      {
        if  ($datastream->mimetype==='text/xml' or $datastream->mimetype==='application/xml' or $datastream->id==='RELS-EXT' )
        {  
          // create DOM from datastream content
          $tmpDom = new DomDocument("1.0", "UTF-8");
          $tmpDom->loadXML($datastream->content);

          // import content from datastream and  add to root node
          $tmpNode = $dom->createElement($datastream->id."_DS");
          $importNode = $dom->importNode($tmpDom->documentElement, TRUE);
          $tmpNode->appendChild($importNode);
          $rootNode->appendChild($tmpNode);
        }
      }
    }
    
    $dom->appendChild($rootNode);

    // add to the XML database (or replace if exists)
    $this->basexSession->replace("/obj[@pid='$fedora_object->id']", $dom->saveXML());
    //print($dom->saveXML());

    $ret = null;
    foreach (libxml_get_errors() as $error) {
      // handle errors here
      $ret = $ret . $error;

    }

    libxml_clear_errors();

    return ($ret);
  }



  /**
  * given a PID, delete the entry in the XML database while 
  *
  * https://github.com/Islandora/islandora/wiki/Working-With-Fedora-Objects-Programmatically-Via-Tuque
  *
  * @param string $pid
  *  the Fedora object PID 
  *
  **/
  function basexdb_delete_content($pid, $msgDateTime=null)
  {
    //$obj = islandora_object_load($pid);

    try { 
      $basex_time_str = $this->basexdb_last_modified_time($pid);
      $message_time = (isset($msgDateTime)) ? strtotime($msgDateTime) : null;
      $basex_time = (isset($basex_time_str)) ? strtotime($basex_time_str) : null;
      if ( 
        !isset($msgDateTime) 
        or 
        (isset($basex_time) && $basex_time<=$message_time)
      )
      {
        // if MessageDateTime not set then not from ActiveMQ
        // if the message time ( Fedora Active MQ ) is before the
        // basex DB version then processing order of queue messages
        // out of order given multiple process
        // I.e. object may have been deleted then re-added with same PID
        // therefor don't delete. 
        $this->basexdb_do_delete($pid);
      }
      $ret = TRUE;
    }
    catch (Exception $e)
    {
      $ret = FALSE;
    }

    return $ret;
  }

  /**
  * given a PID, delete the entry in the XML database 
  *
  * https://github.com/Islandora/islandora/wiki/Working-With-Fedora-Objects-Programmatically-Via-Tuque
  *
  * @param string $pid
  *  the Fedora object PID 
  *
  **/
  protected function basexdb_do_delete($pid)
  {
    //$obj = islandora_object_load($pid);

    $this->basexSession->execute("xquery delete node /obj[@pid='$pid']");
  }


  /**
   * given a PID lookup the last modifed time and return
   *
   * @param string $pid
   *   the Fedora object PID
   *
   * @return last modified time
   **/
  function basexdb_last_modified_time($pid)
  {
    return $this->basexSession->execute("xquery /obj[@pid='$pid']/@lastModifiedDate/data()");
  }




}

