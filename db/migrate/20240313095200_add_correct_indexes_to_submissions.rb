class AddCorrectIndexesToSubmissions < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    remove_index :submissions, name: "index_submissions_on_firm_name", if_exists: true
    remove_index :submissions, name: "index_submissions_on_client_name", if_exists: true

    add_index(:submissions, "(data->'firm_office'->>'name')", name: "index_submissions_on_firm_name", algorithm: :concurrently)
    add_index(:submissions, "(data->'defendant'->>'first_name'), (data->'defendant'->>'last_name')", name: "index_submissions_on_client_name", algorithm: :concurrently)
  end

  def down
    remove_index :submissions, name: "index_submissions_on_firm_name", if_exists: true
    remove_index :submissions, name: "index_submissions_on_client_name", if_exists: true

    add_index(:submissions, "(data->>'firm_name')", name: "index_submissions_on_firm_name", algorithm: :concurrently)
    add_index(:submissions, "(data->>'client_name')", name: "index_submissions_on_client_name", algorithm: :concurrently)
  end
end

