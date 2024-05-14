require 'rails_helper'

RSpec.describe Nsm::V1::YourClaims, type: :view_model do
  subject(:your_claims) do
    described_class.new(laa_reference:, defendants:, firm_office:, submission:, risk:)
  end

  let(:laa_reference) { '1234567890' }
  let(:defendants) do
    [{ 'first_name' => 'John', 'last_name' => 'Doe', 'main' => true },
     { 'main' => false, 'first_name' => 'jim', 'last_name' => 'bob' }]
  end
  let(:firm_office) { { 'name' => 'Acme Law Firm' } }
  let(:created_at) { Time.zone.yesterday }
  let(:submission) { instance_double(Claim, id: 1, created_at: created_at) }
  let(:risk) { 'low' }

  describe '#main_defendant_name' do
    it 'returns the name of the main defendant' do
      summary = described_class.new('defendants' => defendants)
      expect(summary.main_defendant_name).to eq('John Doe')
    end

    context 'when no main defendant record - shouold not be possible' do
      it 'returns an empty string' do
        defendants = [
          { 'main' => false, 'first_name' => 'John', 'last_name' => 'Doe' },
        ]
        summary = described_class.new('defendants' => defendants)
        expect(summary.main_defendant_name).to eq('')
      end
    end
  end

  describe '#firm_name' do
    it 'returns the name of the firm office' do
      expect(your_claims.firm_name).to eq('Acme Law Firm')
    end
  end

  describe '#risk_sort' do
    context 'when risk is high' do
      it 'returns a hash with text "high" and sort value 1' do
        subject.risk = 'high'
        expect(subject.risk_sort).to eq(1)
      end
    end

    context 'when risk is medium' do
      it 'returns a hash with text "medium" and sort value 2' do
        subject.risk = 'medium'
        expect(subject.risk_sort).to eq(2)
      end
    end

    context 'when risk is low' do
      it 'returns a hash with text "low" and sort value 3' do
        subject.risk = 'low'
        expect(subject.risk_sort).to eq(3)
      end
    end

    context 'when risk is invalid' do
      it 'returns nil' do
        subject.risk = nil
        expect(subject.risk_sort).to be_nil
      end
    end
  end

  describe 'date_created' do
    let(:submission) { instance_double(Claim, id: 1, created_at: DateTime.new(2023, 11, 21, 17, 17, 43)) }

    it 'date_created_str -> formats the created_at date' do
      expect(subject.date_created_str).to eq('21 Nov 2023')
    end

    it 'date_created_sort -> returns value for sort' do
      expect(subject.date_created_sort).to eq('2023-11-21 17:17:43')
    end
  end

  describe 'state' do
    context 'when the submission is sent back' do
      let(:submission) { instance_double(Claim, sent_back?: true, state: 'provider_requested') }

      it 'returns the submission state' do
        expect(subject.state).to eq 'provider_requested'
      end
    end

    context 'when the submission is not sent back' do
      let(:submission) { instance_double(Claim, sent_back?: false) }

      it 'returns in_progress' do
        expect(subject.state).to eq 'in_progress'
      end
    end
  end

  describe 'tag_colour' do
    context 'when the submission is sent back' do
      let(:submission) { instance_double(Claim, sent_back?: true, state: 'provider_requested') }

      it 'returns yellow' do
        expect(subject.tag_colour).to eq 'yellow'
      end
    end

    context 'when the submission is not sent back' do
      let(:submission) { instance_double(Claim, sent_back?: false) }

      it 'returns purple' do
        expect(subject.tag_colour).to eq 'purple'
      end
    end
  end
end
