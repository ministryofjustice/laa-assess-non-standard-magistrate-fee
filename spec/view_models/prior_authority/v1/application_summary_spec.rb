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

  describe '#main_offence' do
    context 'when using a standard offence' do
      subject(:key_information) { described_class.new(main_offence_id: 'robbery') }

      it 'returns the main offence' do
        expect(key_information.main_offence).to eq('Robbery')
      end

      context 'when using a custom offence' do
        subject(:key_information) { described_class.new(main_offence_id: 'custom', custom_main_offence_name: 'Stuff') }

        it 'returns the main offence' do
          expect(key_information.main_offence).to eq('Stuff')
        end
      end
    end
  end

  describe '#current_section' do
    let(:submission) { build(:prior_authority_application, state:) }
    let(:state) { 'submitted' }
    let(:user) { create(:caseworker) }

    it { expect(described_class.new(submission:).current_section(user)).to eq :open }

    context 'when submission has been assessed' do
      let(:state) { 'granted' }

      it { expect(described_class.new(submission:).current_section(user)).to eq :assessed }
    end

    context 'when submission is assigned to current user' do
      before do
        submission.assigned_user_id = user.id
      end

      it { expect(described_class.new(submission:).current_section(user)).to eq :your }
    end
  end

  describe '#caseworker' do
    context 'when no caseworker is assigned' do
      let(:submission) { build(:prior_authority_application, assigned_user_id: nil) }

      it 'returns nil' do
        expect(described_class.new(submission:).caseworker).to be_nil
      end
    end

    context 'when a caseworker is assigned' do
      let(:submission) { build(:prior_authority_application, assigned_user_id: user.id) }
      let(:user) { create(:caseworker) }

      it 'returns the caseworker name' do
        expect(described_class.new(submission:).caseworker).to eq user.display_name
      end
    end
  end
end
