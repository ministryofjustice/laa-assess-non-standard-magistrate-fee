require 'rails_helper'

RSpec.describe NotifyAppStore do
  describe '#process' do
    it { expect(described_class.process).to be_truthy }
  end
end
