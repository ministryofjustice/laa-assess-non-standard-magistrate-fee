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
          'plea' => 'cracked_trial',
          'plea_category' => 'not_guilty_pleas',
        }
      )

      expect(subject.rows).to have_key(:title)
      expect(subject.rows).to have_key(:data)
    end
  end

  describe '#data' do
    subject = described_class.new(
      {
        'plea' => 'cracked_trial',
        'plea_category' => 'not_guilty_pleas',
      }
    )

    it 'shows correct table data' do
      expect(subject.data).to eq(
        [
          { title: 'Category 2', value: 'Cracked trial' }
        ]
      )
    end
  end
end
