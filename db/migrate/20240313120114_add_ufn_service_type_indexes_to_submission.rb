class AddUfnServiceTypeIndexesToSubmission < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index(:submissions, "(data->>'ufn')", name: "index_submissions_on_ufn", algorithm: :concurrently)
    add_index(:submissions, "(data->'firm_office'->>'account_number')", name: "index_submissions_on_firm_account_number", algorithm: :concurrently)
    add_index(:submissions, "(data->>'ufn'), (data->'firm_office'->>'account_number')", name: "index_submissions_on_related_applications", algorithm: :concurrently)
    add_index(:submissions, "(data->>'service_type')", name: "index_submissions_on_service_type", algorithm: :concurrently)
  end
end
