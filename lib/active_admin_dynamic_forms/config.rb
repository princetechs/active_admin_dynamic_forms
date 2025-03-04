module ActiveAdminDynamicForms
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration) if block_given?
  end

  class Configuration
    attr_accessor :form_class_name
    attr_accessor :field_class_name
    attr_accessor :option_class_name
    attr_accessor :response_class_name

    def initialize
      @form_class_name = 'ActiveAdminDynamicForms::Models::DynamicForm'
      @field_class_name = 'ActiveAdminDynamicForms::Models::DynamicFormField'
      @option_class_name = 'ActiveAdminDynamicForms::Models::DynamicFormOption'
      @response_class_name = 'ActiveAdminDynamicForms::Models::DynamicFormResponse'
    end
  end
end 