require 'rails_helper'

RSpec.describe Nsm::V1::ClaimSummary do
  describe 'main_defendant_name' do
    it 'returns the name attibute from the main defendant' do
      defendants = [
        { 'main' => false, 'first_name' => 'John', 'last_name' => 'Doe' },
        { 'main' => true, 'first_name' => 'John', 'last_name' => 'Roe' },
      ]
      summary = described_class.new('defendants' => defendants)
      expect(summary.main_defendant_name).to eq('John Roe')
    end

    context 'when no main defendant record - shouold not be possible' do
      it 'returns an empty string' do
        defendants = [
          { 'main' => false, 'first_name' => 'John', 'last_name' => 'Doe' },
        ]
        summary = described_class.new('defendants' => defendants)
        expect(summary.main_defendant_name).to eq('')
      end
    end
  end

  describe 'send_by_post' do
    it 'returns the attribute send by post as bool' do
      send_by_post = true
      summary = described_class.new('send_by_post' => send_by_post)
      expect(summary.send_by_post).to be(true)
    end
  end

  describe '#assiged_to' do
    it 'returns the first assignment' do
      assignment1 = double(:one)
      assignment2 = double(:two)
      assignments = [assignment1, assignment2]
      claim = instance_double(Claim, assignments:)

      summary = described_class.new('submission' => claim)
      expect(summary.assigned_to).to eq(assignment1)
    end
  end

  describe '#assessed_on' do
    context 'when a decision has been made' do
      it 'returns the date from the last Decision event' do
        decision = create(:event, :decision)

        summary = described_class.new('submission' => decision.submission)
        expect(summary.assessed_on).to eq(decision.created_at)
      end
    end

    context 'when no decision has been made' do
      it 'returns nil' do
        summary = described_class.new('submission' => Claim.new)
        expect(summary.assessed_on).to be_nil
      end
    end
  end
end
