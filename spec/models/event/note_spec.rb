require 'rails_helper'

RSpec.describe Event::Note do
  subject { described_class.new(details: { 'comment' => 'new note' }) }

  it 'has a valid title' do
    expect(subject.title).to eq('Caseworker note')
  end

  it 'body is set to comment' do
    expect(subject.body).to eq('new note')
  end
end
