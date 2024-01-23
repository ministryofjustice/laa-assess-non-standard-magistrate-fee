class RenameCrimeApplicationsToSubmissions < ActiveRecord::Migration[7.1]
  def change
    rename_table :crime_applications, :submissions
    rename_column :assignments, :crime_application_id, :submission_id
    rename_column :events, :crime_application_id, :submission_id
    rename_column :events, :crime_application_version, :submission_version
  end
end
