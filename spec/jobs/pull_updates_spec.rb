require 'rails_helper'

RSpec.describe PullUpdates do
  let(:last_update) { 2 }
  let(:client) { instance_double(AppStoreClient, get_all_submissions: http_response) }
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

  before do
    allow(Claim).to receive(:maximum).and_return(last_update)
    allow(AppStoreClient).to receive(:new).and_return(client)
    allow(UpdateSubmission).to receive(:call)
  end

  context 'no data since last pull' do
    let(:http_response) { { 'applications' => [] } }

    it 'do nothing' do
      subject.perform
      expect(UpdateSubmission).not_to have_received(:call)
    end
  end

  context 'when data exists' do
    it 'creates and pushed it to the ReceiveApplicationMetadata class' do
      subject.perform

      expect(UpdateSubmission).to have_received(:call).with(
        'application_id' => id,
        'application_risk' => 'high',
        'application_state' => 'submitted',
        'application_type' => 'crm7',
        'updated_at' => 10,
        'version' => 2
      )
    end
  end
end
