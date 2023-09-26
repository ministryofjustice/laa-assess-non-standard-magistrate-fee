require 'rails_helper'

RSpec.describe V1::OtherInfo do
  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Other relevant information')
    end
  end

  describe '#data' do
    context 'other info and case concluded is yes' do
      subject = described_class.new(
        {
          'is_other_info' => 'yes',
          'other_info' => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. \nDuis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
          'concluded' => 'yes',
          'conclusion' => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
        }
      )

      it 'shows correct table data' do
        expect(subject.data).to eq([
                                    { title: 'Any other information', value: 'Yes' },
                                    { title: 'Other information added', value: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. \\nDuis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.' },
                                    { title: 'Proceedings concluded over 3 months ago', value: 'Yes' },
                                    { title: 'Reason for not claiming within 3 months', value: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.' }
                                  ])
      end
    end

    context 'other info and case concluded is no' do
      subject = described_class.new(
        {
          'is_other_info' => 'no',
          'other_info' => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. \nDuis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
          'concluded' => 'no',
          'conclusion' => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
        }
      )

      it 'shows correct table data' do
        expect(subject.data).to eq([
          { title: 'Any other information', value: 'No' },
          { title: 'Proceedings concluded over 3 months ago', value: 'No' },
                                  ])
      end
    end
  end
end
