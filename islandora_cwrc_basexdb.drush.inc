<?php

/**
 * @file
 * Custom CWRC drush scripts.
 */

/**
 * Implements hook_drush_command().
 */
function islandora_cwrc_basexdb_drush_command() {

  $items = array();

  $items['islandora_cwrc_basexdb_test'] = array(
    'description' => 'Test connection with XML Database',
    'examples' => array(
      'drush -u 1 islandora_cwrc_basexdb_test ',
    ),
    'bootstrap' => DRUSH_BOOTSTRAP_MAX,
  );

  return $items;
}



/**
 * CWRC export batch - book objects
 *
 * $path_to_list_of_book_PIDs
 *  path to the list of book PIDs to export
 * $destination_path
 *  path to save the results
 */
function drush_islandora_cwrc_basexdb_test (
  )
{
  drush_print("Test XML Database");

  // Include modules.

  $connection = null;
  drush_islandora_cwrc_basexdb_init($connection);

  // Display the user.
  drush_print("User: " . $connection->connection->username);

  $file_count = 0;
  $errror_file_count = 0;



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

