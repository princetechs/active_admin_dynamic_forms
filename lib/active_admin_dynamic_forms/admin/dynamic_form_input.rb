module ActiveAdminDynamicForms
  module Admin
    class DynamicFormInput < ::Formtastic::Inputs::SelectInput
      def input_html_options
        super.merge(
          data: {
            dynamic_form_input: true
          }
        )
      end
      
      def collection
        record = @object
        if record && record.respond_to?(:available_forms)
          record.available_forms
        else
          model_name = @object.class.name
          ActiveAdminDynamicForms::Models::DynamicForm
            .where("model_class = ? OR id IN (SELECT dynamic_form_id FROM dynamic_form_model_associations WHERE model_class = ?)", 
                  model_name, model_name)
            .map { |form| [form.name, form.id] }
        end
      end
    end
  end
end 