# -*- mode: ruby -*-
Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu1604"

  config.berkshelf.enabled = true
  config.berkshelf.berksfile_path = "test_kitchen/Berksfile"

  config.vm.provision "chef_solo" do |chef|
    chef.cookbooks_path = ["test_kitchen/cookbooks", "test_kitchen/site-cookbooks"]
    chef.data_bags_path = "test_kitchen/data_bags"
    chef.add_recipe "personal"
  end
end
