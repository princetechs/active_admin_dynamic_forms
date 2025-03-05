module ActiveAdminDynamicForms
  # This module is responsible for registering the generators
  module RegisterGenerators
    def self.register!
      # Ensure the generator is loaded
      require File.expand_path('../../generators/active_admin_dynamic_forms/install/install_generator', __dir__)
      
      # Register the generator namespace
      if defined?(Rails::Generators)
        Rails::Generators.namespace(
          ActiveAdminDynamicForms::Generators,
          path: File.expand_path('../../generators', __dir__),
          namespace: 'active_admin_dynamic_forms'
        )
      end
    end
  end
end

# Register the generators
ActiveAdminDynamicForms::RegisterGenerators.register! if defined?(Rails::Generators) 