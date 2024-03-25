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

    AutograntLimit.upsert_all(limits, unique_by: [:service, :start_date])
  end

  def limits
    file_name = Rails.root.join('db/migrate/20240308140314_create_autogrant_limits.csv')
    limits = CSV.read(file_name, headers: true).map { _1.to_h }
    limits.each do |limit|
      limit['service'] = lookup_service(limit['service'])
    end
  end

  def lookup_service(service_name)
    @service_ids ||= I18n.t("prior_authority.service_types").to_h.invert
    @service_ids.fetch(service_name)
  end
end
