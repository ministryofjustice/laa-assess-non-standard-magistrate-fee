require 'rails_helper'

RSpec.describe V1::WorkItem do
  describe 'adjustment' do
    it 'returns pending' do
      summary = described_class.new({})
      expect(summary.adjustment).to eq('#pending#')
    end
  end
end
