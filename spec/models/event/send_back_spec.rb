require 'rails_helper'

RSpec.describe Event::SendBack do
  subject { described_class.new(details: { 'comment' => 'decision was made', 'to' => 'further_info' }) }

  it 'has a valid title' do
    expect(subject.title).to eq('Claim sent back to provider')
  end

  it 'body is set to comment' do
    expect(subject.body).to eq('decision was made')
  end
end
