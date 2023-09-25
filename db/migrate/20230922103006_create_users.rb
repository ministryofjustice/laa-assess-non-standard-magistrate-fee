class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :email, null: false, index: true
      t.string :name
      t.string :role
      t.timestamps
    end
  end
end
