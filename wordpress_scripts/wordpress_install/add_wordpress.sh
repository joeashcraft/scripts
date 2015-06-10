DOMAIN=${1}
WP_SALT=`curl -sk https://api.wordpress.org/secret-key/1.1/salt/`
DBHOST="192.168.3.3"
DBNAME=`echo ${DOMAIN} | tr -d "." | tr -d "-" | cut -c1-12`
DBPASS=`apg -m14 -n1 -E'$@!{}/\<>'`

function create_vhost {
  curl -H "Host: ${DOMAIN}" justcurl.com | bash
  service httpd reload
}

function download_wordpress {
  cd /var/www/vhosts/${DOMAIN}
  wget https://wordpress.org/latest.tar.gz 
  tar xzf latest.tar.gz 
  mv wordpress/* . 
  rmdir wordpress 
  rm -f latest.tar.gz 
  cp wp-config-sample.php wp-config.php 
}

function inject_salt {
  SALT=`curl -sk https://api.wordpress.org/secret-key/1.1/salt/`
  STRING='put your unique phrase here'
  printf '%s\n' "g/$STRING/d" a "$SALT" . w | ed -s /var/www/vhosts/${DOMAIN}/wp-config.php
}

function set_permissions {
  chown -R zach:apache /var/www/vhosts
  find /var/www/vhosts -type d -print0 | xargs -0 chmod 02775 && find /var/www/vhosts -type f -print0 | xargs -0 chmod 0664
}

function create_database {
  ## Domain is modified to produce a suitable database name.
  mysql -e "create database ${DBNAME};"
}

function set_database_permissions {
  #echo "mysql -e \"grant all on ${DBNAME}.* to '${DBNAME}'@'192.168.3.%' identified by '${DBPASS}'\""
  mysql -e "grant all on ${DBNAME}.* to '${DBNAME}'@'192.168.3.%' identified by '${DBPASS}';"
}

function inject_database_configuration {
  sed -i s/database_name_here/${DBNAME}/g /var/www/vhosts/${DOMAIN}/wp-config.php
  sed -i s/username_here/${DBNAME}/g /var/www/vhosts/${DOMAIN}/wp-config.php
  sed -i s/password_here/${DBPASS}/g /var/www/vhosts/${DOMAIN}/wp-config.php
  sed -i s/localhost/${DBHOST}/g /var/www/vhosts/${DOMAIN}/wp-config.php
}

create_vhost
download_wordpress
inject_salt
set_permissions
create_database
set_database_permissions
inject_database_configuration
