class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events, id: :uuid do |t|
      t.references :claim, null: false, foreign_key: true, type: :uuid
      t.integer :claim_version
      t.string :event_type
      t.references :primary_user, null: true, foreign_key: { to_table: :users }, type: :uuid
      t.references :secondary_user, null: true, foreign_key: { to_table: :users }, type: :uuid
      t.string :linked_type
      t.uuid :linked_id
      t.jsonb :details, default: {}

      t.timestamps
    end
  end
end
