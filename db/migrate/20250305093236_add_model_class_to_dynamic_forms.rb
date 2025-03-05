class AddModelClassToDynamicForms < ActiveRecord::Migration[7.0]
  def change
    # This migration is empty because the model_class column already exists
    # in the dynamic_forms table from the previous migration.
    # We're keeping this file to maintain compatibility with existing installations.
  end
end 