class CreateChangeLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :change_logs, id: :uuid do |t|
      t.references :claim, null: true, type: :uuid
      t.uuid :object_id
      t.string :object_type
      t.string :field
      t.string :from_value
      t.string :new_value
      t.string :comment

      t.timestamps
    end
  end
end
