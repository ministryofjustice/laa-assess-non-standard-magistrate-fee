# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeedbackMessages::FurtherInformationRequestFeedback do
  subject(:feedback) { described_class.new(claim) }

  let(:claim) { build(:claim) }
  let(:feedback_template) { '9ecdec30-83d7-468d-bec2-cf770a2c9828' }
  let(:recipient) { 'provider@example.com' }
  let(:laa_case_reference) { 'LAA-FHaMVK' }
  let(:ufn) { '123456/001' }
  let(:main_defendant_name) { 'Tracy Linklater' }
  let(:maat_id) { 'AB12123' }
  let(:claim_total) { '' }
  let(:date_to_respond_by) { '' }
  let(:caseworker_information_requested) { '' }
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
                                    date_to_respond_by:,
                                    caseworker_information_requested:,
                                    date:,
                                    feedback_url:)
    end
  end

  describe '#recipient' do
    it 'has correct recipient' do
      expect(subject.recipient).to eq(recipient)
    end
  end
end
