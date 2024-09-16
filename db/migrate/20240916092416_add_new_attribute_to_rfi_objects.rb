class AddNewAttributeToRfiObjects < ActiveRecord::Migration[7.1]
  def up
    PriorAuthorityApplication.provider_updated.find_each do |paa|
      latest_provider_update_event = paa.events
                                        .where(event_type: 'Event::ProviderUpdated')
                                        .order(:created_at)
                                        .last

      added_fi = latest_provider_update_event.details['comment'].present?
      added_correction = latest_provider_update_event.details['corrected_info'].any?

      if added_fi
        latest_fi = paa.data['further_information']&.max_by { _1['requested_at'] }
        latest_fi && latest_fi['new'] = true
      end

      if added_correction
        latest_correction = paa.data['incorrect_information']&.max_by { _1['requested_at'] }
        latest_correction && latest_correction['new'] = true
      end

      paa.save!(touch: false)
    end
  end
end
