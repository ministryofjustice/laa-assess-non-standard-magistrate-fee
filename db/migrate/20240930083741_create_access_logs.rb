class CreateAccessLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :access_logs do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :path
      t.string :controller
      t.string :action
      t.string :submission_id
      t.string :secondary_id

      t.timestamps
    end
  end
end
