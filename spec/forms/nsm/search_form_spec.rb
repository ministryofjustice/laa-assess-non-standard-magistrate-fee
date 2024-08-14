require 'rails_helper'

RSpec.describe Nsm::SearchForm do
  subject { described_class.new }

  describe '#statuses' do
    it 'does not contain auto_grant, provider_updated, expired status' do
      statuses = subject.statuses.map(&:value)
      %i[auto_grant provider_updated expired].each do |status|
        refute(statuses.include?(status))
      end
    end
  end
end
