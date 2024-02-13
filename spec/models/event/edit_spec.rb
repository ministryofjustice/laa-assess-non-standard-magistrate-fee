require 'rails_helper'

RSpec.describe Event::Edit do
  subject { described_class.new }

  it 'is not historical' do
    expect(subject).not_to be_historical
  end
end
