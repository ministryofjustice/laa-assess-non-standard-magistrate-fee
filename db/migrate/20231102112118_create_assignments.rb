class CreateAssignments < ActiveRecord::Migration[7.1]
  def change
    create_table :assignments, id: :uuid do |t|
      t.references :claim, null: false, foreign_key: true, index: { unique: true }, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
