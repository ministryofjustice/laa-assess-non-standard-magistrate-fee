require 'rails_helper'

RSpec.describe V1::WorkItem do
  describe 'adjustment' do
    it 'returns pending' do
      subject = described_class.new
      expect(subject.adjustments).to eq('#pending#')
    end
  end

  describe 'table_fields' do
    it 'returns the fields for the table display' do
      subject = described_class.new('work_type' => { 'en' => 'waiting' }, 'time_spent' => 61)
      expect(subject.table_fields).to eq(['waiting', '0%', '61min', '#pending#', '#pending#'])
    end
  end

  describe 'provider_requested_amount' do
    subject = described_class.new({ pricing: 20, time_spent: 90, uplift: 15 })

    it 'calculates the correct provider requested amount' do
      expect(subject.provider_requested_amount).to eq(34.5)
    end
  end
end
