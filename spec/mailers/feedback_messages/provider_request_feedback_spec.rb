# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeedbackMessages::ProviderRequestFeedback do
  subject(:feedback) { described_class.new(claim) }

  let(:claim) { build(:claim) }
  let(:feedback_template) { 'bfd28bd8-b9d8-4b18-8ce0-3fb763123573' }
  let(:recipient) { 'provider@example.com' }
  let(:laa_case_reference) { 'LAA-FHaMVK' }
  let(:ufn) { '123456/001' }
  let(:main_defendant_name) { 'Tracy Linklater' }
  let(:defendant_reference) { 'MAAT ID: AB12123' }
  let(:claim_total) { 0 }
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
        defendant_reference:,
        claim_total:,
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
