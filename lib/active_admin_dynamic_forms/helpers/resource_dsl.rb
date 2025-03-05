module ActiveAdminDynamicForms
  module Helpers
    module ResourceDSL
      # Add dynamic forms functionality to an ActiveAdmin resource
      def has_dynamic_forms
        # Add a forms tab to the resource
        tab 'Dynamic Forms' do
          forms_tab(model_class: resource_class, record: resource)
        end
        
        # Add dynamic forms to the show page
        show do
          attributes_table do
            row :id
            rows *resource_class.column_names - ['id', 'created_at', 'updated_at']
            row :created_at
            row :updated_at
          end
          
          # Display associated dynamic forms
          dynamic_forms_for resource
        end
        
        # Add routes for form association management
        member_action :add_form, method: :post do
          form_id = params[:record][:dynamic_form_id]
          
          if form_id.present?
            form = ActiveAdminDynamicForms::Models::DynamicForm.find_by(id: form_id)
            if form
              form.associate_with_record(resource)
              flash[:notice] = "Form associated successfully."
            else
              flash[:error] = "Form not found."
            end
          else
            flash[:error] = "No form selected."
          end
          
          redirect_back(fallback_location: polymorphic_path([:admin, resource]))
        end
        
        member_action :remove_form, method: :delete do
          form_id = params[:form_id]
          
          if form_id.present?
            form = ActiveAdminDynamicForms::Models::DynamicForm.find_by(id: form_id)
            if form
              form.disassociate_from_record(resource)
              flash[:notice] = "Form association removed successfully."
            else
              flash[:error] = "Form not found."
            end
          else
            flash[:error] = "No form specified."
          end
          
          redirect_back(fallback_location: polymorphic_path([:admin, resource]))
        end
        
        # Add form selection to the edit form
        form do |f|
          f.semantic_errors
          
          f.inputs "Details" do
            f.input :dynamic_form_id, as: :dynamic_form_select, label: "Primary Form"
            f.inputs do
              resource_class.column_names.each do |column|
                next if ['id', 'created_at', 'updated_at', 'dynamic_form_id'].include?(column)
                f.input column.to_sym
              end
            end
          end
          
          f.actions
        end
      end
    end
  end
end

# Include the DSL in ActiveAdmin::DSL
ActiveAdmin::DSL.send(:include, ActiveAdminDynamicForms::Helpers::ResourceDSL) 