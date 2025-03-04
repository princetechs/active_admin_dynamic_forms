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
        migration_template 'create_active_admin_dynamic_forms_tables.rb', 'db/migrate/create_active_admin_dynamic_forms_tables.rb'
      end
      
      def create_initializer
        template 'initializer.rb', 'config/initializers/active_admin_dynamic_forms.rb'
      end
      
      def create_admin_resource
        template 'dynamic_form.rb', 'app/admin/dynamic_form.rb'
      end
      
      def mount_engine
        route "mount ActiveAdminDynamicForms::Engine => '/active_admin_dynamic_forms'"
      end
      
      def add_assets
        inject_into_file 'app/assets/config/manifest.js', after: "//= link_directory ../stylesheets .css\n" do
          "//= link active_admin_dynamic_forms/admin.css\n//= link active_admin_dynamic_forms/admin.js\n"
        end
      end
      
      def show_readme
        readme 'README'
      end
    end
  end
end 