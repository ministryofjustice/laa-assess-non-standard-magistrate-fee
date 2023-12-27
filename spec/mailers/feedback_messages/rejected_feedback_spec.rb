# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeedbackMessages::RejectedFeedback do
  subject(:feedback) { described_class.new(claim, caseworker_decision_explanation) }

  let(:claim) { build(:claim) }
  let(:feedback_template) { '7e807120-b661-452c-95a6-1ae46f411cfe' }
  let(:recipient) { 'provider@example.com' }
  let(:laa_case_reference) { 'LAA-FHaMVK' }
  let(:ufn) { '123456/001' }
  let(:main_defendant_name) { 'Tracy Linklater' }
  let(:maat_id) { 'AB12123' }
  let(:claim_total) { nil }
  let(:caseworker_decision_explanation) { 'Test Explanation' }
  let(:date) { DateTime.now.strftime('%d %B %Y') }
  let(:feedback_url) { 'tbc' }

  describe '#template' do
    it 'has correct template id' do
      expect(subject.template).to eq(feedback_template)
    end
  end

  describe '#contents' do
    it 'throws a not implemented exception' do
      expect(subject.contents).to include(
        laa_case_reference:,
        ufn:,
        main_defendant_name:,
        maat_id:,
        claim_total:,
        caseworker_decision_explanation:,
        date:,
        feedback_url:
      )
    end
  end

  describe '#recipient' do
    it 'has correct recipient' do
      expect(subject.recipient).to eq(recipient)
    end
  end
end
