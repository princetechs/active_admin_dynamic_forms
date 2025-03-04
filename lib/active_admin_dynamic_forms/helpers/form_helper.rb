module ActiveAdminDynamicForms
  module Helpers
    module FormHelper
      def dynamic_form_for(record, options = {}, &block)
        return unless record.respond_to?(:dynamic_form) && record.dynamic_form
        
        form_options = options.merge(url: options[:url] || polymorphic_path(record))
        form_options[:html] ||= {}
        form_options[:html][:class] = [form_options[:html][:class], 'dynamic-form'].compact.join(' ')
        
        form_for(record, form_options) do |f|
          output = ActiveSupport::SafeBuffer.new
          
          # Add hidden field for dynamic_form_id
          output << f.hidden_field(:dynamic_form_id)
          
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

# Include the helper in ActionView::Base
ActiveSupport.on_load(:action_view) do
  include ActiveAdminDynamicForms::Helpers::FormHelper
end 