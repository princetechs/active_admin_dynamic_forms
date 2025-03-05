#!/usr/bin/env ruby

# This script is used to run the active_admin_dynamic_forms:install generator directly
# It can be used as an alternative to the Rails generator command

require 'rails/generators'
require 'rails/generators/migration'
require 'active_record'

# Add the lib directory to the load path
$LOAD_PATH.unshift File.expand_path('lib', __dir__)

# Require the generator
require 'generators/active_admin_dynamic_forms/install/install_generator'

# Run the generator
puts "Running the active_admin_dynamic_forms:install generator..."
ActiveAdminDynamicForms::Generators::InstallGenerator.start
puts "✅ Generator completed successfully." 