require "thor"

class PersonalKitchen::CLI < Thor
  autoload :Init, "personal_kitchen/cli/init"
  autoload :Defaults, "personal_kitchen/cli/defaults"

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
    require "personal_kitchen/cli/init"
    Init.new(symbolized_options).run
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
    require "personal_kitchen/cli/defaults"
    Defaults.new(symbolized_options).run
  end

  private

  def symbolized_options
    options.reduce({}) { |h, (k, v)| h[k.intern] = v; h }
  end
end
