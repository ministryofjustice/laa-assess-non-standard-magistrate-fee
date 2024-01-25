require 'rails_helper'

RSpec.describe PullLatestVersionData do
  let(:claim) do
    instance_double(Claim,
                    id: id,
                    current_version: current_version,
                    assign_attributes: true,
                    save!: true,
                    data: data,
                    namespace: Nsm)
  end
  let(:data) { {} }
  let(:id) { SecureRandom.uuid }
  let(:current_version) { 2 }
  let(:http_puller) { instance_double(HttpPuller, get: http_response) }
  let(:http_response) do
    {
      'version' => 2,
      'json_schema_version' => 1,
      'application_state' => 'submitted',
      'application' => { 'same' => 'data' },
      'events' => events_data
    }
  end
  let(:events_data) { nil }

  before do
    allow(Event::NewVersion).to receive(:build).and_return(true)
    allow(HttpPuller).to receive(:new).and_return(http_puller)
  end

  context 'when current version already exists' do
    let(:data) { { existing: :data } }

    it 'do nothing' do
      expect(subject.perform(claim)).to be_nil
      expect(HttpPuller).not_to have_received(:new)
    end
  end

  context 'when version does not already exist' do
    it 'pulls data via HttpPuller' do
      subject.perform(claim)

      expect(http_puller).to have_received(:get).with(claim)
    end

    context 'when event data exists' do
      let(:claim) { create(:claim, current_version: current_version, data: {}) }
      let(:user) { create(:supervisor) }
      let(:events_data) do
        [{
          'submission_version' => 1,
          'primary_user_id' => user.id,
          'secondary_user_id' => nil,
          'linked_type' => nil,
          'linked_id' => nil,
          'details' => { 'to' => 'granted', 'from' => 'submitted', 'field' => 'state', 'comment' => nil },
          'created_at' => '2023-10-02T14:41:45.136Z',
          'updated_at' => '2023-10-02T14:41:45.136Z',
          'public' => true
        }]
      end

      it 'rehydrates the events' do
        subject.perform(claim)
        expect(Event.count).to eq(1)
        expect(Event.last).to have_attributes(
          submission_id: claim.id,
          submission_version: 1,
          primary_user_id: user.id,
          secondary_user_id: nil,
          linked_type: nil,
          linked_id: nil,
          details: { 'to' => 'granted', 'from' => 'submitted', 'field' => 'state', 'comment' => nil },
          created_at: Time.parse('2023-10-02T14:41:45.136Z'),
          updated_at: Time.parse('2023-10-02T14:41:45.136Z'),
        )
      end
    end

    context 'when pulled version matches current' do
      it 'creates the new version' do
        subject.perform(claim)

        expect(claim).to have_received(:assign_attributes).with(
          json_schema_version: 1,
          data: { 'same' => 'data' }
        )
        expect(claim).to have_received(:save!)
      end

      it 'creates a new version event' do
        subject.perform(claim)

        expect(Event::NewVersion).to have_received(:build).with(submission: claim)
      end
    end

    context 'when pulled version is higher than current' do
      let(:current_version) { 1 }

      it 'do nothing' do
        subject.perform(claim)

        expect(claim).not_to have_received(:assign_attributes)
      end
    end

    context 'when pulled version is lower than current' do
      let(:current_version) { 3 }

      it 'raise an error' do
        expect { subject.perform(claim) }.to raise_error(
          "Correct version not found on AppStore: #{claim.id} - 3 only found 2"
        )
      end
    end
  end

  context 'when pulling prior authority data' do
    let(:http_response) do
      {
        'version' => 1,
        'json_schema_version' => 1,
        'application_state' => 'submitted',
        'application_type' => 'crm4',
        'application' => data,
        'events' => []
      }
    end

    let(:application) { create(:prior_authority_application, current_version: 1, data: nil) }

    context 'when data is valid' do
      let(:data) { build(:prior_authority_data) }

      it 'updates the data' do
        subject.perform(application)
        expect(application.data).to eq data.with_indifferent_access
      end
    end

    context 'when base data is invalid' do
      let(:data) { build(:prior_authority_data, court_type: 'invalid') }

      it 'raises an error' do
        expect { subject.perform(application) }.to raise_error(
          "Received submission data that does not adhere to our assumptions: \nCourt type is not included in the list"
        )
      end
    end

    context 'when additional cost data is invalid' do
      let(:data) { build(:prior_authority_data, additional_costs: [build(:additional_cost, description: nil)]) }

      it 'raises an error' do
        expect { subject.perform(application) }.to raise_error(
          'Received submission data that does not adhere to our assumptions: ' \
          "\nAdditional costs Description can't be blank"
        )
      end
    end
  end
end
