require 'rails_helper'

RSpec.describe Nsm::V1::ClaimJustification do
  subject { described_class.new(data) }

  let(:data) do
    {
      'reasons_for_claim' => [
        {
          'value' => 'enhanced_rates_claimed',
          'en' => 'Enhanced rates claimed',
        },
        {
          'value' => 'counsel_or_agent_assigned',
          'en' => 'Counsel or agent assigned',
        },
      ]
    }
  end

  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Claim justification')
    end
  end

  describe '#rows' do
    it 'has correct structure' do
      expect(subject.rows).to have_key(:title)
      expect(subject.rows).to have_key(:data)
    end
  end

  describe '#data' do
    it 'shows correct table data' do
      expect(subject.data).to eq(
        [
          {
            title: "Why are you claiming a non-standard magistrates' payment?",
            value: 'Enhanced rates claimed<br>Counsel or agent assigned'
          }
        ]
      )
    end

    context 'when `other` option is present' do
      let(:data) do
        {
          'reasons_for_claim' => [
            {
              'value' => 'enhanced_rates_claimed',
              'en' => 'Enhanced rates claimed',
            },
            {
              'value' => 'other',
              'en' => 'Other',
            },
          ],
          'reason_for_claim_other_details' => 'Other reasons for test'
        }
      end

      it 'also renders the option details' do
        expect(subject.data).to eq(
          [
            {
              title: "Why are you claiming a non-standard magistrates' payment?",
              value: 'Enhanced rates claimed<br>Other'
            },
            {
              title: "Other details about why a non-standard magistrates' court paymentis being claimed",
              value: 'Other reasons for test'
            }
          ]
        )
      end
    end
  end
end
