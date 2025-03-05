class AddModelClassToDynamicForms < ActiveRecord::Migration[6.0]
  def change
    unless column_exists?(:dynamic_forms, :model_class)
      add_column :dynamic_forms, :model_class, :string
    end
    
    # Make it nullable initially
    # After you set values for existing records, you can make it NOT NULL if needed
  end
end 