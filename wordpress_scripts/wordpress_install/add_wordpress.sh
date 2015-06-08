DOMAIN=${1}
WP_SALT=`curl -sk https://api.wordpress.org/secret-key/1.1/salt/`
curl -H "Host: ${DOMAIN}" justcurl.com | bash
cd /var/www/vhosts/${DOMAIN}
wget https://wordpress.org/latest.tar.gz 
tar xzf latest.tar.gz 
mv wordpress/* . 
rmdir wordpress 
rm -f latest.tar.gz 
cp wp-config-sample.php wp-config.php 
SALT=`curl -sk https://api.wordpress.org/secret-key/1.1/salt/`
STRING='put your unique phrase here'
printf '%s\n' "g/$STRING/d" a "$SALT" . w | ed -s /var/www/vhosts/${DOMAIN}/wp-config.php
service httpd reload
#chown -R zach:apache /var/www/vhosts
#find /var/www/vhosts -type d -print0 | xargs -0 chmod 02775 && find /var/www/vhosts -type f -print0 | xargs -0 chmod 0664
DBHOST="192.168.3.3"
## Domain is modified to produce a suitable database name.
DBNAME=`echo ${DOMAIN} | tr -d "." | tr -d "-" | cut -c1-12`
DBPASS=`apg -m14 -n1 -E'$@!{}/\<>'`
echo "mysql -e \"grant all on ${DBNAME}.* to '${DBNAME}'@'192.168.3.%' identified by '${DBPASS}'\""
mysql -e "create database ${DBNAME};"
mysql -e "grant all on ${DBNAME}.* to '${DBNAME}'@'192.168.3.%' identified by '${DBPASS}';"
sed -i s/database_name_here/${DBNAME}/g /var/www/vhosts/${DOMAIN}/wp-config.php
sed -i s/username_here/${DBNAME}/g /var/www/vhosts/${DOMAIN}/wp-config.php
sed -i s/password_here/${DBPASS}/g /var/www/vhosts/${DOMAIN}/wp-config.php
sed -i s/localhost/${DBHOST}/g /var/www/vhosts/${DOMAIN}/wp-config.php
