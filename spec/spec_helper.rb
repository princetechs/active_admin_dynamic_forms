require 'bundler/setup'
require 'rails'
require 'active_record'
require 'action_view'
require 'formtastic'
require 'active_admin'
require 'rspec/rails'
require 'active_support/core_ext'
# Establish test database connection
require 'active_record'
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

ENV['RAILS_ENV'] = 'test'

# Initialize test application first
module TestApp
  class Application < Rails::Application
    config.eager_load = false
    config.active_support.deprecation = :log
    config.secret_key_base = 'test_key_base'
    
    # Configure test database
    ActiveRecord::Base.establish_connection(
      adapter: 'sqlite3',
      database: ':memory:'
    )
    
    # Initialize ActionView
    config.action_view = ActiveSupport::OrderedOptions.new
    config.action_view.include_all_helpers = true
  end
end

# Require gem first to register engine initializers
require 'active_admin_dynamic_forms'

# Now initialize the Rails application
TestApp::Application.initialize!


# Initialize Formtastic
module Formtastic
  module ActionView
    module Helper
      def self.included(base)
        base.send(:include, FormHelper)
      end
    end
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Configure ActiveRecord
  config.before(:suite) do
    ActiveRecord::Base.establish_connection(
      adapter: 'sqlite3',
      database: ':memory:'
    )

    # Load and run migrations
    load File.expand_path('../db/migrate/20231201000000_create_dynamic_forms_tables.rb', __dir__)
    CreateDynamicFormsTables.new.change
  end
end