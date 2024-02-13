require 'rails_helper'

RSpec.describe Event::ChangeRisk do
  subject { described_class.new(details: { 'to' => 'low' }) }

  it 'has a valid title' do
    expect(subject.title).to eq('Claim risk changed to low risk')
  end
end
