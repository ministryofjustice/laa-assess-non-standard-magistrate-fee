require 'rails_helper'

RSpec.describe Nsm::V1::CaseDisposal do
  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Case disposal')
    end
  end

  describe '#rows' do
    it 'has correct structure' do
      subject = described_class.new(
        {
          'plea' => 'guilty',
          'plea_category' => 'category_1a',
        }
      )

      expect(subject.rows).to have_key(:title)
      expect(subject.rows).to have_key(:data)
    end
  end

  describe '#data' do
    subject = described_class.new(
      {
        'plea' => 'guilty',
        'plea_category' => 'category_1a',
      }
    )

    it 'shows correct table data' do
      expect(subject.data).to eq(
        [
          { title: 'Category 1A', value: 'Guilty plea' }
        ]
      )
    end

    context 'youth court fee claimed and no adjustment has been made' do
      it 'shows the correct details' do
        subject = described_class.new(
          {
            'plea' => 'guilty',
            'plea_category' => 'category_1a',
            'include_youth_court_fee' => true,
            'include_youth_court_fee_original' => nil
          }
        )
        expect(subject.data).to eq(
          [
            { title: 'Category 1A', value: 'Guilty plea' },
            { title: 'Additional fee', value: 'Youth court fee claimed' }
          ]
        )
      end
    end

    context 'youth court fee claimed and an adjustment has been made' do
      it 'shows the correct details' do
        subject = described_class.new(
          {
            'plea' => 'guilty',
            'plea_category' => 'category_1a',
            'include_youth_court_fee' => false,
            'include_youth_court_fee_original' => true
          }
        )

        expect(subject.data).to eq(
          [
            { title: 'Category 1A', value: 'Guilty plea' },
            { title: 'Additional fee', value: 'Youth court fee claimed' }
          ]
        )
      end
    end

    context 'youth court fee not claimed' do
      it 'to not include the youth court fee' do
        subject = described_class.new(
          {
            'plea' => 'guilty',
            'plea_category' => 'category_1a',
            'include_youth_court_fee' => false
          }
        )
        expect(subject.data).to eq(
          [
            { title: 'Category 1A', value: 'Guilty plea' },
            { title: 'Additional fee', value: 'Youth court fee not claimed' }
          ]
        )
      end

      it 'handles plea category being Other' do
        subject = described_class.new(
          {
            'plea' => 'other',
            'case_outcome_other_info' => 'Test',
            'plea_category' => 'category_1a',
            'include_youth_court_fee' => false
          }
        )
        expect(subject.data).to eq(
          [
            { title: 'Category 1A', value: 'Other: Test' },
            { title: 'Additional fee', value: 'Youth court fee not claimed' }
          ]
        )
      end

      it 'handles Date values' do
        subject = described_class.new(
          {
            'plea' => 'cracked_trial',
            'cracked_trial_date' => Date.new(2024, 12, 5),
            'plea_category' => 'category_1a',
            'include_youth_court_fee' => false
          }
        )
        expect(subject.data).to eq(
          [
            { title: 'Category 1A', value: 'Cracked trial' },
            { title: 'Date of cracked trial', value: '5 December 2024' },
            { title: 'Additional fee', value: 'Youth court fee not claimed' }
          ]
        )
      end
    end
  end
end
