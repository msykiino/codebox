#!/bin/bash
#set -x

sshd_config=/etc/ssh/sshd_config

#sudo sed -i 's/^\(PasswordAuthentication yes\)/#\1/' $sshd_config
#sudo sed -i 's/^\(UseDNS yes\)/#\1/'                 $sshd_config
#sudo sed -i 's/^\(X11Forwarding yes\)/#\1/'          $sshd_config

sudo sed -i '/^PasswordAuthentication yes/d' $sshd_config
sudo sed -i '/^UseDNS yes/d'                 $sshd_config
sudo sed -i '/^X11Forwarding yes/d'          $sshd_config

tail -n 1 $sshd_config | grep ^$ >/dev/null 2>&1
test $? -ne 0 && sudo bash -c "echo >> $sshd_config"

grep "^PasswordAuthentication no" $sshd_config >/dev/null 2>&1
test $? -ne 0 && sudo bash -c "echo 'PasswordAuthentication no' >> $sshd_config"

grep "^UseDNS no" $sshd_config >/dev/null 2>&1
test $? -ne 0 && sudo bash -c "echo 'UseDNS no' >> $sshd_config"

tail -n 1 $sshd_config | grep ^$ >/dev/null 2>&1
test $? -ne 0 && sudo bash -c "echo >> $sshd_config"

exit 0
