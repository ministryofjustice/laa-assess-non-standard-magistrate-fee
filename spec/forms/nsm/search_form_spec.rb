require 'rails_helper'

RSpec.describe Nsm::SearchForm do
  subject { described_class.new }

  describe '#statuses' do
    it 'does not contain auto_grant status' do
      statuses = subject.statuses.map(&:value)
      refute(statuses.include?(:auto_granted))
    end
  end
end
