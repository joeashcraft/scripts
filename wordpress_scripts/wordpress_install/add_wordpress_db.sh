DOMAIN=${1}
DBHOST="192.168.3.3"
## Domain is modified to produce a suitable database name.
DBNAME=`echo ${DOMAIN} | tr -d "." | cut -c1-12`
DBPASS=`apg -m14 -n1 -E'$@!{}/\<>'`
echo "mysql -e \"grant all on ${DBNAME}.* to '${DBNAME}'@'192.168.3.%' identified by '${DBPASS}'\""
mysql -e "create database ${DBNAME};"
mysql -e "grant all on ${DBNAME}.* to '${DBNAME}'@'192.168.3.%' identified by '${DBPASS}';"
sed -i s/database_name_here/${DBNAME}/g /var/www/vhosts/${DOMAIN}/wp-config.php
sed -i s/username_here/${DBNAME}/g /var/www/vhosts/${DOMAIN}/wp-config.php
sed -i s/password_here/${DBPASS}/g /var/www/vhosts/${DOMAIN}/wp-config.php
sed -i s/localhost/${DBHOST}/g /var/www/vhosts/${DOMAIN}/wp-config.php
