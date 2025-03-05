class CreateActiveAdminDynamicFormsTables < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    # Create dynamic_forms table if it doesn't exist
    unless table_exists?(:dynamic_forms)
      create_table :dynamic_forms do |t|
        t.string :name, null: false
        t.text :description
        t.string :model_class, null: false
        t.timestamps
      end

      # Add the index concurrently
      add_index :dynamic_forms, :name, unique: true, name: "index_dynamic_forms_on_name", algorithm: :concurrently
    end

    # Create dynamic_form_fields table if it doesn't exist
    unless table_exists?(:dynamic_form_fields)
      create_table :dynamic_form_fields do |t|
        t.references :dynamic_form, null: false, foreign_key: true
        t.string :label, null: false
        t.string :field_type, null: false
        t.integer :position, null: false
        t.boolean :required, default: false
        t.timestamps
      end
    end

    # Create dynamic_form_options table if it doesn't exist
    unless table_exists?(:dynamic_form_options)
      create_table :dynamic_form_options do |t|
        t.references :dynamic_form_field, null: false, foreign_key: true
        t.string :label, null: false
        t.string :value, null: false
        t.integer :position, default: 0
        t.timestamps
      end
    end

    # Create dynamic_form_responses table if it doesn't exist
    unless table_exists?(:dynamic_form_responses)
      create_table :dynamic_form_responses do |t|
        t.references :dynamic_form, null: false, foreign_key: true
        t.references :record, polymorphic: true, null: false
        t.text :data
        t.timestamps
      end
    end

    # Create test_models table if it doesn't exist
    unless table_exists?(:test_models)
      create_table :test_models do |t|
        t.references :dynamic_form, null: true, foreign_key: true
        t.timestamps
      end
    end
  end
end