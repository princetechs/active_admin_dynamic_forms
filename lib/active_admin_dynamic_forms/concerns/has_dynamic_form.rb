module ActiveAdminDynamicForms
  module Concerns
    module HasDynamicForm
      extend ActiveSupport::Concern
      
      included do
        has_many :dynamic_form_responses, 
                 as: :record, 
                 class_name: 'ActiveAdminDynamicForms::Models::DynamicFormResponse',
                 dependent: :destroy
        
        has_one :dynamic_form_response,
                -> { order(created_at: :desc) },
                as: :record,
                class_name: 'ActiveAdminDynamicForms::Models::DynamicFormResponse'
        
        # New polymorphic association
        has_many :form_record_associations,
                 as: :record,
                 class_name: 'ActiveAdminDynamicForms::Models::FormRecordAssociation',
                 dependent: :destroy
        
        has_many :dynamic_forms,
                 through: :form_record_associations,
                 class_name: 'ActiveAdminDynamicForms::Models::DynamicForm'
        
        # Keep the belongs_to association for backward compatibility
        # but make it optional for all models
        if self.column_names.include?('dynamic_form_id')
          belongs_to :dynamic_form,
                    class_name: 'ActiveAdminDynamicForms::Models::DynamicForm',
                    optional: true
        else
          # If the column doesn't exist, define a method to access the first dynamic form
          define_method :dynamic_form do
            dynamic_forms.first
          end
          
          define_method :dynamic_form_id do
            dynamic_form&.id
          end
          
          define_method :dynamic_form_id= do |value|
            if value.present?
              form = ActiveAdminDynamicForms::Models::DynamicForm.find_by(id: value)
              form.associate_with_record(self) if form
            else
              form_record_associations.destroy_all
            end
          end
          
          # Add a ransacker for dynamic_form_id to support filtering in Active Admin
          # This needs to be added in the class level
          self.class_eval do
            ransacker :dynamic_form_id do
              Arel.sql("(SELECT form_id FROM #{ActiveAdminDynamicForms::Models::FormRecordAssociation.table_name} 
                        WHERE record_type = '#{self.name}' AND record_id = #{self.table_name}.id LIMIT 1)")
            end
          end
        end
        
        accepts_nested_attributes_for :dynamic_form_responses, allow_destroy: true
        accepts_nested_attributes_for :form_record_associations, allow_destroy: true
        
        after_save :create_or_update_form_responses
        
        # Define ransackable associations for Active Admin
        def self.ransackable_associations(auth_object = nil)
          ["dynamic_form_responses", "dynamic_form_response", "dynamic_forms", "form_record_associations"] + 
          (column_names.include?('dynamic_form_id') ? ["dynamic_form"] : []) +
          (super rescue [])
        end
        
        # Register this model with the HasDynamicFormMethod module
        ActiveAdminDynamicForms::HasDynamicFormMethod.register_model(self)
      end
      
      def create_or_update_form_responses
        # Process forms from polymorphic associations first
        dynamic_forms.each do |form|
          # Find existing response or build a new one
          response = dynamic_form_responses.find_or_initialize_by(
            dynamic_form_id: form.id
          )
          
          # Set the record association properly
          response.record = self
          
          # Preserve existing data if present
          response.data ||= {}
          
          # Save the response
          response.save!
        end
        
        # For backward compatibility, also process the primary form if set
        if respond_to?(:dynamic_form_id) && dynamic_form_id.present?
          # Simply return if no dynamic form is associated
          return if dynamic_form_id.nil?
          
          # Find existing response or build a new one
          response = dynamic_form_responses.find_or_initialize_by(
            dynamic_form_id: dynamic_form_id
          )
          
          # Set the record association properly
          response.record = self
          
          # Preserve existing data if present
          response.data ||= {}
          
          # Save the response
          response.save!
        end
      end
      
      def form
        dynamic_form_response
      end
      
      def form_data
        dynamic_form_response&.data || {}
      end
      
      def form_data=(data)
        build_dynamic_form_response unless dynamic_form_response
        dynamic_form_response.data = data
      end
      
      # Get all forms available for this model
      def available_forms
        ActiveAdminDynamicForms::Models::DynamicForm.all_available_for_record(self)
      end
      
      # Get all forms specifically assigned to this record
      def specific_forms
        # Find forms associated through polymorphic association
        forms = ActiveAdminDynamicForms::Models::DynamicForm.associated_with_record(self)
        
        # For backward compatibility, also include forms from model associations
        model_name = self.class.name
        record_id = self.id
        
        legacy_forms = ActiveAdminDynamicForms::Models::DynamicForm
                      .joins(:model_associations)
                      .where(
                        dynamic_form_model_associations: {
                          model_class: model_name, 
                          associated_record_id: record_id
                        }
                      )
                      .distinct
                      .map { |form| [form.name, form.id] }
        
        # For backward compatibility, also include the primary form if set
        if respond_to?(:dynamic_form_id) && dynamic_form_id.present?
          primary_form = ActiveAdminDynamicForms::Models::DynamicForm.find_by(id: dynamic_form_id)
          legacy_forms << [primary_form.name, primary_form.id] if primary_form && !legacy_forms.any? { |f| f[1] == primary_form.id }
        end
        
        (forms + legacy_forms).uniq
      end
      
      # Add a form to this record using the polymorphic association
      def add_form(form)
        form.associate_with_record(self) if form
      end
      
      # Remove a form from this record
      def remove_form(form)
        form.disassociate_from_record(self) if form
      end
    end
  end
  
  # Define the module before using it
  module HasDynamicFormMethod
    @registered_models = []
    
    class << self
      attr_reader :registered_models
      
      def register_model(model_class)
        @registered_models << model_class.name unless @registered_models.include?(model_class.name)
      end
      
      def model_names
        @registered_models
      end
    end

    def has_dynamic_form
      include ActiveAdminDynamicForms::Concerns::HasDynamicForm
    end
  end
end

# Extend ActiveRecord::Base to include the has_dynamic_form method
ActiveSupport.on_load(:active_record) do
  extend ActiveAdminDynamicForms::HasDynamicFormMethod
end