require 'rails_helper'

RSpec.describe Event do
  describe '#as_json' do
    it 'generates the desired JSON' do
      event = create(:event, :new_version)
      expect(event.as_json).to eq()
    end
  end
end