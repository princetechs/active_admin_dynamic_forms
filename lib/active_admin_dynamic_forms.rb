require "active_admin_dynamic_forms/version"
require "active_admin_dynamic_forms/config"

# Load helpers first
require "active_admin_dynamic_forms/helpers/form_helper"

# Load concerns
require "active_admin_dynamic_forms/concerns/has_dynamic_form"

# Load engine
require "active_admin_dynamic_forms/engine"

# Load railtie
require "active_admin_dynamic_forms/railtie" if defined?(Rails::Railtie)

# Register generators
require "active_admin_dynamic_forms/register_generators" if defined?(Rails::Generators)

# Explicitly require the generator
require File.expand_path('../generators/active_admin_dynamic_forms/install/install_generator', __dir__) if defined?(Rails::Generators)

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
  end
end

# Load models after ActiveRecord is initialized
ActiveAdminDynamicForms.load_models