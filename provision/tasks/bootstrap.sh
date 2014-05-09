#!/bin/bash
#set -x

trap 'echo -e "\nabort: signal trapped\n"; exit 1' 1 2 3 15

USERNAME=${1:-""}
PLATFORM=${2:-""}
PLAYBOOK=${3:-""}

if [ ! $USERNAME ]; then
  echo -e "\nabort: USERNAME is not specified.\n" && exit 1
fi
sudo chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

SRC_DIR=/usr/local/src

echo
echo "Starting..."
echo

# add epel repository {{{

ls /etc/yum.repos.d | grep -i ^epel >/dev/null 2>&1
if [ $? -ne 0 ]; then
  if [ ! -d $SRC_DIR ]; then
    mkdir -p $SRC_DIR
    sudo chown root:root $SRC_DIR
  fi
  cd $SRC_DIR
  sudo curl -LOk http://ftp.riken.jp/Linux/fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm
  sudo rpm -ivh epel-release-6-8.noarch.rpm 
fi

# }}}
# yum upgrade {{{

sudo yum check-update
sudo yum -y upgrade

# }}}
# install packages {{{

PACKAGES=`cat <<_EOT_
git
ansible
python-setuptools
rsync
_EOT_`

for i in $PACKAGES
do
  sudo yum --enablerepo=epel -y install $i
done

# }}}
# run external script {{{

if [ $PLATFORM -a $PLAYBOOK ];
then
  (sudo -u $USERNAME /bin/bash /tmp/clonerepo.sh $PLATFORM $PLAYBOOK && rm -f /tmp/clonerepo.sh)
else
  echo -e "\nskip: PLATFORM or PLAYBOOK to run is (or are both) not specified.\n"
fi

# }}}
# yum check-update {{{

sudo yum check-update

# }}}

echo
echo "Finished."
echo

sudo chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

exit 0
