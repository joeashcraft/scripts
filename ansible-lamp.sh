if [ -f /etc/redhat-release ]; then
  yum install -y git python-pip python-devel gcc
  pip install paramiko PyYAML jinja2 httplib2 ansible
  git clone https://github.com/rillip3/lamp.git
  cd lamp/site-cookbooks/LAMP/files/default/lamp 
  ansible-playbook -i hosts site.yml
fi
if [ -f /etc/debian_version ]; then
  apt-get update && apt-get install python-markupsafe python-apt libffi-dev python-pip build-essential python-dev git -y
  pip install paramiko PyYAML jinja2 httplib2 ansible==1.6.1 markupsafe
  pip install paramiko PyYAML jinja2 httplib2 ansible==1.6.1 markupsafe --upgrade
  git clone https://github.com/rillip3/lamp.git
  cd lamp/site-cookbooks/LAMP/files/default/lamp
  ansible-playbook -i hosts site.yml
fi 
