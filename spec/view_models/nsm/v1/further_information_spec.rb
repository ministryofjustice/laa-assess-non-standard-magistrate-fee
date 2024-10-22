require 'rails_helper'

RSpec.describe Nsm::V1::FurtherInformation do
  subject { described_class.new(params) }

  let(:submission) { double('Submission', id: 1) }
  let(:user) { create(:caseworker, id: SecureRandom.uuid, first_name: 'Fred', last_name: 'Falke') }

  let(:params) do
    {
      'information_supplied' => 'Please find...',
      'caseworker_id' => user.id,
      'requested_at' => DateTime.now,
      'information_requested' => 'Please send...',
      'documents' => [{
        'file_name' => 'Some_Info.pdf',
        'file_path' => '421727bc53d347ea81edd6a00833671d',
        'file_size' => 690_389,
        'file_type' => 'application/pdf',
        'document_type' => 'supporting_document'
      }]
    }
  end

  describe '#data' do
    it 'shows correct table data' do
      allow(subject).to receive(:submission).and_return(submission)
      response_with_doc = '<p>Please find...</p><br>' \
                          '<a href="/nsm/further_information_downloads/421727bc53d347ea81edd6a00833671d' \
                          '?file_name=Some_Info.pdf">Some_Info.pdf</a>'
      expect(subject.data).to eq([{ title: 'Caseworker', value: 'Fred Falke' },
                                  { title: 'Information request', value: 'Please send...' },
                                  { title: 'Provider response', value: response_with_doc }])
    end
  end

  describe '#caseworker' do
    let(:params) do
      { 'information_supplied' => 'Please find...',
        'caseworker_id' => 1234,
        'requested_at' => DateTime.now,
        'information_requested' => 'Please send...',
        'documents' => [] }
    end

    it 'falls back to nil if CW not found' do
      subject { described_class.new(params) }

      expect(subject.caseworker).to be_nil
    end
  end

  describe '#uploaded_documents' do
    subject { described_class.new(params) }

    let(:params) do
      { 'information_supplied' => 'Please find...',
        'caseworker_id' => 1234,
        'requested_at' => DateTime.now,
        'information_requested' => 'Please send...',
        'documents' => nil }
    end

    it 'returns nil if no documents' do
      expect(subject.uploaded_documents).to be_empty
    end
  end
end
