require 'rails_helper'

RSpec.describe SearchResult do
  describe '#application_path' do
    application_id = SecureRandom.uuid
    context 'submission is nsm' do
      subject do
        described_class.new(
          application_type: 'crm7',
          application_id: application_id,
          version: 1
        )
      end

      before do
        build(:claim, id: application_id)
      end

      it 'generates a link to the non-standard magistrate details page' do
        expect(subject.application_path).to eq("/nsm/claims/#{application_id}/claim_details")
      end
    end

    context 'submission is prior authority' do
      before do
        build(:prior_authority_application, id: application_id)
      end

      subject = described_class.new(
        {
          application_type: 'crm4',
          application_id: application_id,
          version: 1
        }
      )

      it 'generates a link to the prior authority details page' do
        expect(subject.application_path).to eq("/prior_authority/applications/#{application_id}")
      end
    end

    context 'submission has invalid application type' do
      subject do
        described_class.new(
          application_type: 'random',
          application_id: application_id,
          version: 1
        )
      end

      let(:application) { instance_double(Claim, application_type: 'random', id: application_id) }

      before do
        allow(Submission).to receive(:load_from_app_store).and_return(application)
      end

      it 'raises error' do
        expect { subject.application_path }.to raise_error('Unknown application type random')
      end
    end
  end
end
