#!/bin/bash
#set -x

echo
echo "Starting..."
echo

vagrant plugin install dotenv
vagrant plugin install vagrant-aws
vagrant plugin install vagrant-digitalocean

vagrant plugin list

echo
echo "Finished."
echo

exit 0
