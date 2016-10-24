apvhost () {
    bash <(curl -s "https://raw.githubusercontent.com/tbr0/scripts/master/apache-create-virtualhost.sh") $1
}

kicklamp () {
    bash <(curl -s "https://raw.githubusercontent.com/tbr0/scripts/master/ansible-lamp.sh")
}

getpass () {
    bash <(curl -s "https://raw.githubusercontent.com/tbr0/scripts/master/getpass.sh")
}
installtrove () {
    virtualenv trove;
    . trove/bin/activate;
    pip install --upgrade setuptools;
    pip install pytz;
    pip install python-troveclient rackspace-auth-openstack;
    echo "DDI:"; read DDI;
    echo "User:"; read USER;
    echo "Key:"; read KEY;
    echo "Database Host:"; read DB_HOST;
    echo "Database UUID:"; read DB_UUID;
    cat << EOF > .trove
export OS_AUTH_URL=https://identity.api.rackspacecloud.com/v2.0/
export OS_REGION_NAME=IAD
export OS_AUTH_SYSTEM=rackspace
export OS_USERNAME=${USER}
export OS_TENANT_ID=${DDI}
export TROVE_SERVICE_TYPE=rax:database
export OS_PASSWORD=${KEY}
export OS_PROJECT_ID=${DDI}
export DB_HOST=${DB_HOST}
export DB_UUID=${DB_UUID}
EOF
    source .trove
}

trove_createdb {
    bash <(curl -s "https://raw.githubusercontent.com/tbr0/scripts/master/trove/dbaas_trove_create_database.sh") $1
}
