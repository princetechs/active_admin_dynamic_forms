module ActiveAdminDynamicForms
  class Engine < ::Rails::Engine
    isolate_namespace ActiveAdminDynamicForms
    
    initializer 'active_admin_dynamic_forms.setup' do |app|
      ActiveAdmin.setup do |config|
        config.register_stylesheet 'active_admin_dynamic_forms/admin.css'
        config.register_javascript 'active_admin_dynamic_forms/admin.js'
      end if defined?(ActiveAdmin)
    end
    
    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end
  end
end 