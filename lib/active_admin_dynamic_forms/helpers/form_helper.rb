module ActiveAdminDynamicForms
  module Helpers
    module FormHelper
      def dynamic_form_for(record, options = {}, &block)
        return unless record.class.respond_to?(:has_dynamic_form?) &&
                      record.dynamic_form&
                      record.dynamic_form.model_class == record.class.name
        
        form_options = options.merge(url: options[:url] || polymorphic_path(record))
        form_options[:html] ||= {}
        form_options[:html][:class] = [form_options[:html][:class], 'dynamic-form'].compact.join(' ')
        
        form_for(record, form_options) do |f|
          output = ActiveSupport::SafeBuffer.new
          
          # Add hidden fields for form association
          output << f.hidden_field(:dynamic_form_id, value: record.dynamic_form_id)
          output << f.hidden_field(:model_class, value: record.class.name)
          
          # Render each field
          record.dynamic_form.fields.order(:position).each do |field|
            field_value = record.form&.send(field.field_key)
            output << render_dynamic_field(f, field, field_value)
          end
          
          # Add submit button if not provided in block
          if block_given?
            output << capture(f, &block)
          else
            output << f.submit('Submit', class: 'btn btn-primary')
          end
          
          output
        end
      end
      
      def dynamic_form_fields(form, record)
        return unless record.respond_to?(:dynamic_form) && record.respond_to?(:dynamic_form_response)
        
        # Get available forms for this model
        available_forms = ActiveAdminDynamicForms::Models::DynamicForm.available_for_association(record.class)
        
        # Render form selection
        form.inputs "Dynamic Form" do
          form.input :dynamic_form_id, as: :select, 
                    collection: available_forms,
                    include_blank: 'No Form',
                    label: 'Select Form'
          
          # If a form is selected, render its fields
          if record.dynamic_form.present?
            render_dynamic_form_fields(form, record)
          end
        end
      end
      
      def render_dynamic_form_fields(form, record)
        return unless record.dynamic_form.present?
        
        # Initialize or get existing response
        response = record.dynamic_form_response || record.build_dynamic_form_response(dynamic_form: record.dynamic_form)
        
        # Get form data
        form_data = response.data || {}
        
        # Create a fieldset for the form fields
        form.inputs "#{record.dynamic_form.name} Fields" do
          # Add a hidden field for the response ID
          form.input :dynamic_form_response_id, as: :hidden, input_html: { value: response.id } if response.persisted?
          
          # Add fields for each form field
          record.dynamic_form.fields.order(:position).each do |field|
            field_name = "dynamic_form_responses_attributes[0][data][#{field.field_key}]"
            field_value = form_data[field.field_key]
            
            case field.field_type
            when 'text'
              form.input field_name.to_sym, label: field.label, 
                         input_html: { value: field_value, placeholder: field.placeholder },
                         required: field.required
            when 'textarea'
              form.input field_name.to_sym, as: :text, label: field.label, 
                         input_html: { value: field_value, placeholder: field.placeholder },
                         required: field.required
            when 'number'
              form.input field_name.to_sym, as: :number, label: field.label, 
                         input_html: { value: field_value, placeholder: field.placeholder },
                         required: field.required
            when 'email'
              form.input field_name.to_sym, as: :email, label: field.label, 
                         input_html: { value: field_value, placeholder: field.placeholder },
                         required: field.required
            when 'date'
              form.input field_name.to_sym, as: :date_picker, label: field.label, 
                         input_html: { value: field_value, placeholder: field.placeholder },
                         required: field.required
            when 'select'
              form.input field_name.to_sym, as: :select, label: field.label, 
                         collection: field.options.order(:position).map { |o| [o.label, o.value] },
                         selected: field_value,
                         required: field.required
            when 'radio'
              form.input field_name.to_sym, as: :radio, label: field.label, 
                         collection: field.options.order(:position).map { |o| [o.label, o.value] },
                         selected: field_value,
                         required: field.required
            when 'checkbox'
              # For checkboxes, we need to handle multiple values
              field.options.order(:position).each do |option|
                checked = field_value.is_a?(Array) && field_value.include?(option.value)
                form.input "#{field_name}[#{option.value}]", as: :boolean, 
                           label: option.label,
                           input_html: { checked: checked },
                           required: field.required && field.options.count == 1
              end
            end
          end
        end
      end
      
      def display_dynamic_form_data(record)
        return unless record.respond_to?(:dynamic_form) && record.respond_to?(:form_data)
        return unless record.dynamic_form.present? && record.form.present?
        
        panel "#{record.dynamic_form.name} Data" do
          attributes_table_for record.form do
            record.dynamic_form.fields.order(:position).each do |field|
              value = record.form_data[field.field_key]
              
              # Format the value based on field type
              formatted_value = case field.field_type
                               when 'checkbox'
                                 value.is_a?(Array) ? value.join(', ') : value
                               else
                                 value
                               end
              
              row field.label do
                formatted_value
              end
            end
          end
        end
      end
      
      private
      
      def render_dynamic_field(form, field, value)
        field_name = "form_data[#{field.field_key}]"
        field_id = "form_data_#{field.field_key}"
        field_options = {
          label: field.label,
          required: field.required,
          input_html: {
            id: field_id,
            placeholder: field.placeholder
          }
        }
        
        case field.field_type
        when 'text'
          form.input field_name, field_options.merge(as: :string, input_html: field_options[:input_html].merge(value: value))
        when 'textarea'
          form.input field_name, field_options.merge(as: :text, input_html: field_options[:input_html].merge(value: value))
        when 'number'
          form.input field_name, field_options.merge(as: :number, input_html: field_options[:input_html].merge(value: value))
        when 'email'
          form.input field_name, field_options.merge(as: :email, input_html: field_options[:input_html].merge(value: value))
        when 'date'
          form.input field_name, field_options.merge(as: :date_picker, input_html: field_options[:input_html].merge(value: value))
        when 'select'
          options = field.options.order(:position).map { |o| [o.label, o.value] }
          form.input field_name, field_options.merge(as: :select, collection: options, selected: value)
        when 'radio'
          options = field.options.order(:position).map { |o| [o.label, o.value] }
          form.input field_name, field_options.merge(as: :radio, collection: options, checked: value)
        when 'checkbox'
          options = field.options.order(:position).map { |o| [o.label, o.value] }
          form.input field_name, field_options.merge(as: :check_boxes, collection: options, checked: value)
        else
          form.input field_name, field_options.merge(as: :string, input_html: field_options[:input_html].merge(value: value))
        end
      end
    end
  end
end

# Only include the helper in ActiveAdmin if ActiveAdmin is defined
ActiveSupport.on_load(:active_admin) do
  ActiveAdmin::Views::Pages::Base.send :include, ActiveAdminDynamicForms::Helpers::FormHelper
end