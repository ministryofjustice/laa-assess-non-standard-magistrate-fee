class CreateVersions < ActiveRecord::Migration[7.0]
  def change
    create_table :versions, id: :uuid do |t|
      t.references :claim, null: true, type: :uuid
      t.jsonb :data


      t.timestamps
    end
  end
end
