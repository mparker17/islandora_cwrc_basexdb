# Islandora CWRC BasexDB

Objectives:
--
* Provide a framework and api for efficiently building analytical tools, reports, and clean-up tools leveraging the XML content and hierarchies with the XML content while adhearing to the XACML policies within Fedora

* Increases flexibility during query/analysis operations by indexing Fedora XML content within a read-only XML Database.  This module connects Islandora/Fedora to an XML database to allow advanced XQuery 3.0 with full-text query execution on Fedora XML content to help power advanced queries for analysis purposes. 

Features:
--

* connect Islandora/Fedora to an XML Database via microservices for automatic updates
  * Fedora messaging queue based PHP listener (https://github.com/cwrc/php_listeners) triggers creation/update/deletion/purging of content (i.e. 'D' state and purge both remove from the XMLdb).
  
* provide a manual mechanism to update the XML Database based on create/modified dates (e.g. in event event queue crashes or automatic updates are not needed or to bootstrap the XML database)
  * drush script to bootstrap and initially populate XMLdb

* retain XACML access control mechanisms with the XMLdb (modelled after the Solrequivalent - 2015-08-17) 
  * assumption: users are not allowed to write XPath/XQuery as those could circumvent the access control mechanism. XPath/Xquery should be verified before adding to the collection.

* provide a Drupal API to execute XQueries against the XMLdb respecting the Fedora XACML access conditions on the object (modelled after the Solr integration - 2015-08-17)
  * sample reports https://github.com/cwrc/cwrc_reports_test - 2015-07-17
 
* output XML that can be transformed into HTML or raw HTML 

Install
--
* install BaseX v8.2+ as per directions - http://basex.org/products/download/all-downloads/
  * create a new XML DB user 
  * the drupal module includes a Drush script to create the appropriate XML dbs assuming the created user has ""CREATE"" permissions 
  * "CHOP" should be enabled - http://docs.basex.org/wiki/Options#Create_Options
    * the code should handle this but as of 2015-09-30 it has not been tested
* add to the Drupal libraries directory
  * https://github.com/cwrc/basex-api 
    * basex-api/BaseXClient.php - modified version of https://github.com/BaseXdb/basex/tree/master/basex-api/src/main/php
* install the following Drupal modules to enable the admin form
  * https://www.drupal.org/project/encrypt
  * https://www.drupal.org/project/encryptfapi
* install the following Drupal module to connect Islandora to an XML DB
  * https://github.com/cwrc/islandora_cwrc_basexdb.git
  * use the admin interface to configure 
    * admin/islandora/tools/islandora_cwrc_basex
  * use drush to initialize the XML db
    * drush -u 1 islandora_cwrc_basexdb_init_db
  * to bootstrap the XML DB with the current contents of Fedora:
    * drush -u 1 islandora_cwrc_basexdb_load_multiprocess
    * note: please change the number of processes - $numChildProcesses - depending on the server hardware
  * to continiously update the XML db as Fedora objects are altered, a listener can be used to connect to the Fedora messaging queue.
    * https://github.com/cwrc/php_listeners


* be sure to update firewall rules and username/password for BaseX server 



Notes:
--
* don''t use the BaseX client as it disrupts concurrency when the server instance is trying to write - 2 separate JVMs can''t be trying to write. 
  * http://docs.basex.org/wiki/Startup#Concurrent_Operations

= XMLdb structure
```
<obj pid="" label="" lastModifiedDate="" createdDate="">
  <{datastream text/xml | application/xml | RELS-EXT}_DS>
    element name is the Fedora datastream ID (DSID) appended with "_DS"
    contents of element are the contents of the Fedora datastream
  </>
</obj>
```
