module ActiveAdminDynamicForms
  class Engine < ::Rails::Engine
    isolate_namespace ActiveAdminDynamicForms

    config.eager_load_namespaces << ActiveAdminDynamicForms
    
    config.autoload_paths << File.expand_path('models', __dir__)
    
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
      end
    end

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end
    
    initializer 'active_admin_dynamic_forms.zeitwerk_compatibility', before: :set_autoload_paths do |app|
      # Tell Zeitwerk to ignore our models directory
      app.config.zeitwerk_enabled = true
      Rails.autoloaders.main.ignore(File.expand_path('models', __dir__)) if Rails.autoloaders.respond_to?(:main)
    end
  end
end