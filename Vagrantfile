# -*- mode: ruby -*-
Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu1604"
  config.vm.box_check_update = false

  config.berkshelf.enabled = true
  config.berkshelf.berksfile_path = "test_kitchen/Berksfile"

  config.vm.provision "chef_solo" do |chef|
    chef.data_bags_path = "test_kitchen/data_bags"
    chef.add_recipe "hosts"
    chef.json = {
      "hosts" => {
        "extras" => {
          "0.0.0.0" => "lvh.me",
        },
        "unblock" => [
          "analytics\\.google\\.com",
          "doubleclick\\.net",
          "google-analytics\\.com",
          "googleadservices\\.com",
          "googlesyndication\\.com",
          "newrelic\\.com",
          "nr-data\\.net",
          "smartadserver\\.com"
        ]
      }
    }
  end
end
