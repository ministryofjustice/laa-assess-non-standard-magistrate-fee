# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nsm::FeedbackMessages::FurtherInformationRequestFeedback do
  subject(:feedback) { described_class.new(claim, caseworker_information_requested) }

  let(:claim) { build(:claim) }
  let(:feedback_template) { '9ecdec30-83d7-468d-bec2-cf770a2c9828' }
  let(:recipient) { 'provider@example.com' }
  let(:laa_case_reference) { 'LAA-FHaMVK' }
  let(:ufn) { '123456/001' }
  let(:main_defendant_name) { 'Tracy Linklater' }
  let(:defendant_reference) { 'MAAT ID: AB12123' }
  let(:claim_total) { '£325.97' }
  let(:date_to_respond_by) { 7.days.from_now.to_fs(:stamp) }
  let(:caseworker_information_requested) { 'Test Request' }
  let(:date) { DateTime.now.to_fs(:stamp) }

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
        date_to_respond_by:,
        caseworker_information_requested:,
        date:,
      )
    end
  end

  describe '#recipient' do
    it 'has correct recipient' do
      expect(subject.recipient).to eq(recipient)
    end
  end
end
