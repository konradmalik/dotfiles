API_VERSION = "2"
REPO_PATH = "/home/vagrant/Code/dotfiles"
box = ENV["VAGRANT_BOX"] || "ubuntu/focal64"
# archlinux/archlinux
# ubuntu/focal64

Vagrant.configure(API_VERSION) do |config|
  config.vm.box = box

  # networking
  config.vm.network :private_network, ip: "192.168.10.2"
  config.ssh.forward_agent = true

  # files syncing
  config.vm.synced_folder ".", REPO_PATH

  # provider settings
  config.vm.provider :virtualbox do |vb|
    vb.name = "devenv"
    vb.cpus = 2
    vb.memory = 2048
  end

  # provisioning
  # only for testing ssh ingress in ansible
  #config.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "/home/vagrant/.ssh/id_rsa.pub"
  # main provisioning
  config.vm.provision "ansible_local" do |ansible|
    ansible.playbook = REPO_PATH + "/ansible/playbook.yml"
    ansible.inventory_path = REPO_PATH + "/ansible/inventory.yaml"
    ansible.limit  = "local"
    ansible.provisioning_path = REPO_PATH
    # set this just to force running galaxy
    ansible.galaxy_role_file = REPO_PATH + "/ansible/requirements.yml"
    ansible.galaxy_command = "ansible-galaxy collection install -r " + REPO_PATH + "/ansible/requirements.yml --force"
    ansible.verbose = true
  end
end

