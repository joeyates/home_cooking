class PersonalKitchen::CLI::Defaults < Thor
  include Thor::Actions

  require "chef"
  require "chef/workstation_config_loader"
  require "chef/encrypted_data_bag_item"

  include Chef::EncryptedDataBagItem::CheckEncrypted

  DATA_BAG = "personal"
  DATA_BAG_ITEM = "defaults"
  DEFAULT_CONTENT = {"id" => DATA_BAG_ITEM}

  attr_reader :username

  def initialize(username:)
    super([])
    @username = username
  end

  no_commands do
    def run
      load_config
      data[:username] = username if username
      save!
    end
  end

  private

  def load_config
    Chef::Config[:solo_legacy_mode] = true
    Chef::Config.local_mode = true
    Chef::Config[:solo] = true
    config_loader = Chef::WorkstationConfigLoader.new(nil, Chef::Log)
    config_loader.explicit_config_file = ".chef/knife.rb"
    config_loader.load
  end

  def save!
    item = Chef::DataBagItem.from_hash(data)
    item.data_bag(DATA_BAG)
    encrypted_data = Chef::EncryptedDataBagItem.encrypt_data_bag_item(
      item, secret
    )
    ensure_directory
    File.open item_path, 'w' do |f|
      f.write JSON.pretty_generate(encrypted_data)
    end
  end

  def ensure_directory
    if !File.directory?(data_bags_path)
      Dir.mkdir(data_bags_path)
    end
    if !File.directory?(data_bag_path)
      Dir.mkdir(data_bag_path)
    end
  end

  def data
    @data ||=
      begin
        if encrypted?(item.raw_data)
          Chef::EncryptedDataBagItem.new(item.raw_data, secret).to_hash
        else
          item.to_hash
        end
      end
  end

  def item
    @item ||=
      begin
        if item_exists?
          Chef::DataBagItem.load(DATA_BAG, DATA_BAG_ITEM)
        else
          item = Chef::DataBagItem.from_hash(DEFAULT_CONTENT)
          item.data_bag(DATA_BAG)
          item
        end
      end
  end

  def item_path
    ::File.join(data_bag_path, DATA_BAG_ITEM) + ".json"
  end

  def item_exists?
    ::File.exists?(item_path)
  end

  def data_bag_path
    ::File.join(data_bags_path, DATA_BAG)
  end

  def secret
    @secret ||= ::File.read(secret_path)
  end

  def data_bags_path
    Chef::Config[:data_bag_path] || "data_bags"
  end

  def secret_path
    Chef::Config[:encrypted_data_bag_secret] || "data_bag_key"
  end
end
