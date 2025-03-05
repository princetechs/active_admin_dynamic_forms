class AddModelClassToDynamicForms < ActiveRecord::Migration[7.0]

  def change
    # Add the model_class column
    add_column :dynamic_forms, :model_class, :string

    # Add a check constraint to ensure model_class is not null
    add_check_constraint :dynamic_forms, "model_class IS NOT NULL", name: "dynamic_forms_model_class_null", validate: false
  end
end