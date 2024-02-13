require 'rails_helper'

RSpec.describe Event::Assignment do
  subject { described_class.new }

  it 'has a valid title' do
    expect(subject.title).to eq('Claim allocated to caseworker')
  end
end
