if [ -f /etc/redhat-release ]; then
  yum install -y git python-pip python-devel gcc openssl-devel holland-mysqldump python-virtualenv python-virtualenvwrapper
  yum -y update
  source /bin/virtualenvwrapper_lazy.sh
  workon lampenv
  pip install pip --upgrade
  pip install paramiko PyYAML jinja2 httplib2 ansible==1.6.1 markupsafe --upgrade
  git clone https://github.com/rackerlabs/lamp.git
  cd lamp/site-cookbooks/LAMP/files/default/lamp
  ansible-playbook -i hosts site.yml
fi
if [ -f /etc/debian_version ]; then
  #apt-get update && apt-get install python-markupsafe python-apt libffi-dev python-pip build-essential python-dev git -y
  apt-get update && apt-get install python-virtualenv virtualenvwrapper libyaml-dev libffi-dev python-pip build-essential python-dev git -y
  source /usr/share/virtualenvwrapper/virtualenvwrapper_lazy.sh
  mkvirtualenv lampenv
  pip install pip --upgrade
  pip install paramiko PyYAML jinja2 httplib2 ansible==1.6.1 markupsafe --upgrade
  git clone https://github.com/rackerlabs/lamp.git
  cd lamp/site-cookbooks/LAMP/files/default/lamp
  ansible-playbook -i hosts site.yml
fi

