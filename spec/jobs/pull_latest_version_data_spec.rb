require 'rails_helper'

RSpec.describe PullLatestVersionData do
  let(:claim) { instance_double(Claim, id:, current_version:, update!: true, data: data) }
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
      let(:claim) { create(:claim, current_version:, data: {}) }
      let(:user) { create(:supervisor) }
      let(:events_data) do
        [{
          'claim_version' => 1,
          'primary_user_id' => user.id,
          'secondary_user_id' => nil,
          'linked_type' => nil,
          'linked_id' => nil,
          'details' => { 'to' => 'grant', 'from' => 'submitted', 'field' => 'state', 'comment' => nil },
          'created_at' => '2023-10-02T14:41:45.136Z',
          'updated_at' => '2023-10-02T14:41:45.136Z',
          'public' => true
        }]
      end

      it 'rehydrates the events' do
        subject.perform(claim)
        expect(Event.count).to eq(1)
        expect(Event.last).to have_attributes(
          claim_id: claim.id,
          claim_version: 1,
          primary_user_id: user.id,
          secondary_user_id: nil,
          linked_type: nil,
          linked_id: nil,
          details: { 'to' => 'grant', 'from' => 'submitted', 'field' => 'state', 'comment' => nil },
          created_at: Time.parse('2023-10-02T14:41:45.136Z'),
          updated_at: Time.parse('2023-10-02T14:41:45.136Z'),
        )
      end
    end

    context 'when pulled version matches current' do
      it 'creates the new version' do
        subject.perform(claim)

        expect(claim).to have_received(:update!).with(
          json_schema_version: 1,
          data: { 'same' => 'data' }
        )
      end

      it 'creates a new version event' do
        subject.perform(claim)

        expect(Event::NewVersion).to have_received(:build).with(claim:)
      end
    end

    context 'when pulled version is higher than current' do
      let(:current_version) { 1 }

      it 'do nothing' do
        subject.perform(claim)

        expect(claim).not_to have_received(:update!)
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
end
