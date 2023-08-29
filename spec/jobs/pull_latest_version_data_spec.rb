require 'rails_helper'

RSpec.describe PullLatestVersionData do
  let(:claim) { instance_double(Claim, id:, current_version:, versions:) }
  let(:versions) { double(:versions, find_by: find_by, 'create!': true) }
  let(:id) { SecureRandom.uuid }
  let(:current_version) { 2 }
  let(:find_by) { nil }
  let(:http_puller) { instance_double(HttpPuller, get: http_response) }
  let(:http_response) { {
    'version' => 2,
    'json_schema_version' => 1,
    'application_state' => 'submitted',
    'application' => { 'same' => 'data' }
  } }

  before do
    allow(HttpPuller).to receive(:new).and_return(http_puller)
  end

  context 'when current version already exists' do
    let(:find_by) { double }

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

    context 'when pulled version matches current' do
      it 'creates the new version' do
        subject.perform(claim)

        expect(versions).to have_received(:create!).with(
          version: 2,
          json_schema_version: 1,
          state: 'submitted',
          data: { 'same' => 'data' }
        )
      end
    end

    context 'when pulled version is higher than current' do
      let(:current_version) { 1 }

      it 'do nothing' do
        subject.perform(claim)

        expect(versions).not_to have_received(:create!)
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