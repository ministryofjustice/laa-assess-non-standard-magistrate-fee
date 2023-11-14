require 'rails_helper'

RSpec.describe V1::EqualityDetails do
  subject { described_class.new(params) }

  let(:params) { {} }

  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Equality monitoring')
    end
  end

  describe '#rows' do
    let(:params) do
      {
        'answer_equality' => { 'value' => 'yes', 'en' => 'Yes' },
        'ethnic_group' => { 'value' => '01_white_british', 'en' => 'White british' },
        'gender' => { 'value' => 'm', 'en' => 'Male' },
        'disability' => { 'value' => 'n', 'en' => 'No' },
      }
    end

    it 'has correct structure' do
      expect(subject.rows).to have_key(:title)
      expect(subject.rows).to have_key(:data)
    end
  end

  describe '#data' do
    let(:params) do
      {
        'answer_equality' => { 'value' => 'yes', 'en' => 'Yes' },
        'ethnic_group' => { 'value' => '01_white_british', 'en' => 'White british' },
        'gender' => { 'value' => 'm', 'en' => 'Male' },
        'disability' => { 'value' => 'n', 'en' => 'No' },
      }
    end

    it 'shows correct table data' do
      expect(subject.data).to eq(
        [
          { title: 'Equality questions', value: 'Yes' },
          { title: 'Defendants ethnic group', value: 'White british' },
          { title: 'Defendant identification', value: 'Male' },
          { title: 'Defendant disability', value: 'No' }
        ]
      )
    end

    context 'when no values entered' do
      let(:params) do
        {
          'answer_equality' => { 'value' => 'no', 'en' => 'No' },
          'ethnic_group' => nil,
          'gender' => nil,
          'disability' => nil,
        }
      end

      it 'shows correct table data' do
        expect(subject.data).to eq(
          [
            { title: 'Equality questions', value: 'No' },
            { title: 'Defendants ethnic group', value: '' },
            { title: 'Defendant identification', value: '' },
            { title: 'Defendant disability', value: '' }
          ]
        )
      end
    end
  end
end
