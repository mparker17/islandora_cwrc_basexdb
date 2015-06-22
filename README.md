# Islandora CWRC BasexDB

Increases flexibility during query/analysis operations by indexing Fedora XML content within a read-only XML Database.  This module connects Islandora/Fedora to an XML database to allow advanced XQuery 3.0 with full-text query execution on Fedora XML content to help power advanced queries for analysis purposes. 

Features:
--
= connect Islandora/Fedora to and XML Database via microservices for automatic updates
= provide a manual mechanism to update the XML Database based on create/modified dates (e.g. in event event queue crashes or automatic updates are not needed or to bootstrap the XML database)
= retain XACML access control mechanisms with the XML contain
= provide an API to execute XQueries

Install
--
= install BaseX v8.2+ as per directions - http://basex.org/products/download/all-downloads/
= add to the Drupal libraries directory
== basex-api/BaseXclient.php - from https://github.com/BaseXdb/basex/tree/master/basex-api/src/main/php
= https://www.drupal.org/project/encrypt
= https://www.drupal.org/project/encryptfapi


= be sure to update firewall rules and username/password for BaseX server 
