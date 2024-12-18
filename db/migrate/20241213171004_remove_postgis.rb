class RemovePostgis < ActiveRecord::Migration[7.2]
  def change
    disable_extension 'postgis'
  end
end
