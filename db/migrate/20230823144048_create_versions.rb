class CreateVersions < ActiveRecord::Migration[7.0]
  def change
    create_table :versions, id: :uuid do |t|
      t.references :claim, null: true, foreign_key: true, type: :uuid
      t.integer :version
      t.integer :json_schema_version
      t.string :state
      t.jsonb :data


      t.timestamps
    end
  end
end
