<?php

/**
 * @file
 * Handles the display/submission of the admin settings form for this module.
 */

/**
 * Defines the admin settings form.
 *
 * @param array $form
 *   The Drupal form definition.
 * @param array $form_state
 *   The Drupal form state.
 *
 * @return array
 *   The Drupal form definition.
 */
function islandora_cwrc_basexdb_admin_settings_form(array $form, array &$form_state) {
  return system_settings_form(array(
    '#encrypted_fields' => TRUE,
    'xmldb connection' => array(
      '#type' => 'fieldset',

      'islandora_cwrc_basexdb_server_url' => array(
        '#type' => 'textfield',
        '#title' => t('XML Database server hostname'),
        '#description' => t('Hostname running the XML Database servier.'),
        '#default_value' => variable_get('islandora_cwrc_basexdb_server_url', 'localhost'),
        '#required' => TRUE,
      ),

      'islandora_cwrc_basexdb_server_port' => array(
        '#type' => 'textfield',
        '#title' => t('XML Database server port'),
        '#description' => t('Port used to connect to XML Database servier.'),
        '#default_value' => variable_get('islandora_cwrc_basexdb_server_port', '1984'),
        '#required' => TRUE,
      ),

      'islandora_cwrc_basexdb_database_main' => array(
        '#type' => 'textfield',
        '#title' => t('XML Database: main database '),
        '#description' => t('Database used to store the read-only version of the XML data stored within the repository.'),
        '#default_value' => variable_get('islandora_cwrc_basexdb_database_main', 'cwrc_main'),
        '#required' => TRUE,
      ),

      'islandora_cwrc_basexdb_database_cache' => array(
        '#type' => 'textfield',
        '#title' => t('XML Database: cache entities added from remote sources'),
        '#description' => t('XML Database that is used to prevent remote lookups of the details of entities such as GeoNames place target references - cache helps improve preformance.'),
        '#default_value' => variable_get('islandora_cwrc_basexdb_database_cache', 'cwrc_cache'),
        '#required' => TRUE,
      ),

      'islandora_cwrc_basexdb_username' => array(
        '#type' => 'textfield',
        '#title' => t('XML Database: username'),
        '#description' => t('XML Database username.'),
        '#default_value' => variable_get('islandora_cwrc_basexdb_username', ''),
        '#required' => TRUE,
      ),

      'islandora_cwrc_basexdb_password' => array(
        '#type' => 'password',
        '#title' => t('XML Database: password'),
        '#description' => t('XML Database password.'),
        '#default_value' => variable_get('islandora_cwrc_basexdb_password', ''),
        '#required' => TRUE,
        '#encrypt' => TRUE,
      )

    )
  ));
}


/**
 * Validate module settings form.
 */
/*
function islandora_cwrc_basexdb_settings_validate($form, &$form_state) {
    $field =& $form_state['values']['islandora_cwrc_basexdb_password'];
    if (!$field) {
      // Hack to preserve the existing value if no new value is set.
      unset($form_state['values'][$password_field]);
      continue;
    }

    if (module_exists('encrypt') && $field) {
      $field = encrypt($field);
    }
}
 */


/**
 * Retrieves variable with transparent unencryption if supported.
 * https://davehall.com.au/blog/dave/2015/04/13/managing-variables-drupal-7
 *
 * @param string $name
 *   The name of the variable to return.
 *
 * @return mixed
 *   The value of the variable or NULL if not found.
 */
/*
function islandora_cwrc_basexdb_variable_get($name) {
  $encrypted = &drupal_static(__FUNCTION__);
  if (NULL == $encrypted) {
    $encrypted = module_exists('encrypt');
  }

  $var = variable_get($name);
  if (!$encrypted || 'a:3' != substr($var, 0, 3)) {
    return $var;
  }

  return decrypt($var);
}
*/



