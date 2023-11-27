require 'rails_helper'

RSpec.describe PullUpdates do
  let(:last_update) { 2 }
  let(:http_puller) { instance_double(HttpPuller, get_all: http_response) }
  let(:http_response) do
    {
      'applications' => [{
        'application_id' => id,
        'version' => 2,
        'application_state' => 'submitted',
        'application_risk' => 'high',
        'updated_at' => 10,
        'application_type' => 'crm7'
      }]
    }
  end
  let(:id) { SecureRandom.uuid }
  let(:metadata_processor) { instance_double(ReceiveApplicationMetadata, save: true) }

  before do
    allow(Claim).to receive(:maximum).and_return(last_update)
    allow(HttpPuller).to receive(:new).and_return(http_puller)
    allow(ReceiveApplicationMetadata).to receive(:new).and_return(metadata_processor)
  end

  context 'no data since last pull' do
    let(:http_response) { { 'applications' => [] } }

    it 'do nothing' do
      subject.perform
      expect(ReceiveApplicationMetadata).not_to have_received(:new)
    end
  end

  context 'when data exists' do
    it 'creates and pushed it to the ReceiveApplicationMetadata class' do
      subject.perform

      expect(ReceiveApplicationMetadata).to have_received(:new).with(id)
      expect(metadata_processor).to have_received(:save).with(
        state: 'submitted',
        risk: 'high',
        current_version: 2,
        app_store_updated_at: 10,
        application_type: 'crm7'
      )
    end
  end
end
