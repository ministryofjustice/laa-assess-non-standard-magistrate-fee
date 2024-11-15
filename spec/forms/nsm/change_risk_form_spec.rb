require 'rails_helper'

RSpec.describe Nsm::ChangeRiskForm, type: :model do
  let(:user) { instance_double(User) }
  let(:claim) { build(:claim) }

  describe '#available_risks' do
    context 'when the claim has a risk level' do
      let(:claim) { build(:claim, risk: 'medium') }
      let(:form) do
        described_class.new(claim: claim, risk_level: 'medium', explanation: 'Risk level changed', current_user: user)
      end

      it 'returns the available risks excluding the current risk level' do
        result = form.available_risks
        expect(result.map(&:level)).to eq(['Low risk', 'High risk'])
      end
    end
  end

  describe '#validations' do
    subject { described_class.new(claim:, risk_level:, explanation:) }

    let(:risk_level) { 'high' }
    let(:explanation) { 'changed to high' }

    context 'risk_level' do
      %w[high medium].each do |valid_risk|
        context "when risk is #{valid_risk}" do
          let(:risk_level) { valid_risk }

          it { expect(subject).to be_valid }
        end
      end

      context 'when risk level is unchanged' do
        let(:risk_level) { 'low' }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:risk_level, :unchanged)).to be(true)
        end
      end

      context 'when risk level is something else' do
        let(:risk_level) { 'other' }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:risk_level, :inclusion)).to be(true)
        end
      end
    end

    describe 'explanation' do
      context 'when it is blank' do
        let(:explanation) { '' }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:explanation, :blank)).to be(true)
        end

        context 'but the risk level has not changed' do
          let(:risk_level) { 'low' }

          it 'is does not raise an error' do
            expect(subject).not_to be_valid
            expect(subject.errors.of_kind?(:explanation, :blank)).to be(false)
          end
        end
      end
    end
  end

  describe '#save' do
    subject { described_class.new(params) }

    let(:params) { { claim: claim, risk_level: risk_level, explanation: 'Test', current_user: user } }
    let(:risk_level) { 'high' }
    let(:risk_event) { instance_double(Event::ChangeRisk) }
    let(:client) { instance_double(AppStoreClient) }

    before do
      allow(Event::ChangeRisk).to receive(:build).and_return(risk_event)
      allow(AppStoreClient).to receive(:new).and_return(client)
      allow(client).to receive(:update_submission_metadata)
    end

    context 'when not valid' do
      let(:params) { {} }

      it { expect(subject.save).to be_falsey }
    end

    it 'creates a ChangeRisk event' do
      subject.save
      expect(Event::ChangeRisk).to have_received(:build).with(
        submission: claim, explanation: 'Test', previous_risk_level: 'low', current_user: user
      )
    end

    it 'syncs to the app store' do
      subject.save
      expect(client).to have_received(:update_submission_metadata).with(
        claim, application_risk: risk_level, events: [risk_event]
      )
    end
  end

  describe '#claim' do
    subject { described_class.new(claim:) }

    it 'returns the claim with the given id' do
      expect(subject.claim).to eq(claim)
    end
  end
end
