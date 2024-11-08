class RenameFlag < ActiveRecord::Migration[7.2]
  def change
    rename_column :submissions, :notify_app_store_completed, :send_email_to_provider_completed
    remove_column :events, :notify_app_store_completed, :boolean
  end
end
