require "thor"

class PersonalKitchen::CLI < Thor
  autoload :Init, "personal_kitchen/cli/init"

  desc "init [OPTIONS]", "Creates a personal kitchen"
  long_desc <<~EOT
    Creates a Chef cookbook with the necessary dependencies, sets up the minimal
    data bag, creates an SSH key, a GPG key and a pass store.
    It then adds all files to a new git repo, and commits them.
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

  private

  def symbolized_options
    options.reduce({}) { |h, (k, v)| h[k.intern] = v; h }
  end
end
