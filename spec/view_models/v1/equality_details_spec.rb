require 'rails_helper'

RSpec.describe V1::EqualityDetails do
  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Equality monitoring')
    end
  end

  describe '#rows' do
    it 'has correct structure' do
      subject = described_class.new(
        {
          'answer_equality' => 'yes',
          'ethnic_group' => '01_with_british',
          'gender' => 'm',
          'disability' => 'n',
        }
      )

      expect(subject.rows).to have_key(:title)
      expect(subject.rows).to have_key(:data)
    end
  end

  describe '#data' do
    context 'One line in firm address' do
      subject = described_class.new(
        {
          'answer_equality' => 'yes',
          'ethnic_group' => '01_with_british',
          'gender' => 'm',
          'disability' => 'n',
        }
      )

      it 'shows correct table data' do
        expect(subject.data).to eq(
          [
            { title: 'Equality questions', value: 'yes' },
            { title: 'Defendants ethnic group', value: '01_with_british' },
            { title: 'Defendant identification', value: 'm' },
            { title: 'Defendant disability', value: 'n' }
          ]
        )
      end
    end
  end
end
