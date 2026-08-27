#!/bin/bash

mysqldump --default-character-set=utf8mb4 \
    -h mysql -u root --password=$ROOT_MYSQL_PASSWORD \
    -C -Q -e --create-options moodle \
    --single-transaction > /var/lib/mysql/moodle-database.sql