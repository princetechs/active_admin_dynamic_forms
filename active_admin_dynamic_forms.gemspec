require_relative "lib/active_admin_dynamic_forms/version"

Gem::Specification.new do |spec|
  spec.name        = "active_admin_dynamic_forms"
  spec.version     = ActiveAdminDynamicForms::VERSION
  spec.authors     = ["sandip parida"]
  spec.email       = ["sandipparida282.gmail.com"]
  spec.homepage    = "https://github.com/princetechs/active_admin_dynamic_forms"
  spec.summary     = "Dynamic form creation and management for Active Admin"
  spec.description = "A Ruby on Rails gem that integrates with Active Admin to enable dynamic form creation and management"
  spec.license     = "MIT"
  
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  
  spec.add_dependency "rails", ">= 6.0.0"
  spec.add_dependency "activeadmin", ">= 2.0.0"
  spec.add_dependency "formtastic", ">= 3.0.0"
  
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "factory_bot_rails"
  spec.add_development_dependency "pry"
end 