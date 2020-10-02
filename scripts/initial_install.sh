#! /bin/bash
dir="/opt/ansible/scripts"

. ${dir}/helper_functions.sh

section_echo "=== Finished loading configuration ==="

section_echo "=== Installation of docker ==="
sh ${dir}/install_docker.sh
section_echo "=== Finished installation of docker ==="

section_echo "=== Installation of packages ==="
apt install python3 -y
apt install python3-pip -y
apt install ansible -y
apt install expect -y
apt install sshpass -y
pip3 install docker 

section_echo "=== Finished installation of packages ==="

section_echo "=== Setting up environment ==="

#cp /opt/cert/id_rsa /home/vagrant/.ssh/id_rsa
#chmod 600 /home/vagrant/.ssh/id_rsa
#chown vagrant:vagrant /home/vagrant/.ssh/id_rsa

echo "alias untar='tar -zxvf '" >> /home/vagrant/.bashrc
echo "alias sha='shasum -a 256 '" >> /home/vagrant/.bashrc
echo "alias hs='history | grep'" >> /home/vagrant/.bashrc
echo "alias svi='sudo vi'" >> /home/vagrant/.bashrc
echo "alias c='clear'" >> /home/vagrant/.bashrc
echo "alias ll='ls -la'" >> /home/vagrant/.bashrc
echo "alias l.='ls -d .* --color=auto'" >> /home/vagrant/.bashrc
echo "alias cd..='cd ..'" >> /home/vagrant/.bashrc
echo "alias ..='cd ..'" >> /home/vagrant/.bashrc
echo "alias ...='cd ../../../'" >> /home/vagrant/.bashrc
echo "alias ....='cd ../../../../'" >> /home/vagrant/.bashrc
echo "alias .....='cd ../../../../'" >> /home/vagrant/.bashrc
echo "alias grep='grep --color=auto'" >> /home/vagrant/.bashrc
echo "alias h='history'" >> /home/vagrant/.bashrc
echo "alias path='echo -e \${PATH//:/\\n}'" >> /home/vagrant/.bashrc
echo "alias ols=\"ls -la --color | awk '{k=0;for(i=0;i<=8;i++)k+=((substr(\\\$1,i+2,1)~/[rwx]/)*2^(8-i));if(k)printf(\\\" %0o \\\",k);print}'\"" >> /home/vagrant/.bashrc
echo "alias ap=ansible-playbook" >> /home/vagrant/.bashrc
echo "alias a=ansible-playbook" >> /home/vagrant/.bashrc
echo "alias av=ansible-vault" >> /home/vagrant/.bashrc

cd /opt/ansible

section_echo "=== Finished setting up environment ==="
