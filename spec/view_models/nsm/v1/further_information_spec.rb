require 'rails_helper'

RSpec.describe Nsm::V1::FurtherInformation do
  subject { described_class.new(params) }

  let(:params) do
    {
      'information_supplied' => 'Please find...',
      'caseworker_id' => user.id,
      'requested_at' => DateTime.now,
      'information_requested' => 'Please send...',
      'documents' => []
    }
  end

  let(:user) { create(:caseworker, id: SecureRandom.uuid, first_name: 'Fred', last_name: 'Falke') }

  describe '#data' do
    it 'shows correct table data' do
      expect(subject.data).to eq([{ title: 'Caseworker', value: 'Fred Falke' },
                                  { title: 'Information request', value: 'Please send...' },
                                  { title: 'Provider response', value: '<p>Please find...</p>' }])
    end
  end

  describe '#caseworker' do
    it 'shows caseworker display name' do
      expect(subject.caseworker).to eq 'Fred Falke'
    end

    it 'falls back to nil if CW not found' do
      params = { 'information_supplied' => 'Please find...',
                 'caseworker_id' => 1234,
                 'requested_at' => DateTime.now,
                 'information_requested' => 'Please send...',
                 'documents' => [] }
      subject = described_class.new(params)

      expect(subject.caseworker).to be_nil
    end
  end
end
