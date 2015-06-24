git clone https://github.com/tbr0/ansible-newrelic.git
cd ansible-newrelic
ansible-playbook -i hosts site.yml -e license_key=${1}
