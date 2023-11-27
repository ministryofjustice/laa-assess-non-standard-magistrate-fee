class AddApplicationType < ActiveRecord::Migration[7.1]
  def change
    add_column :claims, :application_type, :string

    execute <<~SQL
      UPDATE claims
      SET application_type = 'crm7'
    SQL
  end
end
