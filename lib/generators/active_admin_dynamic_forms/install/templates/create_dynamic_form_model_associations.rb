class CreateDynamicFormModelAssociations < ActiveRecord::Migration[7.0]
  def change
    create_table :dynamic_form_model_associations do |t|
      t.references :dynamic_form, null: false, foreign_key: true
      t.string :model_class, null: false
      t.integer :associated_record_id
      t.timestamps
    end
    
    # Add index for faster lookups
    add_index :dynamic_form_model_associations, [:model_class, :associated_record_id], 
              name: "index_dynamic_form_model_associations_on_model_and_record"
              
    # Add unique index to prevent duplicate associations
    add_index :dynamic_form_model_associations, [:dynamic_form_id, :model_class, :associated_record_id], 
              unique: true,
              name: "index_unique_dynamic_form_model_associations"
  end
end 