ActiveAdmin.register ActiveAdminDynamicForms::Models::DynamicForm, as: 'DynamicForm' do
  menu parent: 'Dynamic Forms'

  permit_params :name, :description, :model_class,
                fields_attributes: [:id, :label, :field_type, :required, :position, :_destroy,
                  options_attributes: [:id, :label, :value, :position, :_destroy]]

  form do |f|
    f.inputs do
      f.input :model_class, 
        as: :select,
        collection: ActiveAdminDynamicForms::HasDynamicFormMethod.registered_models.map(&:name),
        hint: 'Select which model this form should be associated with'
      f.input :name
      f.input :description
      
      f.has_many :fields, heading: 'Form Fields', allow_destroy: true do |field|
        field.input :label
        field.input :field_type, as: :select, collection: ActiveAdminDynamicForms::Models::DynamicFormField.field_type_options
        field.input :required
        field.input :position
        
        field.has_many :options, heading: 'Field Options', allow_destroy: true do |option|
          option.input :label
          option.input :value
          option.input :position
        end
      end
    end
    f.actions
  end
end