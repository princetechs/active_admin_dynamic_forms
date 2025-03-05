namespace :active_admin_dynamic_forms do
  desc "Check if the active_admin_dynamic_forms:install generator is properly registered"
  task :check_generator do
    begin
      require 'generators/active_admin_dynamic_forms/install/install_generator'
      puts "✅ Generator is properly registered and can be found."
      puts "You can run it with: rails generate active_admin_dynamic_forms:install"
    rescue LoadError => e
      puts "❌ Generator could not be loaded: #{e.message}"
      puts "Make sure the gem is properly installed and the generator files are in the correct location."
    end
  end
  
  desc "Run the active_admin_dynamic_forms:install generator directly"
  task :install do
    begin
      require 'generators/active_admin_dynamic_forms/install/install_generator'
      puts "Running the active_admin_dynamic_forms:install generator..."
      ActiveAdminDynamicForms::Generators::InstallGenerator.start
      puts "✅ Generator completed successfully."
    rescue => e
      puts "❌ Generator failed: #{e.message}"
      puts e.backtrace.join("\n")
      puts "Make sure the gem is properly installed and the generator files are in the correct location."
    end
  end
end 