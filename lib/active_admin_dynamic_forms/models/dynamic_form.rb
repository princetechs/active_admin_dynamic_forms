module ActiveAdminDynamicForms
  module Models
    class DynamicForm < ActiveRecord::Base
      self.table_name = 'dynamic_forms'
      
      has_many :fields, class_name: 'ActiveAdminDynamicForms::Models::DynamicFormField', foreign_key: 'dynamic_form_id', dependent: :destroy
      has_many :responses, class_name: 'ActiveAdminDynamicForms::Models::DynamicFormResponse', foreign_key: 'dynamic_form_id', dependent: :destroy
      
      validates :name, presence: true, uniqueness: true
      validates :description, presence: true
      
      accepts_nested_attributes_for :fields, allow_destroy: true, reject_if: :all_blank
      
      def self.available_for_association
        all.map { |form| [form.name, form.id] }
      end
      
      def response_for(record)
        responses.find_by(record_type: record.class.name, record_id: record.id)
      end
      
      # Define ransackable attributes for Active Admin
      def self.ransackable_attributes(auth_object = nil)
        ["id", "name", "description", "created_at", "updated_at"]
      end
      
      # Define ransackable associations for Active Admin
      def self.ransackable_associations(auth_object = nil)
        ["fields", "responses"]
      end
    end
  end
end 