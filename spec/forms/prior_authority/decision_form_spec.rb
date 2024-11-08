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
            'You can only part-grant an application if you have made adjustments to provider costs. ' \
            'You can either grant it without any cost adjustments, or make cost adjustments and part-grant it.'
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
            'You cannot reject an application after making adjustments to provider costs. ' \
            'You can either keep the adjustments and part-grant it, or delete the cost adjustments to reject it.'
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
            'You cannot grant an application after making adjustments to provider costs. ' \
            'You can either keep the adjustments and part-grant it, or delete the cost adjustments to reject it.'
          )
        end
      end
    end
  end

  describe '#save', :stub_oauth_token do
    let(:params) do
      {
        pending_decision: 'granted',
        pending_granted_explanation: 'granted_explanation',
        submission: submission,
        current_user: current_user
      }
    end
    let(:current_user) { create(:caseworker) }

    before do
      stub_request(:put, "https://appstore.example.com/v1/application/#{submission.id}").to_return(status: 201)
      subject.save
    end

    it 'adds an assessment comment to the payload' do
      expect(submission.reload.data).to include('assessment_comment' => 'granted_explanation')
    end
  end
end
