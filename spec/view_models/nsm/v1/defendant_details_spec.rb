require 'rails_helper'

RSpec.describe Nsm::V1::DefendantDetails do
  subject { described_class.new(args) }

  let(:args) do
    {
      'defendants' => [
        {
          'id' => '40fb1f88-6dea-4b03-9087-590436b62dd8',
            'maat' => 'AB12123',
            'main' => true,
            'position' => 1,
            'first_name' => 'Main', 'last_name' => 'Defendant'
        },
        {
          'id' => '40fb1f98-6dea-4b03-9087-590436b62dd8',
          'maat' => 'AB454545',
          'main' => false,
          'position' => 2,
          'first_name' => 'Defendant', 'last_name' => '1'
        },
        {
          'id' => '40fb2f88-6dea-4b03-9087-590436b62dd8',
          'maat' => 'AB676767',
          'main' => false,
          'position' => 3,
          'first_name' => 'Defendant', 'last_name' => '2'
        }
      ]
    }
  end

  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Defendant details')
    end
  end

  describe '#rows' do
    it 'has correct structure' do
      expect(subject.rows).to have_key(:title)
      expect(subject.rows).to have_key(:data)
    end
  end

  describe '#data' do
    context 'Main defendant and additional defendants' do
      it 'shows correct table data' do
        expect(subject.data).to eq([
                                     { title: 'Main defendant full name', value: 'Main Defendant' },
                                     { title: 'Main defendant MAAT ID number', value: 'AB12123' },
                                     { title: 'Additional defendant 1 full name', value: 'Defendant 1' },
                                     { title: 'Additional defendant 1 MAAT ID number', value: 'AB454545' },
                                     { title: 'Additional defendant 2 full name', value: 'Defendant 2' },
                                     { title: 'Additional defendant 2 MAAT ID number', value: 'AB676767' }
                                   ])
      end

      context 'when there is no MAAT' do
        let(:args) do
          {
            'defendants' => [
              {
                'id' => '40fb1f88-6dea-4b03-9087-590436b62dd8',
                  'maat' => nil,
                  'main' => true,
                  'position' => 1,
                  'first_name' => 'Main', 'last_name' => 'Defendant'
              },
              {
                'id' => '40fb1f98-6dea-4b03-9087-590436b62dd8',
                'maat' => nil,
                'main' => false,
                'position' => 2,
                'first_name' => 'Defendant', 'last_name' => '1'
              }
            ]
          }
        end

        it 'shows correct table data' do
          expect(subject.data).to eq([
                                       { title: 'Main defendant full name', value: 'Main Defendant' },
                                       { title: 'Additional defendant 1 full name', value: 'Defendant 1' },
                                     ])
        end
      end
    end

    context 'Main defendant and no additional defendants' do
      let(:args) do
        {
          'defendants' => [
            {
              'id' => '40fb1f88-6dea-4b03-9087-590436b62dd8',
                'maat' => 'AB12123',
                'main' => true,
                'position' => 1,
                'first_name' => 'Main', 'last_name' => 'Defendant'
            }
          ]
        }
      end

      it 'shows correct table data' do
        expect(subject.data).to eq([
                                     { title: 'Main defendant full name', value: 'Main Defendant' },
                                     { title: 'Main defendant MAAT ID number', value: 'AB12123' }
                                   ])
      end
    end
  end
end
