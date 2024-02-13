require 'rails_helper'

RSpec.describe Event::Unassignment do
  subject do
    described_class.new(details: { 'comment' => 'test comment' },
                        primary_user_id: primary_user_id,
                        secondary_user_id: secondary_user_id)
  end

  let(:primary_user_id) { '123' }

  context 'when user is the same as current user' do
    let(:secondary_user_id) { nil }

    it 'has a valid title' do
      expect(subject.title).to eq('Caseworker removed self from claim')
    end

    it 'leaves the secondary user blank' do
      expect(subject.secondary_user).to be_nil
    end
  end

  context 'when user is different to the current user' do
    let(:secondary_user) { create(:supervisor) }
    let(:secondary_user_id) { secondary_user.id }

    it 'has a valid title' do
      expect(subject.title).to eq('Caseworker removed from claim by super visor')
    end

    it 'populates the secondary user' do
      expect(subject.secondary_user).to eq secondary_user
    end
  end
end
