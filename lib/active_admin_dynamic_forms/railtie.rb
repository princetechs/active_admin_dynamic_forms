require 'rails/railtie'

module ActiveAdminDynamicForms
  class Railtie < Rails::Railtie
    generators do
      require File.expand_path('../../../rails/generators/active_admin_dynamic_forms/install/install_generator', __FILE__)
    end
  end
end 