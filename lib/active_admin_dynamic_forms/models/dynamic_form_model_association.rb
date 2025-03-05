module ActiveAdminDynamicForms
  module Models
    class DynamicFormModelAssociation < ActiveRecord::Base
      self.table_name = 'dynamic_form_model_associations'
      
      belongs_to :form, class_name: 'ActiveAdminDynamicForms::Models::DynamicForm', foreign_key: 'dynamic_form_id'
      
      validates :model_class, presence: true
      
      # Define ransackable attributes for Active Admin
      def self.ransackable_attributes(auth_object = nil)
        ["id", "dynamic_form_id", "model_class", "associated_record_id", "created_at", "updated_at"]
      end
      
      # Define ransackable associations for Active Admin
      def self.ransackable_associations(auth_object = nil)
        ["form"]
      end
    end
  end
end 