class ClearExistingData < ActiveRecord::Migration[7.0]
  def change
    # need to clear out any existing data that doe not meet the latest specification
    # may make more sense to use versions here in the future, but this is pre-production
    Version.delete_all
    Application.delete_all
  end
end
