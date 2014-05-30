#!/bin/bash
#set -x

trap 'echo -e "\nabort: signal trapped\n"; exit 1' 1 2 3 15

REPO_URL="https://github.com/msykiino/codebox.git"
CHECKOUT="ansible-multi-platforms"
CLONE_AS="ansible"
ALIAS_TO="ansible"

PLATFORM=${1:-""}
PLAYBOOK=${2:-""}

# downgrade packages {{{

# https://forums.aws.amazon.com/thread.jspa?threadID=150273&tstart=0
#curl_version=`curl --version | cut -d " " -f 2 | head -n 1`
#echo $curl_version | grep ^"7.36" >/dev/null 2>&1
#test $? -eq 0 && sudo yum -y downgrade curl libcurl libcurl-devel

# }}}
# git clone {{{

cd ~/
test ! -d "~/repos" && mkdir -p ~/repos

cd ~/repos
if [ ! -d "$CLONE_AS" ]; then
  git clone $REPO_URL $CLONE_AS
  cd $CLONE_AS
  git checkout $CHECKOUT
  cd ~/
  ln -nfs ~/repos/$CLONE_AS $ALIAS_TO
else
  cd $CLONE_AS
  git pull
  cd ~/
fi

# }}}
# run ansible {{{

cd ~/$ALIAS_TO
touch .auto
./ansible-playbook-$PLATFORM $PLAYBOOK -s -v

# }}}

exit 0
