require 'rails_helper'

RSpec.describe PriorAuthority::V1::ApplicationSummary do
  describe '#service_name' do
    it 'returns a translated service type by default' do
      summary = described_class.new(service_type: 'accident_reconstruction')
      expect(summary.service_name).to eq('Accident reconstruction')
    end

    it 'returns a custom service name if provided' do
      summary = described_class.new(service_type: 'custom', custom_service_name: 'Apples')
      expect(summary.service_name).to eq('Apples')
    end
  end

  describe '#current_section' do
    let(:submission) { create(:prior_authority_application, state:) }
    let(:state) { 'submitted' }
    let(:user) { create(:caseworker) }

    it { expect(described_class.new(submission:).current_section(user)).to eq :open }

    context 'when submission has been assessed' do
      let(:state) { 'granted' }

      it { expect(described_class.new(submission:).current_section(user)).to eq :assessed }
    end

    context 'when submission is assigned to current user' do
      before do
        submission.assignments.create(user:)
      end

      it { expect(described_class.new(submission:).current_section(user)).to eq :your }
    end
  end
end
