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
          'first_name' => 'Defendant', 'last_name' => '2'
        },
        {
          'id' => '40fb2f88-6dea-4b03-9087-590436b62dd8',
          'maat' => 'AB676767',
          'main' => false,
          'position' => 3,
          'first_name' => 'Defendant', 'last_name' => '3'
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
                                     { title: "Defendant 1 (lead)", value: "Main Defendant<br>AB12123" },
                                     { title: "Defendant 2", value: "Defendant 2<br>AB454545" },
                                     { title: "Defendant 3", value: "Defendant 3<br>AB676767" },
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
                'first_name' => 'Defendant', 'last_name' => '2'
              }
            ]
          }
        end

        it 'shows correct table data' do
          expect(subject.data).to eq([
                                       { title: "Defendant 1 (lead)", value: "Main Defendant" },
                                       { title: "Defendant 2", value: "Defendant 2" },
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
                                     { title: "Defendant 1 (lead)", value: 'Main Defendant<br>AB12123' }
                                   ])
      end
    end
  end
end
