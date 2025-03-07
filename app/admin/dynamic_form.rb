# This file was generated by the active_admin_dynamic_forms:install generator.
# You can customize it to your needs.

ActiveAdmin.register ActiveAdminDynamicForms::Models::DynamicForm, as: 'Form' do
  menu label: 'Dynamic Forms', priority: 100
  
  permit_params :name, :description, :model_class,
                fields_attributes: [:id, :label, :field_type, :placeholder, :required, :position, :_destroy,
                                   options_attributes: [:id, :label, :value, :position, :_destroy]]
  
  index do
    selectable_column
    id_column
    column :name
    column :description
    column :model_class
    column :created_at
    column :updated_at
    column 'Fields' do |form|
      form.fields.count
    end
    actions
  end
  
  show do
    attributes_table do
      row :id
      row :name
      row :description
      row :model_class
      row :created_at
      row :updated_at
    end
    
    panel 'Fields' do
      table_for resource.fields.order(:position) do
        column :position
        column :label
        column :field_type do |field|
          ActiveAdminDynamicForms::Models::DynamicFormField::FIELD_TYPES[field.field_type]
        end
        column :required
        column :placeholder
        column 'Options' do |field|
          if field.has_options?
            ul do
              field.options.order(:position).each do |option|
                li "#{option.label} (#{option.value})"
              end
            end
          else
            span 'N/A'
          end
        end
      end
    end
  end
  
  form do |f|
    f.inputs 'Form Details' do
      f.input :name
      f.input :description
      
      # Get all models that have included has_dynamic_form
      available_models = ActiveAdminDynamicForms::HasDynamicFormMethod.model_names
      
      # Create a select input for model_class
      f.input :model_class, as: :select, 
              collection: available_models,
              include_blank: false,
              hint: 'Select the model this form will be associated with'
    end
    
    f.inputs 'Fields' do
      f.has_many :fields, sortable: :position, sortable_start: 1, allow_destroy: true, new_record: true do |field|
        field.input :label
        field.input :field_type, as: :select, collection: ActiveAdminDynamicForms::Models::DynamicFormField.field_type_options
        field.input :placeholder
        field.input :required
        field.input :position, as: :hidden
        
        # Only show options for field types that support them
        field.has_many :options, sortable: :position, sortable_start: 1, allow_destroy: true, new_record: true,
                      heading: 'Options (for Select, Radio, and Checkbox fields only)' do |option|
          option.input :label
          option.input :value
          option.input :position, as: :hidden
        end
      end
    end
    
    f.actions
  end
  
  controller do
    def find_resource
      ActiveAdminDynamicForms::Models::DynamicForm.find(params[:id])
    end
  end
end 