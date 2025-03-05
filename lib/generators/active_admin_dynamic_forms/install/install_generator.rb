require 'rails/generators'
require 'rails/generators/migration'
require 'active_record'

module ActiveAdminDynamicForms
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      source_root File.expand_path('templates', __dir__)
      
      def self.next_migration_number(dirname)
        next_migration_number = current_migration_number(dirname) + 1
        ActiveRecord::Migration.next_migration_number(next_migration_number)
      end
      
      def create_migrations
        # Check if migrations already exist
        main_migration_exists = migration_exists?('create_active_admin_dynamic_forms_tables')
        model_class_migration_exists = migration_exists?('add_model_class_to_dynamic_forms')
        placeholder_migration_exists = migration_exists?('add_placeholder_to_dynamic_form_fields')
        
        if main_migration_exists
          say_status :skip, "Main migration already exists", :yellow
        else
          migration_template 'create_active_admin_dynamic_forms_tables.rb', 'db/migrate/create_active_admin_dynamic_forms_tables.rb'
          say_status :create, "Created main migration", :green
        end
        
        # Add a separate migration for adding model_class to existing installations
        # This is only needed for users upgrading from an older version
        if model_class_migration_exists
          say_status :skip, "Model class migration already exists", :yellow
        else
          migration_template 'add_model_class_to_dynamic_forms.rb', 'db/migrate/add_model_class_to_dynamic_forms.rb'
          say_status :create, "Created model class migration", :green
        end
        
        # Add a separate migration for adding placeholder to dynamic_form_fields
        # This is needed for users upgrading from an older version
        if placeholder_migration_exists
          say_status :skip, "Placeholder migration already exists", :yellow
        else
          migration_template 'add_placeholder_to_dynamic_form_fields.rb', 'db/migrate/add_placeholder_to_dynamic_form_fields.rb'
          say_status :create, "Created placeholder migration", :green
        end
      end
      
      def create_initializer
        initializer_path = 'config/initializers/active_admin_dynamic_forms.rb'
        if File.exist?(File.join(destination_root, initializer_path))
          say_status :skip, "Initializer already exists", :yellow
        else
          template 'initializer.rb', initializer_path
          say_status :create, "Created initializer", :green
        end
      end
      
      def create_admin_resource
        admin_resource_path = 'app/admin/dynamic_form.rb'
        if File.exist?(File.join(destination_root, admin_resource_path))
          say_status :skip, "Admin resource already exists", :yellow
        else
          template 'dynamic_form.rb', admin_resource_path
          say_status :create, "Created admin resource", :green
        end
      end
      
      def mount_engine
        if routes_contain?("mount ActiveAdminDynamicForms::Engine")
          say_status :skip, "Engine already mounted in routes", :yellow
        else
          route "mount ActiveAdminDynamicForms::Engine => '/active_admin_dynamic_forms'"
          say_status :route, "Mounted engine in routes", :green
        end
      end
      
      def add_assets
        manifest_path = 'app/assets/config/manifest.js'
        if File.exist?(File.join(destination_root, manifest_path))
          if file_contains?(manifest_path, "active_admin_dynamic_forms/admin")
            say_status :skip, "Assets already added to manifest", :yellow
          else
            inject_into_file manifest_path, after: "//= link_directory ../stylesheets .css\n" do
              "//= link active_admin_dynamic_forms/admin.css\n//= link active_admin_dynamic_forms/admin.js\n"
            end
            say_status :insert, "Added assets to manifest", :green
          end
        else
          say_status :error, "Manifest file not found. Skipping asset registration.", :red
        end
      end
      
      def show_readme
        readme 'README'
      end
      
      private
      
      def migration_exists?(name)
        Dir.glob("#{File.join(destination_root, 'db/migrate')}/*_#{name}.rb").any?
      end
      
      def routes_contain?(text)
        routes_file = File.join(destination_root, 'config/routes.rb')
        File.exist?(routes_file) && File.read(routes_file).include?(text)
      end
      
      def file_contains?(file_path, text)
        full_path = File.join(destination_root, file_path)
        File.exist?(full_path) && File.read(full_path).include?(text)
      end
    end
  end
end 