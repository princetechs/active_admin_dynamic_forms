ActiveAdmin.register Job do
  # Specify which parameters can be modified through the admin interface
  permit_params :user_id, :title, :job_description, :location, :company_info,
                :employment_type, :experience_level, :salary_range, :required_skills,
                :screening_questions, :status, :application_deadline,
                dynamic_form_responses_attributes: [:id, :dynamic_form_id, :_destroy, {data: {}}]

  # Index page customization
  index do
    selectable_column
    id_column
    column :title
    column :location
    column :employment_type
    column :status
    column :application_deadline
    column :user
    column "Dynamic Form" do |job|
      if job.dynamic_form
        link_to job.dynamic_form.name, admin_form_path(job.dynamic_form)
      else
        "None"
      end
    end
    column :created_at
    actions
  end

  # Filter options in the sidebar
  filter :title
  filter :location
  filter :employment_type
  filter :status, as: :select, collection: Job.statuses
  filter :application_deadline
  filter :user
  filter :created_at

  # Form for creating/editing jobs
  form do |f|
    f.inputs "Job Details" do
      f.input :title
      f.input :job_description
      f.input :location
      f.input :company_info
      f.input :status, as: :select, collection: Job.statuses.keys
    end
    
    f.inputs "Dynamic Form" do
      f.has_many :dynamic_form_responses, new_record: 'Link Form', allow_destroy: true do |df|
        df.input :dynamic_form_id, as: :select, 
          collection: ActiveAdminDynamicForms::Models::DynamicForm.available_for_association(Job),
          hint: 'Select form specific to Job model'
        
        if df.object.persisted? && df.object.form.present?
          df.object.form.fields.order(:position).each do |field|
            field_name = "dynamic_form_responses_attributes[#{df.index}][data][#{field.field_key}]"
            field_value = df.object.data[field.field_key] if df.object.data.present?
            field_value = df.object.data[field.label] if df.object.data.present?
            
            case field.field_type
            when 'text'
              f.input field_name, label: field.label, input_html: { value: field_value }, as: :string, required: field.required
            when 'textarea'
              f.input field_name, label: field.label, input_html: { value: field_value }, as: :text, required: field.required
            when 'number'
              f.input field_name, label: field.label, input_html: { value: field_value }, as: :number, required: field.required
            when 'email'
              f.input field_name, label: field.label, input_html: { value: field_value }, as: :email, required: field.required
            when 'date'
              f.input field_name, label: field.label, input_html: { value: field_value }, as: :date_picker, required: field.required
            when 'select'
              f.input field_name, label: field.label, 
                     as: :select, 
                     collection: field.options.map { |o| [o.label, o.value] },
                     selected: field_value,
                     required: field.required
            when 'radio'
              f.input field_name, label: field.label, 
                     as: :radio, 
                     collection: field.options.map { |o| [o.label, o.value] },
                     selected: field_value,
                     required: field.required
            when 'checkbox'
              field.options.each do |option|
                checked = field_value.is_a?(Array) && field_value.include?(option.value)
                f.input "#{field_name}[#{option.value}]", 
                       label: option.label, 
                       as: :boolean,
                       checked: checked
              end
            end
          end
        end
      end
    end
    
    f.actions
  end
  
  # Show page customization
  show do
    attributes_table do
      row :id
      row :title
      row :job_description
      row :location
      row :company_info
      row :employment_type
      row :experience_level
      row :salary_range
      row :required_skills
      row :screening_questions
      row :status
      row :application_deadline
      row :user
      row :created_at
      row :updated_at
    end
    
    if resource.dynamic_form_response.present?
      panel "Dynamic Form Response: #{resource.dynamic_form.name}" do
        attributes_table_for resource.dynamic_form_response do
          resource.form_data.each do |key, value|
            row field.label do
              if value.is_a?(Array)
                ul do
                  value.each do |v|
                    li v
                  end
                end
              else
                value
              end
            end
          end
    # Show dynamic form responses if present
    if resource.form.present?
      panel "Dynamic Form Responses" do
        attributes_table_for resource.form do
          resource.dynamic_form.fields.order(:position).each do |field|
            row field.label do
              resource.form.send(field.field_key)
            end
          end
        end
      end
    end

    # Show dynamic form responses if present
    if resource.form.present?
      panel "Dynamic Form Responses" do
        attributes_table_for resource.form do
          resource.dynamic_form.fields.order(:position).each do |field|
            row field.label do
              resource.form.send(field.field_key)
            end
          end
        end
      end
    end
    
    active_admin_comments
  end
end