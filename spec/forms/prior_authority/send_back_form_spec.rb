require 'rails_helper'

RSpec.describe PriorAuthority::SendBackForm do
  subject { described_class.new(params) }

  let(:submission) { create(:prior_authority_application) }
  let(:further_information_explanation) { 'foo' }
  let(:incorrect_information_explanation) { 'bar' }

  describe '#comment' do
    context 'when further information is requested' do
      let(:params) do
        {
          updates_needed: ['further_information'],
          further_information_explanation: further_information_explanation
        }
      end

      it { expect(subject.comment).to eq further_information_explanation }
    end

    context 'when incorrect information is cited' do
      let(:params) do
        {
          updates_needed: ['incorrect_information'],
          incorrect_information_explanation: incorrect_information_explanation
        }
      end

      it { expect(subject.comment).to eq incorrect_information_explanation }
    end

    context 'when both reasons are given' do
      let(:params) do
        {
          updates_needed: %w[further_information incorrect_information],
          further_information_explanation: further_information_explanation,
          incorrect_information_explanation: incorrect_information_explanation
        }
      end

      it 'combines the two explanations' do
        expect(subject.comment).to eq(
          "#{further_information_explanation} #{incorrect_information_explanation}"
        )
      end
    end
  end
end
