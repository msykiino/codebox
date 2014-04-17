# -*- mode: ruby -*-
# vi: set ft=ruby :

Dotenv.load

# change default provider to digital_ocean
ENV['VAGRANT_DEFAULT_PROVIDER'] = "digital_ocean"

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

  config.vm.provider :digital_ocean do |provider, override|
    override.vm.hostname          = "vagrant-casual-do"
    override.vm.box               = "digital_ocean"
    override.vm.box_url           = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"
    override.ssh.username         = ENV['DO_SSH_USERNAME']
    override.ssh.private_key_path = ENV['DO_SSH_KEY']

    provider.client_id            = ENV['DO_CLIENT_ID']
    provider.api_key              = ENV['DO_API_KEY']
    provider.ssh_key_name         = "Vagrant"
    provider.region               = "Singapore 1"
    provider.image                = "CentOS 6.5 x64"
    provider.size                 = "512MB" # 512MB | 1GB | 2GB | 4GB | 8GB | 16GB 
    provider.private_networking   = true
    provider.ca_path              = "/usr/local/share/ca-bundle.crt"
    provider.setup                = true

    # disable synced_folder: rsync is not installed on DigitalOcean's guest machine
    override.vm.synced_folder "./", "/vagrant", disabled: true

    # provision
    override.vm.provision :file,  source: "./provision/files/.ssh/config", destination: "/home/#{ENV['DO_SSH_USERNAME']}/.ssh/config"
    override.vm.provision :file,  source: "./provision/files/.gitconfig",  destination: "/home/#{ENV['DO_SSH_USERNAME']}/.gitconfig"
    override.vm.provision :file,  source: "./provision/tasks/gitclone.sh", destination: "/tmp/gitclone.sh"

    override.vm.provision :shell, inline: "chmod 700 /home/#{ENV['DO_SSH_USERNAME']}/.ssh"
    override.vm.provision :shell, inline: "chmod 600 /home/#{ENV['DO_SSH_USERNAME']}/.ssh/config"
    override.vm.provision :shell, inline: "chmod 644 /home/#{ENV['DO_SSH_USERNAME']}/.gitconfig"
    override.vm.provision :shell, inline: "chmod 755 /tmp/gitclone.sh"

    override.vm.provision :shell, path: "./provision/tasks/bootstrap.sh", args: [ENV['DO_SSH_USERNAME']]
  end

end
