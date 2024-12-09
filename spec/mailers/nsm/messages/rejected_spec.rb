# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nsm::Messages::Rejected do
  subject(:feedback) { described_class.new(claim, caseworker_decision_explanation) }

  let(:claim) { build(:claim, data:) }
  let(:data) { build(:nsm_data, solicitor: { 'contact_email' => recipient }) }
  let(:feedback_template) { '7e807120-b661-452c-95a6-1ae46f411cfe' }
  let(:recipient) { 'provider@example.com' }
  let(:laa_case_reference) { 'LAA-FHaMVK' }
  let(:ufn) { '123456/001' }
  let(:main_defendant_name) { 'Tracy Linklater' }
  let(:defendant_reference) { 'MAAT ID number: AB12123' }
  let(:claim_total) { '£359.76' }
  let(:caseworker_decision_explanation) { 'Test Explanation' }
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
        caseworker_decision_explanation:,
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
