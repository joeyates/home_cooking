require "thor"

class HomeCooking::CLI < Thor
  require "home_cooking/cli/helpers"

  autoload :Init, "home_cooking/cli/init"
  autoload :Defaults, "home_cooking/cli/defaults"
  autoload :EncryptedFile, "home_cooking/cli/encrypted_file"

  include Helpers

  desc "init [OPTIONS]", "Creates a personal kitchen"
  long_desc <<~EOT
    Creates a Chef cookbook with the necessary dependencies.
  EOT
  method_option(
    "name",
    type: :string, required: true, banner: "the name of the kitchen",
    aliases: ["-n"]
  )
  def init
    require "home_cooking/cli/init"
    Init.new(symbolized(options)).run
  end

  desc "defaults [OPTIONS]", "Sets defaults"
  long_desc <<~EOT
    Sets defaults for: username
  EOT
  method_option(
    "username",
    type: :string, required: true, banner: "your default user name",
    aliases: ["-u"]
  )
  def defaults
    require "home_cooking/cli/defaults"
    Defaults.new(symbolized(options)).run
  end

  desc "file subcommand ...ARGS", "manage files in encrypted data bags"
  subcommand "file", EncryptedFile
end
