class RemoveVersionData < ActiveRecord::Migration[7.1]
  def change
    add_column :claims, :json_schema_version, :integer
    add_column :claims, :data, :jsonb

    sql = <<~SQL
      UPDATE claims
      SET json_schema_version = versions.json_schema_version,
        data = versions.data
      FROM
        versions
      WHERE
        versions.claim_id = claims.id
    SQL
    execute sql

    drop_table :versions
  end
end
