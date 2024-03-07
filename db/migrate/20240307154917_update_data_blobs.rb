class UpdateDataBlobs < ActiveRecord::Migration[7.1]
  def change
    PriorAuthorityApplication.find_each do |application|
      application.data['main_offence_id'] = 'custom'
      application.data['custom_main_offence_name'] = application.data['main_offence']
      application.data['prison_id'] = 'custom'
      application.data['custom_prison_name'] = application.data['client_detained_prison']
    end
  end
end
