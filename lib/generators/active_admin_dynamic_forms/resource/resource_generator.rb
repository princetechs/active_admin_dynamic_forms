require 'rails/generators'

module ActiveAdminDynamicForms
  module Generators
    class ResourceGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('templates', __dir__)
      
      attr_accessor :model_name, :resource_name
      
      def create_or_update_admin_resource
        if !model_exists?
          say_status :error, "Model #{file_name.camelize} does not exist. Please create it first.", :red
          return
        end
        
        if !model_includes_has_dynamic_form?
          say_status :error, "Model #{file_name.camelize} does not include has_dynamic_form. Please add it first.", :red
          return
        end
        
        # Set instance variables for the template
        @model_name = file_name.camelize
        @resource_name = file_name.underscore.humanize
        
        admin_resource_path = "app/admin/#{file_name}.rb"
        
        if File.exist?(File.join(destination_root, admin_resource_path))
          inject_into_file admin_resource_path, before: /^\s*permit_params.*$/ do
            "  # Add dynamic_form_id to permit_params\n"
          end
          
          inject_into_file admin_resource_path, after: /^\s*permit_params.*$/ do
            " :dynamic_form_id,"
          end
          
          # Find the form do |f| block
          if file_contains?(admin_resource_path, "form do |f|")
            inject_into_file admin_resource_path, after: /^\s*form do \|f\|.*$/ do
              "\n    f.inputs 'Dynamic Form' do\n      f.input :dynamic_form, as: :dynamic_form, label: 'Select a Form'\n    end\n"
            end
            
            say_status :update, "Updated #{admin_resource_path} with dynamic form selection", :green
          else
            say_status :error, "Could not find form block in #{admin_resource_path}. Please add the dynamic form selection manually.", :yellow
          end
        else
          # Use instance variables in the template
          template 'admin_resource.rb.erb', admin_resource_path
                    
          say_status :create, "Created #{admin_resource_path} with dynamic form selection", :green
        end
      end
      
      private
      
      def model_exists?
        File.exist?(File.join(destination_root, "app/models/#{file_name.underscore}.rb"))
      end
      
      def model_includes_has_dynamic_form?
        model_file = File.join(destination_root, "app/models/#{file_name.underscore}.rb")
        File.exist?(model_file) && File.read(model_file).include?('has_dynamic_form')
      end
      
      def file_contains?(file_path, text)
        full_path = File.join(destination_root, file_path)
        File.exist?(full_path) && File.read(full_path).include?(text)
      end
    end
  end
end 