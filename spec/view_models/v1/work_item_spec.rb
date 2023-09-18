require 'rails_helper'

RSpec.describe V1::WorkItem do
  describe 'adjustment' do
    it 'returns pending' do
      summary = described_class.new({})
      expect(summary.adjustment).to eq('#pending#')
    end
  end

  describe 'table_fields' do
    it 'returns the fields for the table display' do
      summary = described_class.new('work_type' => { 'en' => 'waiting' }, 'time_spent' => 61)
      expect(summary.table_fields).to eq(['waiting', '61min', '#pending#'])
    end
  end
end
