$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "localdoc/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "localdoc"
  s.version     = Localdoc::VERSION
  s.authors     = ["Marica Odagaki"]
  s.email       = ["marica@noredink.com"]
  s.homepage    = "https://github.com/NoRedInk/localdoc"
  s.summary     = "Documentation browser."
  s.description = "A Rails engine for viewing and editing local documentation."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 3.2.22"
  s.add_dependency "haml-rails", ">= 0.4.0"
  s.add_dependency "rake"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "test-unit", "~> 3.0"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "pry-rails"
  s.add_development_dependency "byebug"

  s.post_install_message = <<EOS
Run the following comamnd to generate this engine's assets for the development environment:

  bundle exec rake localdoc:webpack
EOS
end
