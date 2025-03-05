module ActiveAdminDynamicForms
  module Models
    class DynamicFormField < ActiveRecord::Base
      self.table_name = 'dynamic_form_fields'
      
      belongs_to :form, class_name: 'ActiveAdminDynamicForms::Models::DynamicForm', foreign_key: 'dynamic_form_id'
      has_many :options, class_name: 'ActiveAdminDynamicForms::Models::DynamicFormOption', foreign_key: 'dynamic_form_field_id', dependent: :destroy
      
      validates :label, presence: true
      validates :field_type, presence: true
      validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :required, inclusion: { in: [true, false] }
      
      accepts_nested_attributes_for :options, allow_destroy: true, reject_if: :all_blank
      
      FIELD_TYPES = {
        'text' => 'Text Field',
        'textarea' => 'Text Area',
        'number' => 'Number',
        'email' => 'Email',
        'date' => 'Date',
        'select' => 'Dropdown',
        'radio' => 'Radio Buttons',
        'checkbox' => 'Checkboxes'
      }.freeze
      
      def self.field_type_options
        FIELD_TYPES.map { |value, label| [label, value] }
      end
      
      def has_options?
        %w[select radio checkbox].include?(field_type)
      end
      
      def field_key
        label.parameterize.underscore
      end
      
      # Define ransackable attributes for Active Admin
      def self.ransackable_attributes(auth_object = nil)
        ["id", "dynamic_form_id", "label", "field_type", "placeholder", "required", "position", "created_at", "updated_at"]
      end
      
      # Define ransackable associations for Active Admin
      def self.ransackable_associations(auth_object = nil)
        ["form", "options"]
      end
    end
  end
end