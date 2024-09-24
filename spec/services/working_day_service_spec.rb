require 'rails_helper'

RSpec.describe WorkingDayService do
  subject { described_class.call(days_to_increment) }

  before do
    travel_to date_to_test
    stub_request(:get, 'https://www.gov.uk/bank-holidays.json').to_return(
      status: 200,
      body: bank_holiday_list.to_json,
      headers: { 'Content-type' => 'application/json' }
    )
  end

  let(:bank_holiday_list) do
    {
      'england-and-wales': {
        events: [
          { date: '2024-01-01' }
        ]
      }
    }
  end

  let(:a_september_tuesday) { DateTime.new(2024, 9, 24, 12, 23, 0) }
  let(:a_september_thursday) { DateTime.new(2024, 9, 26, 12, 23, 0) }
  let(:friday_29_december) { DateTime.new(2023, 12, 29, 12, 23, 0) }

  let(:days_to_increment) { 2 }

  context 'when no weekends or bank holidays are involved' do
    let(:date_to_test) { a_september_tuesday }

    it 'skips forward the number of days specified' do
      expect(subject).to eq 2.days.from_now
    end
  end

  context 'when navigating a weekend' do
    let(:date_to_test) { a_september_thursday }

    it 'skips forward the number of working days specified' do
      expect(subject).to eq 4.days.from_now
    end
  end

  context 'when navigating a bank holiday and weekends' do
    let(:date_to_test) { friday_29_december }

    it 'skips weekends and bank holidays' do
      expect(subject).to eq 5.days.from_now
    end
  end
end
