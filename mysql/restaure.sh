#!/bin/bash

mysql -h mysql -u moodle --password=$MOODLE_PASSWORD moodle < /var/lib/mysql/moodle-database.sql


# puis:
mysql -h mysql -u moodle --password=$MOODLE_PASSWORD moodle <<EOF

--- erreur de columun index mdl_comm_con_ix already exists
ALTER TABLE mdl_communication DROP INDEX mdl_comm_con_ix;

--- erreur de table existante mdl_qtype_ordering_options already exists
DROP TABLE mdl_qtype_ordering_options;

--- erreur de table existante mdl_subsection already exists
DROP TABLE IF EXISTS mdl_subsection;

--- erreur de table existante mdl_communication_customlink already exists
DROP TABLE IF EXISTS mdl_communication_customlink;

--- erreur de table existante mdl_matrix_room already exists
DROP TABLE IF EXISTS mdl_matrix_room;

--- Attention: Erreur de table existante mdl_tool_mfa_auth already exists
DROP TABLE IF EXISTS mdl_tool_mfa_auth;
DROP TABLE IF EXISTS mdl_tool_mfa_secrets;
DROP TABLE IF EXISTS mdl_tool_mfa;

EOF
