class AddNotifyAppStoreCompleteToSubmission < ActiveRecord::Migration[7.1]
  def change
    add_column :submissions, :notify_app_store_completed, :boolean
    add_column :events, :notify_app_store_completed, :boolean
  end
end
