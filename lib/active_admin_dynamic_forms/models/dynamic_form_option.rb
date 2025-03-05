module ActiveAdminDynamicForms
  module Models
    class DynamicFormOption < ActiveRecord::Base
      self.table_name = 'dynamic_form_options'
      
      belongs_to :field, class_name: 'ActiveAdminDynamicForms::Models::DynamicFormField', foreign_key: 'dynamic_form_field_id'
      
      validates :label, presence: true
      validates :value, presence: true
      validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      
      # Define ransackable attributes for Active Admin
      def self.ransackable_attributes(auth_object = nil)
        ["id", "dynamic_form_field_id", "label", "value", "position", "created_at", "updated_at"]
      end
      
      # Define ransackable associations for Active Admin
      def self.ransackable_associations(auth_object = nil)
        ["field"]
      end
    end
  end
end