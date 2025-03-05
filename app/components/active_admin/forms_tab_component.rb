module ActiveAdmin
  class FormsTabComponent < ActiveAdmin::Component
    builder_method :forms_tab
    
    def build(args = {})
      @model_class = args[:model_class]
      @record = args[:record]
      
      # Skip rendering if the model class doesn't support dynamic forms
      return unless @model_class.respond_to?(:has_dynamic_form?) && @model_class.has_dynamic_form?
      
      # Get all available forms for this model class
      available_forms = ActiveAdminDynamicForms::Models::DynamicForm.where(
        "model_class = ? OR id IN (SELECT dynamic_form_id FROM dynamic_form_model_associations WHERE model_class = ?)",
        @model_class.name, @model_class.name
      )
      
      if available_forms.present?
        # Build the tab content
        div class: "forms-tab" do
          h3 "Associated Forms"
          
          if @record && @record.persisted?
            # Show existing form associations
            associated_forms = @record.specific_forms
            
            if associated_forms.present?
              table_for associated_forms do
                column "Form" do |form_data|
                  form_data[0]
                end
                column "Actions" do |form_data|
                  form_name, form_id = form_data
                  form = ActiveAdminDynamicForms::Models::DynamicForm.find_by(id: form_id)
                  
                  div do
                    if form
                      span link_to "View Form", admin_form_path(form_id)
                      span " | "
                      span link_to "Remove Association", 
                           remove_form_admin_record_path(id: @record.id, form_id: form_id),
                           method: :delete,
                           data: { confirm: "Are you sure you want to remove this form?" }
                    end
                  end
                end
              end
            else
              para "No forms associated with this record."
            end
            
            # Form to add a new association
            h4 "Add Form"
            semantic_form_for [:admin, @record], url: add_form_admin_record_path(@record), method: :post do |f|
              f.inputs do
                f.input :dynamic_form_id, 
                       label: "Select Form", 
                       as: :select, 
                       collection: available_forms.map { |form| [form.name, form.id] },
                       include_blank: "-- Select a Form --"
              end
              f.actions do
                f.action :submit, label: "Add Form"
              end
            end
          else
            para "Save the record first to associate forms."
          end
        end
      else
        para "No forms available for this model."
      end
    end
  end
end 