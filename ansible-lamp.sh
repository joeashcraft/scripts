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
        pip install paramiko PyYAML jinja2 httplib2 ansible==1.6.1 markupsafe --upgrade
        pip install --upgrade --force-reinstall --no-binary :all: ansible==1.6.1
    fi
    git clone https://github.com/rackerlabs/lamp.git && \
    cd lamp/site-cookbooks/LAMP/files/default/lamp && \
    ansible-playbook -i hosts site.yml
fi
