class AddPlaceholderToDynamicFormFields < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:dynamic_form_fields, :placeholder)
      add_column :dynamic_form_fields, :placeholder, :string
    end
  end
end 