module ActiveAdminDynamicForms
  # This module is responsible for registering the generators
  module RegisterGenerators
    def self.register!
      # Ensure the generator is loaded
      require File.expand_path('../../../rails/generators/active_admin_dynamic_forms/install/install_generator', __FILE__)
      
      # Register the generator namespace
      if defined?(Rails::Generators)
        # The namespace should already be defined in the generator class itself
        # So we don't need to call Rails::Generators.namespace here
      end
    end
  end
end

# Register the generators
ActiveAdminDynamicForms::RegisterGenerators.register! if defined?(Rails::Generators)

module ActiveAdminDynamicForms
  class << self
    def register_generators!
      # Only register generators if we're in a Rails app
      if defined?(Rails::Generators)
        require File.expand_path('../../../rails/generators/active_admin_dynamic_forms/install/install_generator', __FILE__)
        require File.expand_path('../../../rails/generators/active_admin_dynamic_forms/resource/resource_generator', __FILE__)
      end
    end
  end
  
  # Determine if we should automatically register generators
  def self.should_register_generators?
    return false unless defined?(Rails::Generators)
    
    # Don't register generators during test runs
    return false if defined?(Rails) && Rails.env.test?
    
    true
  end
end

# Automatically register generators if appropriate
ActiveAdminDynamicForms.register_generators! if ActiveAdminDynamicForms.should_register_generators? 