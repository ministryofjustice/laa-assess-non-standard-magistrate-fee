require 'rails_helper'

RSpec.describe V1::CaseDisposal do
  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Case disposal')
    end
  end

  describe '#data' do
    subject = described_class.new(
      {
        'plea' => {
          'value' => 'cracked_trial',
          'en' => 'Cracked Trial'
        },
        'plea_category' => 'Category 2'
      }
    )

    it 'shows correct table data' do
      expect(subject.data).to eq(
        [
          { title: 'Category 2', value: 'Cracked Trial' }
        ]
      )
    end
  end
end
