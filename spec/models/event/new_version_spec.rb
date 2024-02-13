require 'rails_helper'

RSpec.describe Event::NewVersion do
  subject { described_class.new }

  it 'has a valid title' do
    expect(subject.title).to eq('New claim received')
  end
end
