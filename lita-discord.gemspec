Gem::Specification.new do |spec|
  spec.name          = "lita-discord"
  spec.version       = "0.2.0"
  spec.authors       = ["Kyle Boe", "Andrew Kreps"]
  spec.email         = ["ksboe1@gmail.com", "andrew.kreps@gmail.com"]
  spec.description   = "A Discord adapter for Lita"
  spec.summary       = "lita-discord is an adapter for Lita that allows you to use the robot to manage a Discord server."
  spec.homepage      = "https://github.com/onewheelskyward/lita-discord"
  spec.license       = "MIT"
  spec.metadata      = { "lita_plugin_type" => "adapter" }
  spec.required_ruby_version = ">= 2.7"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "lita", ">= 4.7"

  spec.add_dependency 'rest-client', '~> 2'
  spec.add_dependency 'faye-websocket', '~> 0'
  spec.add_dependency 'websocket-client-simple', '~> 0'
  spec.add_dependency 'eventmachine', '~> 1.2'

  spec.add_development_dependency "bundler", "~> 2"
  # spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake", '~> 13'
  spec.add_development_dependency "rack-test", '~> 1.1'
  spec.add_development_dependency "rspec", "~> 3"
end
