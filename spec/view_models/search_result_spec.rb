require 'rails_helper'

RSpec.describe SearchResult do
  describe '#application_path' do
    let(:application_type) { nil }
    let(:application_id) { nil }
    let(:nsm_application) { create(:claim) }
    let(:pa_application) { create(:prior_authority_application) }
    let(:submission) do
      {
        application_type: application_type,
        application_id: application_id,
        version: 1
      }
    end

    subject = described_class.new(submission)

    context 'submission is nsm' do
      let(:application_type) { 'crm7' }
      let(:application_id) { nsm_application.id }

      it 'generates a link to the non-standard magistrate details page' do
        expect(subject.application_path).to eq("/nsm/claims/#{application_id}/claim_details")
      end
    end

    context 'submission is prior authority' do
      let(:application_type) { 'crm4' }
      let(:application_id) { pa_application.id }

      it 'generates a link to the prior authority details page' do
        expect(subject.application_path).to eq("/prior_authority/applications/#{application_id}")
      end
    end
  end
end
