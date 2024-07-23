require 'rails_helper'

RSpec.describe SearchResult do
  describe '#application_path' do
    application_id = SecureRandom.uuid
    context 'submission is nsm' do
      before do
        create(:claim, id: application_id)
      end

      subject = described_class.new(
        {
          application_type: 'crm7',
          application_id: application_id,
          version: 1
        }
      )

      it 'generates a link to the non-standard magistrate details page' do
        expect(subject.application_path).to eq("/nsm/claims/#{application_id}/claim_details")
      end
    end

    context 'submission is prior authority' do
      before do
        create(:prior_authority_application, id: application_id)
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
  end
end
