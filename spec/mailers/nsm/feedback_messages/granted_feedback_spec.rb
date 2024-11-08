# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nsm::FeedbackMessages::GrantedFeedback do
  subject(:feedback) { described_class.new(claim) }

  let(:claim) { build(:claim) }
  let(:feedback_template) { '80c0dcd2-597b-4c82-8c94-f6e26af71a40' }
  let(:recipient) { 'provider@example.com' }
  let(:laa_case_reference) { 'LAA-FHaMVK' }
  let(:ufn) { '123456/001' }
  let(:main_defendant_name) { 'Tracy Linklater' }
  let(:defendant_reference) { 'MAAT ID number: AB12123' }
  let(:claim_total) { '£359.76' }
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
