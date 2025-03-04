class CreateActiveAdminDynamicFormsTables < ActiveRecord::Migration[6.0]
  def change
    create_table :dynamic_forms do |t|
      t.string :name, null: false
      t.text :description
      t.timestamps
    end
    
    add_index :dynamic_forms, :name, unique: true
    
    create_table :dynamic_form_fields do |t|
      t.references :dynamic_form, null: false, foreign_key: true
      t.string :label, null: false
      t.string :field_type, null: false
      t.string :placeholder
      t.boolean :required, default: false
      t.integer :position, default: 0
      t.timestamps
    end
    
    create_table :dynamic_form_options do |t|
      t.references :dynamic_form_field, null: false, foreign_key: true
      t.string :label, null: false
      t.string :value, null: false
      t.integer :position, default: 0
      t.timestamps
    end
    
    create_table :dynamic_form_responses do |t|
      t.references :dynamic_form, null: false, foreign_key: true
      t.references :record, polymorphic: true, null: false
      t.json :data, default: {}
      t.timestamps
    end
    
    add_index :dynamic_form_responses, [:record_type, :record_id, :dynamic_form_id], unique: true, name: 'index_dynamic_form_responses_on_record_and_form'
  end
end 