module ActiveAdminDynamicForms
  module Models
    class DynamicForm < ActiveRecord::Base
      self.table_name = 'dynamic_forms'
      
      has_many :fields, class_name: 'ActiveAdminDynamicForms::Models::DynamicFormField', foreign_key: 'dynamic_form_id', dependent: :destroy
      has_many :responses, class_name: 'ActiveAdminDynamicForms::Models::DynamicFormResponse', foreign_key: 'dynamic_form_id', dependent: :destroy
      
      validates :name, presence: true, uniqueness: true
      validates :description, presence: true
      validates :model_class, presence: true
      
      accepts_nested_attributes_for :fields, allow_destroy: true, reject_if: :all_blank
      
      # Define accessor methods for model_class without checking column_names
      attr_accessor :_model_class_accessor
      
      def model_class
        # Try to get from database column first, fall back to accessor
        self[:model_class] || @_model_class_accessor
      end
      
      def model_class=(value)
        # Set both the database column and the accessor
        self[:model_class] = value
        @_model_class_accessor = value
      end
      
      def self.available_for_association(model)
        where(model_class: model.name).map { |form| [form.name, form.id] }
      end
      
      def response_for(record)
        responses.find_by(record_type: record.class.name, record_id: record.id)
      end
      
      # Define ransackable attributes for Active Admin
      def self.ransackable_attributes(auth_object = nil)
        ["id", "name", "description", "model_class", "created_at", "updated_at"]
      end
      
      # Define ransackable associations for Active Admin
      def self.ransackable_associations(auth_object = nil)
        ["fields", "responses"]
      end
    end
  end
end