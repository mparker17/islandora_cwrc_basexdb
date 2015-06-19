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
    'xmldb connection' => array(
      '#type' => 'fieldset',

      'islandora_cwrc_basexdb_server_url' => array(
        '#type' => 'textfield',
        '#title' => t('XML Database server hostname'),
        '#description' => t('Hostname running the XML Database servier.'),
        '#default_value' => variable_get('islandora_cwrc_basexdb_server_url', 'localhost'),
      ),

      'islandora_cwrc_basexdb_server_port' => array(
        '#type' => 'textfield',
        '#title' => t('XML Database server port'),
        '#description' => t('Port used to connect to XML Database servier.'),
        '#default_value' => variable_get('islandora_cwrc_basexdb_server_port', '1984'),
      ),

      'islandora_cwrc_basexdb_database_main' => array(
        '#type' => 'textfield',
        '#title' => t('XML Database: main database '),
        '#description' => t('Database used to store the read-only version of the XML data stored within the repository.'),
        '#default_value' => variable_get('islandora_cwrc_basexdb_database_main', 'cwrc_main'),
      ),

      'islandora_cwrc_basexdb_database_cache' => array(
        '#type' => 'textfield',
        '#title' => t('XML Database: cache entities added from remote sources'),
        '#description' => t('XML Database that is used to prevent remote lookups of the details of entities such as GeoNames place target references - cache helps improve preformance.'),
        '#default_value' => variable_get('islandora_cwrc_basexdb_database_cache', 'cwrc_cache'),
      )
    )
  ));
}


