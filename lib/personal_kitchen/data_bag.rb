class PersonalKitchen::DataBag
  require "chef"
  require "chef/workstation_config_loader"
  require "chef/encrypted_data_bag_item"

  include Chef::EncryptedDataBagItem::CheckEncrypted

  attr_reader :group
  attr_reader :item

  def initialize(group:, item:)
    @group = group
    @item = item
    load_config
  end

  def set(key, value)
    data[key] = value
  end

  def save!
    data_bag_item = Chef::DataBagItem.from_hash(data)
    data_bag_item.data_bag(group)
    encrypted_data = Chef::EncryptedDataBagItem.encrypt_data_bag_item(
      data_bag_item, secret
    )
    ensure_directory
    File.open(item_path, "w") do |f|
      f.write JSON.pretty_generate(encrypted_data)
    end
  end

  private

  def data
    @data ||=
      begin
        if encrypted?(data_bag_item.raw_data)
          Chef::EncryptedDataBagItem.new(data_bag_item.raw_data, secret).to_hash
        else
          data_bag_item.to_hash
        end
      end
  end

  def data_bag_item
    @data_bag_item ||=
      begin
        if item_exists?
          Chef::DataBagItem.load(group, item)
        else
          data_bag_item = Chef::DataBagItem.from_hash(default_content)
          data_bag_item.data_bag(group)
          data_bag_item
        end
      end
  end

  def default_content
    {"id" => item}
  end

  def item_path
    ::File.join(data_bag_path, item) + ".json"
  end

  def item_exists?
    ::File.exists?(item_path)
  end

  def data_bag_path
    ::File.join(data_bags_path, group)
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

  def ensure_directory
    if !File.directory?(data_bags_path)
      Dir.mkdir(data_bags_path)
    end
    if !File.directory?(data_bag_path)
      Dir.mkdir(data_bag_path)
    end
  end

  def load_config
    Chef::Config[:solo_legacy_mode] = true
    Chef::Config.local_mode = true
    Chef::Config[:solo] = true
    config_loader = Chef::WorkstationConfigLoader.new(nil, Chef::Log)
    config_loader.explicit_config_file = ".chef/knife.rb"
    config_loader.load
  end
end
