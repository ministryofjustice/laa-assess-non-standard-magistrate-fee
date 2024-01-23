class RenameClaimsToCrimeApplications < ActiveRecord::Migration[7.1]
  def change
    rename_table :claims, :crime_applications

    rename_column :assignments, :claim_id, :crime_application_id
    rename_column :events, :claim_id, :crime_application_id
    rename_column :events, :claim_version, :crime_application_version
  end
end
