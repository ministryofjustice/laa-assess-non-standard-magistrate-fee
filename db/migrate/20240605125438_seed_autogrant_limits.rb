class SeedAutograntLimits < ActiveRecord::Migration[7.1]
  def up
    load Rails.root.join("db/seeds/autogrant_limits.rb")
  end
end
