class CreateAutograntLimits < ActiveRecord::Migration[7.1]
  def change
    create_table :autogrant_limits do |t|
      t.string :service
      t.string :unit_type
      t.date :start_date
      t.integer :max_units
      t.decimal :max_rate_london, precision: 10, scale: 2
      t.decimal :max_rate_non_london, precision: 10, scale: 2
      t.integer :travel_hours
      t.decimal :travel_rate_london, precision: 10, scale: 2
      t.decimal :travel_rate_non_london, precision: 10, scale: 2

      t.timestamps
    end

    add_index :autogrant_limits, [:service, :start_date], unique: true
  end
end
