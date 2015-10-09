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
      'drush -u 1 islandora_cwrc_basexdb_init_db'
    ),
    'bootstrap' => DRUSH_BOOTSTRAP_MAX
  );

  $items['islandora_cwrc_basexdb_drop_db'] = array(
    'description' => 'Drop XML Database',
    'examples' => array(
      'drush -u 1 islandora_cwrc_basexdb_drop_db'
    ),
    'bootstrap' => DRUSH_BOOTSTRAP_MAX
  );

  $items['islandora_cwrc_basexdb_load_multiprocess'] = array(
    'description' => 'Load XML Database',
    'examples' => array(
      'drush -u 1 islandora_cwrc_basexdb_load_multiprocess'
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
 
  $items['islandora_cwrc_basexdb_test_delete'] = array(
    'description' => 'Test detete within XML Database',
    'examples' => array(
      'drush -u 1 islandora_cwrc_basexdb_test_delete'
    ),
    'bootstrap' => DRUSH_BOOTSTRAP_MAX
  );


  $items['islandora_cwrc_basexdb_test_xq'] = array(
    'description' => 'Test XQuery',
    'examples' => array(
      'drush -u 1 -l "http://cwrc-dev-01.srv.ualberta.ca" islandora_cwrc_basexdb_test_xq '
    ),
    'bootstrap' => DRUSH_BOOTSTRAP_MAX
  );


  $items['islandora_cwrc_basexdb_test_auth'] = array(
    'description' => 'Test Fedora XACML access control',
    'examples' => array(
      'drush -u 1 islandora_cwrc_basexdb_test_auth'
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
    module_load_include('inc', 'islandora_cwrc_basexdb', 'includes/helpers');
    module_load_include('inc', 'islandora_cwrc_basexdb', 'includes/xmldb_basex');
    include_once(libraries_get_path(ISLANDORA_CWRC_BASEXDB_LIB) . '/BaseXClient.php');

    // connection to the BaseXDB 
    drush_islandora_cwrc_basexdb_xmldb_config($xmldb_config);
    $basexObj = new xmldb_basex($xmldb_config,null);

    // create new database
    $basexObj->basexSession->execute("check " . variable_get('islandora_cwrc_basexdb_database_main'));
    print $basexObj->basexSession->info();

    $basexObj->basexSession->execute("check " . variable_get('islandora_cwrc_basexdb_database_cache'));
    print $basexObj->basexSession->info();

    print $basexObj->close();

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
    module_load_include('inc', 'islandora_cwrc_basexdb', 'includes/helpers');
    module_load_include('inc', 'islandora_cwrc_basexdb', 'includes/xmldb_basex');
    include_once(libraries_get_path(ISLANDORA_CWRC_BASEXDB_LIB) . '/BaseXClient.php');

    // connection to the BaseXDB 
    drush_islandora_cwrc_basexdb_xmldb_config($xmldb_config);
    $basexObj = new xmldb_basex($xmldb_config,null);

    // create new database
    $basexObj->basexSession->execute("drop db " . variable_get('islandora_cwrc_basexdb_database_main'));
    print $basexObj->basexSession->info();

    $basexObj->basexSession->execute("drop db " . variable_get('islandora_cwrc_basexdb_database_cache'));
    print $basexObj->basexSession->info();
    
    print $basexObj->close();

  } catch (Exception $e) {
     // print exception
     print $e->getMessage();
  } 
}


/**
 * get array of Fedora PIDs to act upon
 **/
function drush_islandora_cwrc_basexdb_get_PID_array()
{
    // connection to Tuque/Islandora
    $fedoraConnection = null;
    drush_islandora_cwrc_basexdb_init($fedoraConnection);
    drush_print('user:' .  $fedoraConnection->connection->username);

    // https://groups.google.com/forum/#!topic/fedora-community/FoKsrCjZzEM
    // https://groups.google.com/forum/#!searchin/islandora/jms/islandora/YVayZCbx-vQ/KRe0X49YYqkJ
    //https://groups.google.com/forum/#!searchin/islandora/mulgara$3Aafter/islandora/ecV7PwQywRM/EFMT4mGIcQUJ

    //$startDate = "2015-06-17T15:29:21.374Z";
    /*
    $startDate = "2005-06-17T15:29:21.374Z";
    $startDate = "2015-07-29T15:29:21.374Z";

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
     */

    $query = <<<EOQ
    SELECT ?object
    FROM <#ri>
    WHERE {
      ?object <fedora-view:lastModifiedDate> ?modified ;
      <fedora-model:hasModel> <info:fedora/fedora-system:FedoraObject-3.0>;
    }
EOQ;

    drush_print($query);

    $results = $fedoraConnection->repository->ri->sparqlQuery($query);

    $fedoraConnection = null;

    return $results;
}

function drush_islandora_cwrc_basexdb_sig_handler($signo) 
{
  global $pids, $pidFileWritten;
  if ($signo == SIGTERM || $signo == SIGHUP || $signo == SIGINT) {
    // If we are being restarted or killed, quit all children
    // Send the same signal to the children which we recieved
    foreach ($pids as $p) {
      posix_kill($p, $signo);
    }

    // Women and Children first (let them exit)
    foreach ($pids as $p) {
      pcntl_waitpid($p, $status);
    }
    drush_print("Parent : " . getmypid() . " all my kids should be gone now. Exiting.\n");
    exit();
  }
  else if ($signo == SIGUSR1) {
    drush_print("I currently have " . count($pids) . " children\n");
  }
}




/**
 * Load content from Islandora/Fedora into BaseX database
 * Use multitasking with multiple process to populate the XML db
 *
 * based on:
 *  http://www.mullie.eu/parallel-processing-multi-tasking-php/
 *  https://github.com/cwrc/php_listeners/blob/taverna-1.x/listener.php
 */
function drush_islandora_cwrc_basexdb_load_multiprocess()
{
  //try 
  {
    drush_print("Load XML Database content from Islandora/Fedora");
    
    // Include modules.
    module_load_include('inc', 'islandora_cwrc_basexdb', 'includes/helpers');
    module_load_include('inc', 'islandora_cwrc_basexdb', 'includes/xmldb_basex');
    include_once(libraries_get_path(ISLANDORA_CWRC_BASEXDB_LIB) . '/BaseXClient.php');

    // number of child processes
    $numChildProcesses = 5;
    $numChildProcesses = 10;
    $numChildProcesses = 20;
    $numChildProcesses = 50;

    // Handle interrupt signals
    ini_set('display_errors', 0);

    // process ids
    global $pids;
    $pids = array();

    // Handle signals so we can exit nicely
    declare(ticks = 1);

    // setup signal handlers to actually catch and direct the signals
    pcntl_signal(SIGTERM, "drush_islandora_cwrc_basexdb_sig_handler");
    pcntl_signal(SIGHUP, "drush_islandora_cwrc_basexdb_sig_handler");
    pcntl_signal(SIGINT, "drush_islandora_cwrc_basexdb_sig_handler");
    pcntl_signal(SIGUSR1, "drush_islandora_cwrc_basexdb_sig_handler");

    // setup authentication for the XML DB
    $xmldb_config = null;
    drush_islandora_cwrc_basexdb_xmldb_config($xmldb_config); 

    // get array of Fedora PIDs to add to the XML DB
    $results = drush_islandora_cwrc_basexdb_get_PID_array();

    $cnt = 0;
    foreach ($results as $result) 
    {
      $cnt++;
      drush_print("cnt:" . $cnt);

      $fedoraPid = $result['object']['value']; // match SparQL select term
      drush_print("tmp:" . $fedoraPid);

      {
        $pid = pcntl_fork();
        if ($pid == 0) 
        { 
          try {
            // child process
            //drush_print("Child : " . getmypid() . "\n");

            // ToDo - more efficient way instead of opening and closing connect
            // each time - unable to install pthreads
            // connection to Tuque/Islandora
            $fedoraConnection = null;
            drush_islandora_cwrc_basexdb_init_multitasking($fedoraConnection);

            // connection to the BaseXDB 
            $basexObj = null; 
            $basexObj = new xmldb_basex($xmldb_config,null);
            $basexObj->basexSession->execute("check " . variable_get('islandora_cwrc_basexdb_database_main'));
            //drush_print($basexObj->basexSession->info());

            //drush_print("child fedoraPid: " . $fedoraPid);
            $fedora_object = islandora_object_load($fedoraPid);
            if ($fedora_object)
            {
              $tmp = $basexObj->basexdb_add_content($fedora_object);
              if ($tmp != null)
              {
                drush_print($tmp);
              }
            }
            //drush_print($basexObj->basexSession->info());
            
            $basexObj->close();
            $basexObj = null; 
            $fedoraPid = null; 
            $fedora_object = null; 
            $fedoraConnection = null;
          }
          catch (Exception $e)
          {
            $file_error_count++;
            drush_print("pid=$fedoraPid was not added.");
            drush_print($e->getMessage());
          }
          //exit(0); // causes: Drush command terminated abnormally due to an unrecoverable error.
          break;
        }
        if ($pid > 0) 
        {
          // parent process
          //drush_print("Parent : " . getmypid() . "\n");
          // add pids to a global array, so that when we get a kill signal
          // tell the kids to flush and exit.
          $pids[] = $pid;
          //drush_print("pid:" . $pid . " count:" . count($pids) . '-' . $numChildProcesses);
          //drush_print("parent:" . $fedoraPid);
          $currentPidsCnt = count($pids);
          if ($currentPidsCnt >= $numChildProcesses && $currentPidsCnt != 0) 
          {
            // Collect any children which have exited on their own. pcntl_waitpid will
            // return the PID that exited or 0 or ERROR
            // WNOHANG means we won't sit here waiting if there's not a child ready
            // for us to reap immediately
            // -1 means any child

            $dead_and_gone = pcntl_waitpid(-1, $status);
            while ($dead_and_gone > 0) {
              //drush_print("wait2:" . $dead_and_gone);

              // Remove the gone pid from the array
              unset($pids[array_search($dead_and_gone, $pids)]);

              // Look for another one
              $dead_and_gone = pcntl_waitpid(-1, $status, WNOHANG);
            }
          }
        }
        if ($pid ==-1 ) 
        {
          drush_print("error no child created" . "\n");
        }


      }
      // Roughly ever 60 seconds print the memory usage
      if ($timer > 1200) {
        drush_print("Daemon memory usage: " . memory_get_usage() . "\n");
        $timer = 0;
      }
      $timer++;
      // Sleep for 1 second
      //usleep(50000);
    }
  } 

//  catch (Exception $e) 
//  {
//     // print exception
//     print $e->getMessage();
//  } 

  if ( $pid > 0 and count($pids) != 0 )
  {
    // Collect any children which have exited on their own. pcntl_waitpid will
    // return the PID that exited or 0 or ERROR
    // WNOHANG means we won't sit here waiting if there's not a child ready
    // for us to reap immediately
    // -1 means any child
    do
    { 
      $dead_and_gone = pcntl_waitpid(-1, $status);
        // Remove the gone pid from the array
        unset($pids[array_search($dead_and_gone, $pids)]);

    } while (count($pids) != 0);
  }


  $xmldb_config = null;
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
    module_load_include('inc', 'islandora_cwrc_basexdb', 'includes/helpers');
    module_load_include('inc', 'islandora_cwrc_basexdb', 'includes/xmldb_basex');
    include_once(libraries_get_path(ISLANDORA_CWRC_BASEXDB_LIB) . '/BaseXClient.php');

    // connection to Tuque/Islandora
    $fedoraConnection = null;
    drush_islandora_cwrc_basexdb_init($fedoraConnection);
    drush_print('user:' .  $fedoraConnection->connection->username);

    // connection to the BaseXDB 
    drush_islandora_cwrc_basexdb_xmldb_config($xmldb_config); 
    $basexObj = new xmldb_basex($xmldb_config,null);
    $basexObj->basexSession->execute("check " . variable_get('islandora_cwrc_basexdb_database_main'));
    drush_print($basexObj->basexSession->info());

    // https://groups.google.com/forum/#!topic/fedora-community/FoKsrCjZzEM
    // https://groups.google.com/forum/#!searchin/islandora/jms/islandora/YVayZCbx-vQ/KRe0X49YYqkJ
    //https://groups.google.com/forum/#!searchin/islandora/mulgara$3Aafter/islandora/ecV7PwQywRM/EFMT4mGIcQUJ

    //$startDate = "2015-06-17T15:29:21.374Z";
    //$startDate = "2005-06-17T15:29:21.374Z";
    $startDate = "2015-09-17T15:29:21.374Z";

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
        $fedora_object = islandora_object_load($pid);
        drush_print($basexObj->basexdb_add_content($fedora_object));
        drush_print($basexObj->basexSession->info());

      }
      catch (Exception $e)
      {
        $file_error_count++;
        drush_print("pid=$pid was not added.");
        drush_print($e->getMessage());
      }
    }

    $basexObj->close();

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
  module_load_include('inc', 'islandora_cwrc_basexdb', 'includes/helpers');
  module_load_include('inc', 'islandora_cwrc_basexdb', 'includes/xmldb_basex');
  include_once(libraries_get_path(ISLANDORA_CWRC_BASEXDB_LIB) . '/BaseXClient.php');

  // connection to Tuque/Islandora
  $connection = null;
  drush_islandora_cwrc_basexdb_init($connection);

  //database details
  drush_print(variable_get('islandora_cwrc_basexdb_server_url'));
  drush_print(variable_get('islandora_cwrc_basexdb_server_port'));
  drush_print('user:' . variable_get('islandora_cwrc_basexdb_username'));

  // connection to the BaseXDB 
  drush_islandora_cwrc_basexdb_xmldb_config($xmldb_config);
  $basexObj = new xmldb_basex($xmldb_config,null);

  // Display the user.
  drush_print("User: " . $connection->connection->username);

  $file_count = 0;
  $errror_file_count = 0;

  // create new database
  $basexObj->basexSession->execute("check " . variable_get('islandora_cwrc_basexdb_database_main'));
  print $basexObj->basexSession->info();

  drush_print($basexObj->basexSession->execute("INFO DB"));


 // add to the database
  $basexObj->basexSession->add('/cwrc', "<z>sadf \n <a> asf </a> asdf</z>");

  // run query on database
  print $basexObj->basexSession->execute("xquery /").'\n';

  // bind variables 
  $input = 'declare variable $name external; for $i in 1 to 3 return element { $name } { $i }';
  // bind variable
  $basexQuery = $basexObj->basexSession->query($input);
  $basexQuery->bind('$name', 'number');
  drush_print($basexQuery->execute());
  drush_print($basexObj->basexSession->info());


  // 'more' and 'next' loop
  $basexQuery = $basexObj->basexSession->query($input);
  $basexQuery->bind('$name', 'number');
  // loop through all results
  while($basexQuery->more()) {
      drush_print($basexQuery->next());
  }
  drush_print($basexObj->basexSession->info());

  $basexQuery->close();
  $basexObj->close();



  drush_print('Complete');
  drush_print('Number of files exported: ' . $file_count);
  drush_print('Number of errors: ' . $file_error_count);
}



function drush_islandora_cwrc_basexdb_test_auth()
{

  drush_islandora_cwrc_basexdb_init ($connection);
  drush_print('user:' .  $connection->connection->username);

  $pid = 'cwrc:alltag-w';

  $obj = islandora_object_load($pid);


  if (!$obj)
  {
    drush_print('Error: failed to load - ['.$pid. ']') ;
  }
  else
  { 
    drush_print($obj->id);
  }
}


function drush_islandora_cwrc_basexdb_test_delete()
{

  // Include modules.
  module_load_include('inc', 'islandora_cwrc_basexdb', 'includes/helpers');
  module_load_include('inc', 'islandora_cwrc_basexdb', 'includes/xmldb_basex');
  include_once(libraries_get_path(ISLANDORA_CWRC_BASEXDB_LIB) . '/BaseXClient.php');

  global $user;
  drush_islandora_cwrc_basexdb_init ($connection);
  drush_print('user:' .  $user->name);

  $user_roles = "('".implode("','", $user->roles)."')";
  drush_print('roles:' . $user_roles);


  // connection to the BaseXDB 
  drush_islandora_cwrc_basexdb_xmldb_config($xmldb_config);
  $basexObj = new xmldb_basex($xmldb_config,null);


  // open XML Database 
  $basexObj->basexSession->execute("OPEN " . variable_get('islandora_cwrc_basexdb_database_main')); 
  drush_print($basexObj->basexSession->info());

  $basexObj->basexdb_delete_content('cwrc:alltag-w');
  drush_print($basexObj->basexSession->info());

  $basexObj->close();


}


function drush_islandora_cwrc_basexdb_test_xq()
{

  // Include modules.
  module_load_include('inc', 'islandora_cwrc_basexdb', 'includes/helpers');
  module_load_include('inc', 'islandora_cwrc_basexdb', 'includes/xmldb_basex');
  include_once(libraries_get_path(ISLANDORA_CWRC_BASEXDB_LIB) . '/BaseXClient.php');

  global $user;
  drush_islandora_cwrc_basexdb_init ($connection);
  drush_print('user:' .  $user->name);

  $user_roles = "('".implode("','", $user->roles)."')";
  drush_print('roles:' . $user_roles);


  // connection to the BaseXDB 
  drush_islandora_cwrc_basexdb_xmldb_config($xmldb_config);
  $basexObj = new xmldb_basex($xmldb_config,null);


  // open XML Database 
  $basexObj->basexSession->execute("OPEN " . variable_get('islandora_cwrc_basexdb_database_main')); 
  drush_print($basexObj->basexSession->info());

  //$basexSession->execute("SET BINDINGS {cwAccessibility}user_external=".$connection->connection->username); 
  //drush_print($basexSession->execute("GET BINDINGS"));
  $xquery_bindings = "map { '{cwAccessibility}user_external' : '$user->name', '{cwAccessibility}role_external' : $user_roles }";


  Global $base_url;
  $base_xquery = $base_url . '/'. drupal_get_path('module','islandora_cwrc_basexdb') .  '/xq/';
  $basexObj->basexSession->execute('SET QUERYPATH ' . $base_xquery );

  // 2015-06-26
  // ToDo: using this syntax as the BaseX server is running on another
  // server and the 'RUN' command doesn't understand URIs
  //$xqueryStr = 'xquery:eval(fetch:text("'.$base_xquery.'template.xq"), '.$xquery_bindings.')';
  $xq_file = 'template.xq';
  $xq_file = 'orlando_researchnotes_lookup.xq';
  $xq_file = 'orlando_workflow_new.xq';
  $xq_file = 'orlando_bibcit_lookup.xq';
  $xq_file = '/xml_tag_search_facets.xq';
  $xqueryStr = 'xquery:eval(fetch:text("'.$base_xquery.$xq_file.'"), '.$xquery_bindings.')';
  //$xqueryStr = 'xquery:eval(fetch:text("'.$base_xquery.'template.xq"))';
  drush_print($xqueryStr);

  //drush_print($basexSession->execute('xquery ' . $xqueryStr));
  //drush_print($basexSession->info());

  //$basexSession->execute("SET BINDINGS"); 
  //drush_print($basexSession->execute("GET BINDINGS"));

  $basexQuery = $basexObj->basexSession->query($xqueryStr);

  // 2015-06-26
  // ToDo: appears bind is overridden given the manner the XQuery is being called 
  //$basexQuery->bind('user_external', $user->name);
  //$basexQuery->bind('role_external', $user_roles);
  drush_print($basexQuery->execute());
  drush_print($basexObj->basexSession->info());

  $basexObj->close();


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

  ini_set('max_execution_time', 86400);


  // Get the tuque connection.
  $connection = islandora_get_tuque_connection();

  // grab the current user specified as on the command-line via 'drush -u 0'
  //$user = user_load_by_name($GLOBALS['user']->name);
  global $user;
  $connection->connection->username = $user->name;
  $connection->connection->password = $user->pass;
}


/**
 * CWRC migration batch - migration_init
 *
 * @param string $connection
 *   tuque connection object
 */
function drush_islandora_cwrc_basexdb_init_multitasking (
    &$connection
  )
{
  // Include modules.
  //module_load_include('inc', 'islandora', 'includes/utilities');
  //module_load_include('inc', 'cwrc_migration_batch', 'includes/helpers');

  //ini_set('max_execution_time', 300);

  ini_set('max_execution_time', '1209600' );
  set_time_limit(1209600);


  // Get the tuque connection.
  $connection = islandora_get_tuque_connection();
  // CurlConnection >createCookieFile() - used to generate new tempnam
  // and not resuse the one in the cached version
  $connection->connection->__construct();
  //$connection->connection->reuseConnection = FALSE;
  //$connection->connection->reuseConnection = FALSE;
  //$connection->connection->cookies = FALSE;
  //if (IslandoraTuque::exists()) {
    //try {
        //$connection = new IslandoraTuque();
    //}
    //catch (Exception $e) {
        //drupal_set_message(t('Unable to connect to the repository %e', array('%e' => $e)), 'error');
      //}
  //}



  // grab the current user specified as on the command-line via 'drush -u 0'
  //$user = user_load_by_name($GLOBALS['user']->name);
  global $user;
  $connection->connection->username = $user->name;
  $connection->connection->password = $user->pass;
}




/**
 * CWRC migration batch - migration_init
 *
 * @param string $connection
 *   tuque connection object
 */
function drush_islandora_cwrc_basexdb_xmldb_config (
    &$xmldb_config
  )
{
  $xmldb_config = new stdClass;
  $xmldb_config->basexdb_server_url = variable_get('islandora_cwrc_basexdb_server_url');
  $xmldb_config->basexdb_server_port = variable_get('islandora_cwrc_basexdb_server_port');
  $xmldb_config->basexdb_username = variable_get('islandora_cwrc_basexdb_username');
  $xmldb_config->basexdb_password = islandora_cwrc_basexdb_get_password('islandora_cwrc_basexdb_password');
}

