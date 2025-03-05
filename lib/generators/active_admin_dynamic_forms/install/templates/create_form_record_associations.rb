class CreateFormRecordAssociations < ActiveRecord::Migration[7.0]
  def change
    create_table :form_record_associations do |t|
      t.references :dynamic_form, null: false, foreign_key: true
      t.references :record, polymorphic: true, null: false
      t.timestamps
      
      # Add a unique index to prevent duplicate associations
      t.index [:dynamic_form_id, :record_type, :record_id], 
              name: 'index_unique_form_record_associations',
              unique: true
    end
  end
end 