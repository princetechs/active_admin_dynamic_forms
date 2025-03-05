class DynamicFormSelectInput < Formtastic::Inputs::SelectInput
  def to_html
    input_wrapping do
      label_html <<
      builder.collection_select(
        input_name, 
        collection, 
        value_method, 
        label_method, 
        input_options, 
        input_html_options
      )
    end
  end
  
  private
  
  def collection
    @collection ||= begin
      forms = object.respond_to?(:available_forms) ? object.available_forms : []
      forms = ActiveAdminDynamicForms::Models::DynamicForm.all.map { |form| [form.name, form.id] } if forms.empty?
      forms
    end
  end
  
  def input_name
    :dynamic_form_id
  end
  
  def value_method
    :last
  end
  
  def label_method
    :first
  end
end 