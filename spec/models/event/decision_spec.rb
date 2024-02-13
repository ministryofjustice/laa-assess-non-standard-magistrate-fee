require 'rails_helper'

RSpec.describe Event::Decision do
  subject { described_class.new(details: { 'to' => state, 'comment' => 'decision was made' }) }

  let(:state) { 'granted' }

  it 'has a valid title' do
    expect(subject.title).to eq('Decision made to grant claim')
  end

  context 'when part granted' do
    let(:state) { 'part_grant' }

    it 'has a valid title' do
      expect(subject.title).to eq('Decision made to part grant claim')
    end
  end

  context 'when rejected' do
    let(:state) { 'rejected' }

    it 'has a valid title' do
      expect(subject.title).to eq('Decision made to reject claim')
    end
  end

  it 'body is set to comment' do
    expect(subject.body).to eq('decision was made')
  end
end
