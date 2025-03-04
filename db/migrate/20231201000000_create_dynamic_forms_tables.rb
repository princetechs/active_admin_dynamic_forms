class CreateDynamicFormsTables < ActiveRecord::Migration[7.0]
  def change
    create_table :dynamic_forms do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.timestamps
    end

    add_index :dynamic_forms, :name, unique: true

    create_table :dynamic_form_fields do |t|
      t.references :dynamic_form, null: false, foreign_key: true
      t.string :label, null: false
      t.string :field_type, null: false
      t.integer :position, null: false
      t.boolean :required, default: false
      t.timestamps
    end

    create_table :dynamic_form_options do |t|
      t.references :dynamic_form_field, null: false, foreign_key: true
      t.string :label, null: false
      t.string :value, null: false
      t.integer :position, null: false
      t.timestamps
    end

    create_table :dynamic_form_responses do |t|
      t.references :dynamic_form, null: false, foreign_key: true
      t.references :record, polymorphic: true, null: false
      t.text :data
      t.timestamps
    end

    create_table :test_models do |t|
      t.references :dynamic_form, null: true, foreign_key: true
      t.timestamps
    end
  end
end