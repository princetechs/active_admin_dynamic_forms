module ActiveAdminDynamicForms
  module Models
    class DynamicFormResponse < ActiveRecord::Base
      self.table_name = 'dynamic_form_responses'
      
      belongs_to :form, class_name: 'ActiveAdminDynamicForms::Models::DynamicForm', foreign_key: 'dynamic_form_id'
      belongs_to :record, polymorphic: true, optional: true
      
      serialize :data
      
      validates :dynamic_form_id, presence: true
      
      # Define ransackable attributes for Active Admin
      def self.ransackable_attributes(auth_object = nil)
        ["id", "dynamic_form_id", "record_id", "record_type", "data", "created_at", "updated_at"]
      end
      
      # Define ransackable associations for Active Admin
      def self.ransackable_associations(auth_object = nil)
        ["form", "record"]
      end
      
      def method_missing(method_name, *arguments, &block)
        if data.present? && data.key?(method_name.to_s)
          data[method_name.to_s]
        else
          super
        end
      end
      
      def respond_to_missing?(method_name, include_private = false)
        (data.present? && data.key?(method_name.to_s)) || super
      end
      
      def fields
        data
      end
      
      # Override the record= method to ensure record_type is set properly
      def record=(record)
        self.record_id = record.try(:id)
        self.record_type = record.try(:class).try(:name)
        @record = record
      end
    end
  end
end