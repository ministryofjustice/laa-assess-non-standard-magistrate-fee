class AddLastUpdatedAtToSubmission < ActiveRecord::Migration[7.1]
  def change
    add_column :submissions, :last_updated_at, :datetime
  end
end
