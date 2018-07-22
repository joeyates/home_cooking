class PersonalKitchen::CLI::Init < Thor
  require "securerandom"

  include Thor::Actions
  source_root File.expand_path("../../..", __dir__)

  attr_reader :name

  def initialize(name:)
    super([])
    @name = name
  end

  no_commands do
    def run
      # Here target_directory gets memoized **before** any chdir, ensuring
      # it is relative to the initial path
      self.destination_root = target_directory
      directory "templates", "."
      create_data_bag_key
      install_gems
      tell_user_to_save_data_bag_key
    end
  end

  private

  def create_data_bag_key
    create_file "data_bag_key" do
      data_bag_key
    end
  end

  def tell_user_to_save_data_bag_key
    puts <<~EOT

      Please take note of your data bag key ('data_bag_key') -
      without it you will be locked out of your kitchen.

      Key:
      #{data_bag_key}

    EOT
  end

  def install_gems
    puts "Installing project dependencies..."
    Dir.chdir(target_directory) do
      puts `BUNDLE_GEMFILE=#{gemfile_path} bundle install`
    end
  end

  def target_directory
    @target_directory ||= ::File.expand_path(name)
  end

  def gemfile_path
    @gemfile_path ||= ::File.join(target_directory, "Gemfile")
  end

  def data_bag_key
    @data_bag_key ||= SecureRandom.hex(100)
  end
end
