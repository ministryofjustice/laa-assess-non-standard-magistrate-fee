class CreateClaims < ActiveRecord::Migration[7.0]
  def change
    create_table :claims, id: :uuid do |t|
      t.string :state
      t.string :risk
      t.integer :current_version
      t.date :received_on

      t.timestamps
    end
  end
end
