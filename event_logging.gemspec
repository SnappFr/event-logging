$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "event_logging/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "event_logging"
  s.version     = EventLogging::VERSION
  s.authors     = ["Emeric"]
  s.email       = ["egaichet@snapp.fr"]
  s.homepage    = "https://github.com/Snapp-FidMe/event-logging"
  s.summary     = "Rails engine for Event Logging"
  s.description = "Provide concern for write and read models"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5"

  s.add_development_dependency "pg"
end
