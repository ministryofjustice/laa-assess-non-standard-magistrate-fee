require 'rails_helper'

RSpec.describe ChangeRiskForm, type: :model do
  let(:user) { instance_double(User) }
  let(:claim) { create(:claim) }

  describe '#available_risks' do
    it 'returns an array of RiskLevels' do
      risks = subject.available_risks
      expect(risks).to be_an(Array)
      expect(risks.first).to be_a(ChangeRiskForm::RiskLevels)
    end

    it 'returns an array with three elements' do
      result = subject.available_risks
      expect(result.length).to eq(3)
    end

    it 'returns an array with the correct risk levels' do
      result = subject.available_risks
      expect(result.map(&:level)).to eq(['Low risk', 'Medium risk', 'High risk'])
    end
  end

  describe '#save' do
    subject { described_class.new(params) }

    let(:params) { { id: claim.id, risk_level: 'low', explanation: 'Test', current_user: user } }

    before do
      allow(Event::ChangeRisk).to receive(:build)
    end

    it 'updates the claim' do
      subject.save
      expect(claim.reload).to have_attributes(risk: 'low')
    end

    context 'when not valid' do
      let(:params) { {} }

      it { expect(subject.save).to be_falsey }
    end

    it 'creates a ChangeRisk event' do
      subject.save
      expect(Event::ChangeRisk).to have_received(:build).with(
        claim: claim, explanation: 'Test', previous_risk_level: 'low', current_user: user
      )
    end

    context 'when error during save' do
      before do
        allow(Claim).to receive(:find_by).and_return(claim)
        allow(claim).to receive(:update!).and_raise(StandardError)
      end

      it { expect(subject.save).to be_falsey }
    end
  end

  describe '#claim' do
    subject { described_class.new(id: claim.id) }

    it 'returns the claim with the given id' do
      expect(subject.claim).to eq(claim)
    end
  end
end
