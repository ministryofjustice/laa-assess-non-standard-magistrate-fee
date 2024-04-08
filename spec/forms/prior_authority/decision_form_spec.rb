require 'rails_helper'

RSpec.describe PriorAuthority::DecisionForm do
  subject { described_class.new(params) }

  let(:submission) { create(:prior_authority_application, data:) }
  let(:data) { build(:prior_authority_data) }

  describe '#explanation' do
    let(:params) do
      {
        pending_decision: pending_decision,
        pending_granted_explanation: 'granted_explanation',
        pending_part_grant_explanation: 'part_grant_explanation',
        pending_rejected_explanation: 'rejected_explanation',
      }
    end

    context 'when decision is granted' do
      let(:pending_decision) { 'granted' }

      it { expect(subject.explanation).to eq 'granted_explanation' }
    end

    context 'when decision is part_grant' do
      let(:pending_decision) { 'part_grant' }

      it { expect(subject.explanation).to eq 'part_grant_explanation' }
    end

    context 'when decision is rejected' do
      let(:pending_decision) { 'rejected' }

      it { expect(subject.explanation).to eq 'rejected_explanation' }
    end

    context 'when decision is not chosen' do
      let(:pending_decision) { nil }

      it { expect(subject.explanation).to be_nil }
    end
  end

  describe '#valid?' do
    context 'when decision is part_grant' do
      let(:params) do
        {
          pending_decision: 'part_grant',
          submission: submission
        }
      end

      before { subject.valid? }

      context 'when no adjustments have been made' do
        it 'adds an appropriate error' do
          expect(subject.errors[:pending_decision]).to include(
            "You must make adjustments to the provider's costs " \
            'before you can submit this application as being part granted'
          )
        end
      end

      context 'when adjustments have been made' do
        let(:data) { build(:prior_authority_data, quotes: [build(:primary_quote, items_original: 8)]) }

        it 'adds no error' do
          expect(subject.errors[:pending_decision]).to be_empty
        end
      end
    end

    context 'when decision is rejected' do
      let(:params) do
        {
          pending_decision: 'rejected',
          submission: submission
        }
      end

      before { subject.valid? }

      context 'when adjustments have been made' do
        let(:data) { build(:prior_authority_data, quotes: [build(:primary_quote, items_original: 8)]) }

        it 'adds an error' do
          expect(subject.errors[:pending_decision]).to include(
            "You must delete adjustments made to the provider's costs " \
            'before you can submit this application as being rejected'
          )
        end
      end
    end

    context 'when decision is granted' do
      let(:params) do
        {
          pending_decision: 'granted',
          submission: submission
        }
      end

      before { subject.valid? }

      context 'when adjustments have been made' do
        let(:data) { build(:prior_authority_data, quotes: [build(:primary_quote, items_original: 8)]) }

        it 'adds an error' do
          expect(subject.errors[:pending_decision]).to include(
            "You must delete adjustments made to the provider's costs " \
            'before you can submit this application as being granted'
          )
        end
      end
    end
  end
end
