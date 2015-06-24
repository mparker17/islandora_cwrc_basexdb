<?php

/**
 * @file
 * Custom CWRC drush scripts.
 */

/**
 * Implements hook_drush_command().
 */
function islandora_cwrc_basexdb_drush_command() 
{

  $items = array();

  $items['islandora_cwrc_basexdb_init_db'] = array(
    'description' => 'Initialize XML Database',
    'examples' => array(
      'drush -u 1 islandora_cwrc_basexdb_init'
    ),
    'bootstrap' => DRUSH_BOOTSTRAP_MAX
  );

  $items['islandora_cwrc_basexdb_drop_db'] = array(
    'description' => 'Drop XML Database',
    'examples' => array(
      'drush -u 1 islandora_cwrc_basexdb_drop'
    ),
    'bootstrap' => DRUSH_BOOTSTRAP_MAX
  );

  $items['islandora_cwrc_basexdb_load_by_last_modified'] = array(
    'description' => 'Load XML Database',
    'examples' => array(
      'drush -u 1 islandora_cwrc_basexdb_load_by_last_modified'
    ),
    'bootstrap' => DRUSH_BOOTSTRAP_MAX
  );


  $items['islandora_cwrc_basexdb_test'] = array(
    'description' => 'Test connection with XML Database',
    'examples' => array(
      'drush -u 1 islandora_cwrc_basexdb_test '
    ),
    'bootstrap' => DRUSH_BOOTSTRAP_MAX
  );

  return $items;
}



/**
 * Init BaseX database
 *
 */
function drush_islandora_cwrc_basexdb_init_db()
{
  try 
  {
    drush_print("Init XML Database");
    
    // Include modules.
    module_load_include('inc', 'islandora_cwrc_basexdb', 'includes/basexdb');
    include_once(libraries_get_path(ISLANDORA_CWRC_BASEXDB_LIB) . '/BaseXclient.php');

    // connection to the BaseXDB 
    $basexSession = null;
    $basexSession = islandora_cwrc_basexdb_init();

    // create new database
    $basexSession->execute("check " . variable_get('islandora_cwrc_basexdb_database_main'));
    print $basexSession->info();

    $basexSession->execute("check " . variable_get('islandora_cwrc_basexdb_database_cache'));
    print $basexSession->info();

    print $basexSession->close();

  } catch (Exception $e) {
     // print exception
     print $e->getMessage();
  } 
}

/**
 * Drop BaseX database
 *
 */
function drush_islandora_cwrc_basexdb_drop_db()
{
  try 
  {
    drush_print("Drop XML Database");
    
    // Include modules.
    module_load_include('inc', 'islandora_cwrc_basexdb', 'includes/basexdb');
    include_once(libraries_get_path(ISLANDORA_CWRC_BASEXDB_LIB) . '/BaseXclient.php');

    // connection to the BaseXDB 
    $basexSession = null;
    $basexSession = islandora_cwrc_basexdb_init();

    // create new database
    $basexSession->execute("drop db " . variable_get('islandora_cwrc_basexdb_database_main'));
    print $basexSession->info();

    $basexSession->execute("drop db " . variable_get('islandora_cwrc_basexdb_database_cache'));
    print $basexSession->info();
    
    print $basexSession->close();

  } catch (Exception $e) {
     // print exception
     print $e->getMessage();
  } 
}

/**
 * Load content from Islandora/Fedora into BaseX database
 *
 */
function drush_islandora_cwrc_basexdb_load_by_last_modified()
{
  try 
  {
    drush_print("Load XML Database content from Islandora/Fedora by last modified date");
    
    // Include modules.
    module_load_include('inc', 'islandora_cwrc_basexdb', 'includes/basexdb');
    include_once(libraries_get_path(ISLANDORA_CWRC_BASEXDB_LIB) . '/BaseXclient.php');

    // connection to Tuque/Islandora
    $fedoraConnection = null;
    drush_islandora_cwrc_basexdb_init($fedoraConnection);

    // connection to the BaseXDB 
    $basexSession = null;
    $basexSession = islandora_cwrc_basexdb_init();
    $basexSession->execute("check " . variable_get('islandora_cwrc_basexdb_database_main'));
    drush_print($basexSession->info());

    // https://groups.google.com/forum/#!topic/fedora-community/FoKsrCjZzEM
    // https://groups.google.com/forum/#!searchin/islandora/jms/islandora/YVayZCbx-vQ/KRe0X49YYqkJ
    //https://groups.google.com/forum/#!searchin/islandora/mulgara$3Aafter/islandora/ecV7PwQywRM/EFMT4mGIcQUJ
    $startDate = "2015-06-17T15:29:21.374Z";

    $query = <<<EOQ
    SELECT ?object
    FROM <#ri>
    WHERE {
      ?object <fedora-view:lastModifiedDate> ?modified ;
      <fedora-model:hasModel> <info:fedora/fedora-system:FedoraObject-3.0>;
      FILTER ( 
        ?modified > '$startDate'^^<xml-schema:dateTime>
      )
    }
EOQ;

    drush_print($query);

    //islandora_cwrc_basexdb_add_content('islandora:75a7614e-fd23-431a-ae36-6f521fa83990', $fedoraConnection);


    $results = $fedoraConnection->repository->ri->sparqlQuery($query);

    drush_print("results:");
    
    //var_dump($results);  
    foreach ($results as $result) {
      try {
        $pid = $result['object']['value']; // match SparQL select term
        drush_print($pid);
        drush_print(islandora_cwrc_basexdb_add_content($pid, $basexSession));
        drush_print($basexSession->info());

      }
      catch (Exception $e)
      {
        $file_error_count++;
        drush_print("pid=$pid was not added.");
        drush_print($e->getMessage());
      }
    }

    $basexSession->close();

  } catch (Exception $e) {
     // print exception
     print $e->getMessage();
  } 
}




/**
 * Test BaseX 
 *
 */
function drush_islandora_cwrc_basexdb_test (
  )
{
  drush_print("Test XML Database");

  // Include modules.
  module_load_include('inc', 'islandora_cwrc_basexdb', 'includes/basexdb');
  include_once(libraries_get_path(ISLANDORA_CWRC_BASEXDB_LIB) . '/BaseXclient.php');

  // connection to Tuque/Islandora
  $connection = null;
  drush_islandora_cwrc_basexdb_init($connection);

  //database details
  drush_print(variable_get('islandora_cwrc_basexdb_server_url'));
  drush_print(variable_get('islandora_cwrc_basexdb_server_port'));
  drush_print('user:' . variable_get('islandora_cwrc_basexdb_username'));

  // connection to the BaseXDB 
  $basexSession = null;
  $basexSession = islandora_cwrc_basexdb_init();

  // Display the user.
  drush_print("User: " . $connection->connection->username);

  $file_count = 0;
  $errror_file_count = 0;

  // create new database
  $basexSession->execute("check " . variable_get('islandora_cwrc_basexdb_database_main'));
  print $basexSession->info();

  drush_print($basexSession->execute("INFO DB"));


 // add to the database
  $basexSession->add('/cwrc', "<z>sadf \n <a> asf </a> asdf</z>");

  // run query on database
  print $basexSession->execute("xquery /").'\n';

  // bind variables 
  $input = 'declare variable $name external; for $i in 1 to 3 return element { $name } { $i }';
  // bind variable
  $basexQuery = $basexSession->query($input);
  $basexQuery->bind('$name', 'number');
  drush_print($basexQuery->execute());
  drush_print($basexSession->info());


  // 'more' and 'next' loop
  $basexQuery = $basexSession->query($input);
  $basexQuery->bind('$name', 'number');
  // loop through all results
  while($basexQuery->more()) {
      drush_print($basexQuery->next());
  }
  drush_print($basexSession->info());

  $basexQuery->close();
  $basexSession->close();



  drush_print('Complete');
  drush_print('Number of files exported: ' . $file_count);
  drush_print('Number of errors: ' . $file_error_count);
}


/**
 * CWRC migration batch - migration_init
 *
 * @param string $connection
 *   tuque connection object
 */
function drush_islandora_cwrc_basexdb_init (
    &$connection
  )
{
  // Include modules.
  //module_load_include('inc', 'islandora', 'includes/utilities');
  //module_load_include('inc', 'cwrc_migration_batch', 'includes/helpers');

  ini_set('max_execution_time', 300);


  // Get the tuque connection.
  $connection = islandora_get_tuque_connection();
}
