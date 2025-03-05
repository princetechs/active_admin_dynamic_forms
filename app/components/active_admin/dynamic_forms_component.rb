module ActiveAdmin
  class DynamicFormsComponent < ActiveAdmin::Component
    builder_method :dynamic_forms_for
    
    def build(record)
      @record = record
      
      # Skip rendering if the record doesn't support dynamic forms
      return unless @record.class.respond_to?(:has_dynamic_form?) && @record.class.has_dynamic_form?
      
      # Get all forms associated with this record
      forms = @record.specific_forms
      
      if forms.present?
        h3 "Dynamic Forms"
        
        div class: "dynamic-forms-container" do
          forms.each do |form_name, form_id|
            dynamic_form = ActiveAdminDynamicForms::Models::DynamicForm.find_by(id: form_id)
            
            next unless dynamic_form
            
            div class: "dynamic-form-container" do
              h4 form_name
              
              # Display form responses if they exist
              response = dynamic_form.response_for(@record)
              
              if response&.data.present?
                table_for dynamic_form.fields.order(:position) do
                  column "Question" do |field|
                    field.label
                  end
                  column "Answer" do |field|
                    format_response(response.data[field.id.to_s], field)
                  end
                end
              else
                para "No responses yet."
                
                # Add link to edit form responses
                para link_to "Add Responses", 
                      polymorphic_path([:edit, :admin, @record], anchor: "dynamic-form-#{form_id}"),
                      class: "button"
              end
            end
          end
        end
      else
        para "No dynamic forms associated with this record."
      end
    end
    
    private
    
    def format_response(value, field)
      return "Not provided" if value.blank?
      
      case field.field_type
      when "checkbox"
        value.is_a?(Array) ? value.join(", ") : value.to_s
      when "select", "radio"
        option = field.options.find_by(value: value)
        option ? option.label : value.to_s
      when "date"
        begin
          Date.parse(value).strftime("%m/%d/%Y")
        rescue
          value.to_s
        end
      else
        value.to_s
      end
    end
  end
end 