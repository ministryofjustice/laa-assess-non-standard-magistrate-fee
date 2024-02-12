class DropSubmissionTables < ActiveRecord::Migration[7.1]
  def change
    drop_table :events
    drop_table :assignments
    drop_table :submissions
  end
end
