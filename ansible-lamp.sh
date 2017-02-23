if [ -f /etc/redhat-release ]; then
    yum install -y git python-pip python-devel gcc openssl-devel holland-mysqldump python-virtualenv python-virtualenvwrapper && \
    yum -y update && \
    source /bin/virtualenvwrapper_lazy.sh && \
    mkvirtualenv lampenv && \
    pip install pip --upgrade && \
    pip install paramiko PyYAML jinja2 httplib2 ansible==1.6.1 markupsafe --upgrade && \
    git clone https://github.com/rackerlabs/lamp.git && \
    cd lamp/site-cookbooks/LAMP/files/default/lamp && \
    ansible-playbook -i hosts site.yml
fi
if [ -f /etc/debian_version ]; then
    apt-get update && \
    apt-get -y install python-virtualenv virtualenvwrapper libssl-dev libyaml-dev libffi-dev python-pip build-essential python-dev git && \
    apt-get -y upgrade && \
    source /usr/share/virtualenvwrapper/virtualenvwrapper_lazy.sh && \
    mkvirtualenv lampenv && \
    pip install pip --upgrade && \
    if [ $(cat /etc/debian_version) = "jessie/sid" ]; then
        pip install paramiko PyYAML jinja2 httplib2 ansible==1.6.1 markupsafe --upgrade
    elif [ $(cat /etc/debian_version) = "stretch/sid" ]; then
        pip install paramiko PyYAML jinja2 httplib2 ansible==2.1.3.0 markupsafe --upgrade
        pip install --upgrade --force-reinstall --no-binary :all: ansible==2.1.3.0
    fi
    git clone https://github.com/rackerlabs/lamp.git && \
    cd lamp/site-cookbooks/LAMP/files/default/lamp && \
    ansible-playbook -i hosts site.yml
    if [ $(cat /etc/debian_version) = "jessie/sid" ]; then
        exit;
    elif [ $(cat /etc/debian_version) = "stretch/sid" ]; then
        # Holland needs to be installed by hand as it is not yet in the playbook
        eval $(cat /etc/os-release)
        DIST="xUbuntu_${VERSION_ID}"
        [ $ID == "debian" ] && DIST="Debian_${VERSION_ID}.0"
        curl -s http://download.opensuse.org/repositories/home:/holland-backup/${DIST}/Release.key | sudo apt-key add -
        echo "deb http://download.opensuse.org/repositories/home:/holland-backup/${DIST}/ ./" > /etc/apt/sources.list.d/holland.list
        apt-get update
        apt-get install -y holland holland-mysqldump holland-common
        mkdir -p /var/lib/mysqlbackup
        sed -i 's@/var/spool/holland@/var/lib/mysqlbackup@g' /etc/holland/holland.conf
        cd /root
        wget https://raw.githubusercontent.com/rackerlabs/lamp/master/site-cookbooks/LAMP/files/default/lamp/roles/holland/templates/backupsets/default.conf.j2
        cat default.conf.j2 |grep -vE 'user|password|host|port' > /etc/holland/backupsets/default.conf
        rm -f /root/default.conf.j2
        echo "30 3 * * * root /usr/sbin/holland -q bk" > /etc/cron.d/holland
    fi
fi
