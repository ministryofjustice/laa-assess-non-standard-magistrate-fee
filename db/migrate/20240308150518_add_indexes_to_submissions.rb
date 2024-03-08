class AddIndexesToSubmissions < ActiveRecord::Migration[7.1]
  def change
    add_index(:submissions, "(data->>'laa_reference')", name: "index_submissions_on_laa_reference")
    add_index(:submissions, "(data->>'firm_name')", name: "index_submissions_on_firm_name")
    add_index(:submissions, "(data->>'client_name')", name: "index_submissions_on_client_name")
  end
end
