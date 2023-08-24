class CreateAssignments < ActiveRecord::Migration[7.0]
  def change
    create_table :assignments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :claim, null: false, foreign_key: true
      t.date :from_date, null: false
      t.date :to_date

      t.timestamps
    end
  end
end
