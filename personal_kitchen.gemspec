
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) if !$LOAD_PATH.include?(lib)
require "personal_kitchen/version"

Gem::Specification.new do |spec|
  spec.name          = "personal_kitchen"
  spec.version       = PersonalKitchen::VERSION
  spec.authors       = ["Joe Yates"]
  spec.email         = ["joe.g.yates@gmail.com"]

  spec.summary       = %q{Use Chef to configure your users on various computers.}
  spec.description   = <<~EOT
    Create a Chef kitchen that handles default, and node-specific
    setup for your user environment on every computer you use.
  EOT
  spec.homepage      = "https://gitlab.com/joeyates/personal_kitchen"
  spec.license       = "MIT"

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec)/}) }
  end
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
