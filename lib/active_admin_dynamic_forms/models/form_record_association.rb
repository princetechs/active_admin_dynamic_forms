module ActiveAdminDynamicForms
  module Models
    class FormRecordAssociation < ActiveRecord::Base
      self.table_name = 'form_record_associations'
      
      belongs_to :dynamic_form, class_name: 'ActiveAdminDynamicForms::Models::DynamicForm'
      belongs_to :record, polymorphic: true
      
      validates :dynamic_form, presence: true
      validates :record, presence: true
      
      # Define ransackable attributes for Active Admin
      def self.ransackable_attributes(auth_object = nil)
        ["id", "dynamic_form_id", "record_type", "record_id", "created_at", "updated_at"]
      end
      
      # Define ransackable associations for Active Admin
      def self.ransackable_associations(auth_object = nil)
        ["dynamic_form", "record"]
      end
    end
  end
end 