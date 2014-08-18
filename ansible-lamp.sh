if [ -f /etc/redhat-release ]; then
  echo "No Redhat version yet."
fi
if [ -f /etc/debian_version ]; then
  apt-get -y update && apt-get install python-apt python-pip build-essential python-dev git
  pip install paramiko PyYAML jinja2 httplib2 ansible
  git clone https://github.com/rackspace-orchestration-templates/lamp
  cd lamp/site-cookbooks/LAMP/files/default/lamp
  ansible-playbook -i hosts site.yml
fi 
