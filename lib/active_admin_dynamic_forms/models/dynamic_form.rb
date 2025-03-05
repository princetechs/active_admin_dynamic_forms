module ActiveAdminDynamicForms
  module Models
    class DynamicForm < ActiveRecord::Base
      self.table_name = 'dynamic_forms'
      
      has_many :fields, class_name: 'ActiveAdminDynamicForms::Models::DynamicFormField', foreign_key: 'dynamic_form_id', dependent: :destroy
      has_many :responses, class_name: 'ActiveAdminDynamicForms::Models::DynamicFormResponse', foreign_key: 'dynamic_form_id', dependent: :destroy
      has_many :model_associations, class_name: 'ActiveAdminDynamicForms::Models::DynamicFormModelAssociation', foreign_key: 'dynamic_form_id', dependent: :destroy
      has_many :form_record_associations, class_name: 'ActiveAdminDynamicForms::Models::FormRecordAssociation', foreign_key: 'dynamic_form_id', dependent: :destroy
      
      validates :name, presence: true, uniqueness: true
      validates :description, presence: true
      validates :model_class, presence: true, if: -> { model_associations.empty? }
      
      accepts_nested_attributes_for :fields, allow_destroy: true, reject_if: :all_blank
      accepts_nested_attributes_for :model_associations, allow_destroy: true, reject_if: :all_blank
      accepts_nested_attributes_for :form_record_associations, allow_destroy: true, reject_if: :all_blank
      
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
      
      # Get all model classes this form is associated with
      def associated_model_classes
        model_associations.pluck(:model_class).uniq
      end
      
      # Legacy method to maintain backward compatibility
      def self.available_for_association(model)
        model_name = model.name
        where("model_class = ? OR id IN (SELECT dynamic_form_id FROM dynamic_form_model_associations WHERE model_class = ?)", 
              model_name, model_name).map { |form| [form.name, form.id] }
      end
      
      # Find forms applicable to a specific record
      def self.available_for_record(record)
        model_name = record.class.name
        record_id = record.id
        where("model_class = ? OR id IN (SELECT dynamic_form_id FROM dynamic_form_model_associations WHERE model_class = ? AND (associated_record_id IS NULL OR associated_record_id = ?))", 
              model_name, model_name, record_id).map { |form| [form.name, form.id] }
      end
      
      # Find forms associated with a record using the polymorphic association
      def self.associated_with_record(record)
        joins(:form_record_associations)
          .where(form_record_associations: { record_type: record.class.name, record_id: record.id })
          .distinct
          .map { |form| [form.name, form.id] }
      end
      
      # Find all forms available for a record, including both legacy and new polymorphic associations
      def self.all_available_for_record(record)
        (available_for_record(record) + associated_with_record(record)).uniq
      end
      
      def response_for(record)
        responses.find_by(record_type: record.class.name, record_id: record.id)
      end
      
      # Associate this form with a record using the polymorphic association
      def associate_with_record(record)
        form_record_associations.find_or_create_by(record: record)
      end
      
      # Remove association between this form and a record
      def disassociate_from_record(record)
        form_record_associations.where(record: record).destroy_all
      end
      
      # Define ransackable attributes for Active Admin
      def self.ransackable_attributes(auth_object = nil)
        ["id", "name", "description", "model_class", "created_at", "updated_at"]
      end
      
      # Define ransackable associations for Active Admin
      def self.ransackable_associations(auth_object = nil)
        ["fields", "responses", "model_associations", "form_record_associations"]
      end
    end
  end
end