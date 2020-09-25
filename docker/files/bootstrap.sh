#!/usr/bin/env bash

echo "APT::Acquire::Retries \"3\";" > /etc/apt/apt.conf.d/80-retries
echo '* libraries/restart-without-asking boolean true' | debconf-set-selections

apt-get install --yes python3-pip
pip3 install ansible

ansible-galaxy install git+https://github.com/osism/ansible-docker
ansible-galaxy collection install git+https://github.com/osism/ansible-collection-commons
ansible-galaxy collection install git+https://github.com/osism/ansible-collection-services

ansible-playbook -i localhost, /opt/bootstrap.yml

if [[ -e /home/ubuntu/service/bootstrap.sh ]]; then
  sudo -u ubuntu bash /home/ubuntu/service/bootstrap.sh
fi
