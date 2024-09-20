require 'rails_helper'

RSpec.describe Nsm::V1::EqualityDetails do
  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Equality monitoring')
    end
  end

  # rubocop:disable RSpec/ExampleLength
  describe '#rows' do
    it 'has correct structure' do
      subject = described_class.new(
        {
          'answer_equality' => 'yes',
          'ethnic_group' => '01_white_british',
          'gender' => 'm',
          'disability' => 'n',
        }
      )

      expect(subject.rows).to have_key(:title)
      expect(subject.rows).to have_key(:data)
    end
  end

  describe '#data' do
    context 'Basic accessibility details' do
      subject { described_class.new(data) }

      let(:answer_equality) { 'yes' }
      let(:data) do
        {
          'answer_equality' => answer_equality,
          'ethnic_group' => '01_white_british',
          'gender' => 'm',
          'disability' => 'n',
        }
      end

      it 'shows correct table data' do
        expect(subject.data).to eq(
          [
            {
              title: 'Equality questions',
              value: TranslationObject.new('yes', 'nsm.answer_equality')
            },
            {
              title: 'Defendants ethnic group',
              value: TranslationObject.new('01_white_british', 'nsm.ethnic_group')
            },
            {
              title: 'Defendant identification',
              value: TranslationObject.new('m', 'nsm.gender')
            },
            {
              title: 'Defendant disability',
              value: TranslationObject.new('n', 'nsm.disability')
            }
          ]
        )
      end

      context 'when answer equality is selected as no' do
        let(:answer_equality) { 'no' }

        it 'shows correct table data' do
          expect(subject.data).to eq(
            [
              {
                title: 'Equality questions',
                value: TranslationObject.new('no', 'nsm.answer_equality')
              },
            ]
          )
        end
      end
    end
  end
  # rubocop:enable RSpec/ExampleLength
end
