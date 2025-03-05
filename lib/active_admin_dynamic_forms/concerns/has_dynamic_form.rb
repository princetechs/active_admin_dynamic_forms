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
        
        belongs_to :dynamic_form,
                   class_name: 'ActiveAdminDynamicForms::Models::DynamicForm',
                   optional: true
        
        accepts_nested_attributes_for :dynamic_form_responses, allow_destroy: true
        
        after_save :create_or_update_form_response
        
        # Define ransackable associations for Active Admin
        def self.ransackable_associations(auth_object = nil)
          ["dynamic_form_responses", "dynamic_form_response", "dynamic_form"] + (super rescue [])
        end
      end
      
      def create_or_update_form_response
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
    end
  end
  
  # Define the module before using it
  module HasDynamicFormMethod
    def has_dynamic_form
      include ActiveAdminDynamicForms::Concerns::HasDynamicForm
    end
  end
end

# Extend ActiveRecord::Base to include the has_dynamic_form method
ActiveSupport.on_load(:active_record) do
  extend ActiveAdminDynamicForms::HasDynamicFormMethod
end