module ActiveAdminDynamicForms
  class Engine < ::Rails::Engine
    isolate_namespace ActiveAdminDynamicForms

    config.eager_load_namespaces << ActiveAdminDynamicForms
    
    config.autoload_paths << File.expand_path('models', __dir__)
    config.autoload_paths << File.expand_path('admin', __dir__)
    config.autoload_paths << File.expand_path('../../app/inputs', __dir__)
    config.autoload_paths << File.expand_path('../../app/components', __dir__)
    
    # Ensure generators are properly registered
    config.paths["lib/generators"] = File.expand_path("../../generators", __dir__)
    
    # Explicitly register the generator path
    initializer "active_admin_dynamic_forms.register_generators", before: :load_config_initializers do |app|
      if defined?(Rails::Generators)
        Rails::Generators.configure!(app.config.generators)
        Rails::Generators.hidden_namespaces.reject! { |namespace| namespace.to_s.start_with?("active_admin_dynamic_forms") }
      end
    end

    initializer 'active_admin_dynamic_forms.setup', after: 'active_admin.setup' do |app|
      if defined?(ActiveAdmin)
        ActiveAdmin.setup do |config|
          config.register_stylesheet 'active_admin_dynamic_forms/admin.css'
          config.register_javascript 'active_admin_dynamic_forms/admin.js'
        end
        
        # Include our helper in ActiveAdmin
        ActiveAdmin::Views::Pages::Base.send :include, ActiveAdminDynamicForms::Helpers::FormHelper if defined?(ActiveAdmin::Views::Pages::Base)
        
        # Register our custom input with Formtastic
        Formtastic::Inputs.send :autoload, :DynamicFormInput, 'active_admin_dynamic_forms/admin/dynamic_form_input'
        Formtastic::Inputs.send :autoload, :DynamicFormSelectInput, 'app/inputs/dynamic_form_select_input'
        ::Formtastic::Inputs.send :include, ActiveAdminDynamicForms::Admin
        
        # Register our custom components with ActiveAdmin
        ActiveAdmin::Views::Pages::Show.send :include, ActiveAdmin if defined?(ActiveAdmin::Views::Pages::Show)
        ActiveAdmin::Views::Tabs.send :include, ActiveAdmin if defined?(ActiveAdmin::Views::Tabs)
      end
    end

    # Add initialization hook for custom inputs
    initializer 'active_admin_dynamic_forms.register_custom_inputs' do |app|
      app.config.to_prepare do
        ActiveAdminDynamicForms.register_custom_inputs if defined?(Formtastic::Inputs)
      end
    end

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end
    
    # Changed to remove any after dependencies to fix circular initialization
    initializer 'active_admin_dynamic_forms.zeitwerk_compatibility', before: :set_autoload_paths do |app|
      # Tell Zeitwerk to ignore our models directory
      app.config.zeitwerk_enabled = true
      Rails.autoloaders.main.ignore(File.expand_path('models', __dir__)) if Rails.autoloaders.respond_to?(:main)
      Rails.autoloaders.main.ignore(File.expand_path('admin', __dir__)) if Rails.autoloaders.respond_to?(:main)
      Rails.autoloaders.main.ignore(File.expand_path('../../app/inputs', __dir__)) if Rails.autoloaders.respond_to?(:main)
      Rails.autoloaders.main.ignore(File.expand_path('../../app/components', __dir__)) if Rails.autoloaders.respond_to?(:main)
    end
  end
end