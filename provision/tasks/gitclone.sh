#!/bin/bash
#set -x

trap 'echo -e "\nabort: signal trapped\n"; exit 1' 1 2 3 15

REPO_URL="git@github.com:msykiino/codebox.git"
CHECKOUT="ansible-casual-do"
CLONE_AS="ansible"
ALIAS_TO="ansible"

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
ansible-playbook setup.yml -i hosts --connection=local -s -v

# }}}

exit 0
