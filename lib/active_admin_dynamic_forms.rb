require "active_admin_dynamic_forms/version"
require "active_admin_dynamic_forms/config"

# Load helpers first
require "active_admin_dynamic_forms/helpers/form_helper"
require "active_admin_dynamic_forms/helpers/resource_dsl"

# Load admin components
require "active_admin_dynamic_forms/admin/dynamic_form_input"

# Load concerns
require "active_admin_dynamic_forms/concerns/has_dynamic_form"

# Load engine
require "active_admin_dynamic_forms/engine"

# Load railtie
require "active_admin_dynamic_forms/railtie" if defined?(Rails::Railtie)

# Register generators
require "active_admin_dynamic_forms/register_generators" if defined?(Rails::Generators)

# Explicitly require the generator
require File.expand_path('../../rails/generators/active_admin_dynamic_forms/install/install_generator', __FILE__) if defined?(Rails::Generators)

module ActiveAdminDynamicForms
  # Initialize configuration
  self.configuration ||= Configuration.new
  
  # This will be called by the engine after ActiveRecord is initialized
  def self.load_models
    # Only load models when ActiveRecord is fully initialized
    ActiveSupport.on_load(:active_record) do
      require "active_admin_dynamic_forms/models/dynamic_form"
      require "active_admin_dynamic_forms/models/dynamic_form_field"
      require "active_admin_dynamic_forms/models/dynamic_form_response"
      require "active_admin_dynamic_forms/models/dynamic_form_option"
      require "active_admin_dynamic_forms/models/dynamic_form_model_association"
      require "active_admin_dynamic_forms/models/form_record_association"
      
      # Setup constants if needed
      ActiveAdminDynamicForms.setup_constants
    end
  end
  
  # Setup constants in a way that avoids dynamic constant assignment
  def self.setup_constants
    Object.const_set(:DynamicForm, ActiveAdminDynamicForms::Models::DynamicForm) unless Object.const_defined?(:DynamicForm)
    Object.const_set(:DynamicFormField, ActiveAdminDynamicForms::Models::DynamicFormField) unless Object.const_defined?(:DynamicFormField)
    Object.const_set(:DynamicFormResponse, ActiveAdminDynamicForms::Models::DynamicFormResponse) unless Object.const_defined?(:DynamicFormResponse)
    Object.const_set(:DynamicFormOption, ActiveAdminDynamicForms::Models::DynamicFormOption) unless Object.const_defined?(:DynamicFormOption)
    Object.const_set(:DynamicFormModelAssociation, ActiveAdminDynamicForms::Models::DynamicFormModelAssociation) unless Object.const_defined?(:DynamicFormModelAssociation)
    Object.const_set(:FormRecordAssociation, ActiveAdminDynamicForms::Models::FormRecordAssociation) unless Object.const_defined?(:FormRecordAssociation)
  end
  
  # Define a method to add the migration for polymorphic form associations
  def self.create_form_record_associations_migration
    require File.expand_path('../../rails/generators/active_admin_dynamic_forms/install/templates/create_form_record_associations', __FILE__)
    CreateFormRecordAssociations.new.change
  end
  
  # Define a method to register custom inputs
  def self.register_custom_inputs
    # Ensure the DynamicFormSelectInput is available
    Formtastic::Inputs.send(:autoload, :DynamicFormSelectInput, 'app/inputs/dynamic_form_select_input')
  end
end

# Load models after ActiveRecord is initialized
ActiveAdminDynamicForms.load_models

# The to_prepare block should be moved to the engine initializer
# to ensure Rails.application is available when this code runs
# Removed from here:
# if defined?(Rails::Engine)
#   Rails.application.config.to_prepare do
#     ActiveAdminDynamicForms.register_custom_inputs if defined?(Formtastic::Inputs)
#   end
# end