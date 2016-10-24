#!/bin/bash
DATABASE_HOST=${DB_HOST}
UUID=${DB_UUID}
DATABASE_NAME=${1}
trove database-create ${UUID} ${DATABASE_NAME}
USER_NAME=$(echo "${DATABASE_NAME}" | cut -b1-16)
USER_PASS=$(apg -m22 -n1 -E'`$@!{}/\<>')
trove user-create ${UUID} ${USER_NAME} ${USER_PASS} --databases ${DATABASE_NAME}
echo Host: ${DATABASE_HOST}
echo Database: ${DATABASE_NAME}
echo User: ${USER_NAME}
echo Password: ${USER_PASS}

## Special Wordpress populator, only for fresh Wordpress installs.
#VHOSTNAME=$(echo ${DATABASE_NAME} | sed s/_/\./g)
#WP_CONFIG_PATH=/var/www/vhosts/${VHOSTNAME}/wp-config.php

#sed -i s/localhost/${DATABASE_HOST}/ ${WP_CONFIG_PATH}
#sed -i s/database_name_here/${DATABASE_NAME}/ ${WP_CONFIG_PATH}
#sed -i s/username_here/${USER_NAME}/ ${WP_CONFIG_PATH}
#sed -i s/password_here/${USER_PASS}/ ${WP_CONFIG_PATH}
