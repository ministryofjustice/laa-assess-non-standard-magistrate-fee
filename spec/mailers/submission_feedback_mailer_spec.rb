# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe SubmissionFeedbackMailer, type: :mailer do
  let(:recipient) { 'provider@example.com' }
  let(:laa_case_reference) { 'LAA-FHaMVK' }
  let(:ufn) { '123456/001' }
  let(:main_defendant_name) { 'Tracy Linklater' }
  let(:defendant_reference) { 'MAAT ID: AB12123' }
  let(:claim_total) { 0 }
  let(:date) { DateTime.now.strftime('%d %B %Y') }
  let(:feedback_url) { 'tbc' }

  describe 'granted' do
    context 'with maat id' do
      let(:claim) { build(:claim, state: 'granted') }
      let(:feedback_template) { '80c0dcd2-597b-4c82-8c94-f6e26af71a40' }
      let(:personalisation) do
        [laa_case_reference:, ufn:, main_defendant_name:, defendant_reference:, claim_total:, date:, feedback_url:]
      end

      include_examples 'creates a feedback mailer'
    end

    context 'with cntp id' do
      let(:defendant_reference) { "Client's CNTP number: CNTP12345" }
      let(:claim) do
        build(:claim, state: 'granted').tap do |claim|
          claim.data['cntp_order'] = 'CNTP12345'
          claim.data['defendants'].first['maat'] = nil
        end
      end

      let(:feedback_template) { '80c0dcd2-597b-4c82-8c94-f6e26af71a40' }
      let(:personalisation) do
        [laa_case_reference:, ufn:, main_defendant_name:, defendant_reference:, claim_total:, date:, feedback_url:]
      end

      include_examples 'creates a feedback mailer'
    end
  end

  describe 'part granted' do
    let(:claim) { build(:claim, state: 'part_grant') }
    let(:feedback_template) { '9df38f19-f76b-42f9-a4e1-da36a65d6aca' }
    let(:part_grant_total) { 0 }
    let(:caseworker_decision_explanation) { '' }
    let(:personalisation) do
      [laa_case_reference:, ufn:, main_defendant_name:,
       defendant_reference:, claim_total:, part_grant_total:, caseworker_decision_explanation:,
       date:, feedback_url:]
    end

    include_examples 'creates a feedback mailer'
  end

  describe 'rejected' do
    let(:claim) { build(:claim, state: 'rejected') }
    let(:feedback_template) { '7e807120-b661-452c-95a6-1ae46f411cfe' }
    let(:caseworker_decision_explanation) { '' }
    let(:personalisation) do
      [laa_case_reference:, ufn:, main_defendant_name:, defendant_reference:, claim_total:,
       caseworker_decision_explanation:, date:, feedback_url:]
    end

    include_examples 'creates a feedback mailer'
  end

  describe 'further information' do
    let(:claim) { build(:claim, state: 'further_information') }
    let(:feedback_template) { '9ecdec30-83d7-468d-bec2-cf770a2c9828' }
    let(:date_to_respond_by) { 7.days.from_now.strftime('%d %B %Y') }
    let(:caseworker_information_requested) { '' }
    let(:personalisation) do
      [laa_case_reference:, ufn:, main_defendant_name:,
       defendant_reference:, claim_total:, date_to_respond_by:,
       caseworker_information_requested:, date:, feedback_url:]
    end

    include_examples 'creates a feedback mailer'
  end

  describe 'provider requested' do
    let(:claim) { build(:claim, state: 'provider_requested') }
    let(:feedback_template) { 'bfd28bd8-b9d8-4b18-8ce0-3fb763123573' }
    let(:personalisation) do
      [laa_case_reference:, ufn:, main_defendant_name:, defendant_reference:, claim_total:, date:, feedback_url:]
    end

    include_examples 'creates a feedback mailer'
  end

  describe 'other status' do
    let(:claim) { build(:claim, state: 'fake') }
    let(:feedback_template) { '9ecdec30-83d7-468d-bec2-cf770a2c9828' }
    let(:date_to_respond_by) { 7.days.from_now.strftime('%d %B %Y') }
    let(:caseworker_information_requested) { '' }
    let(:personalisation) do
      [laa_case_reference:, ufn:, main_defendant_name:, defendant_reference:,
       claim_total:, date_to_respond_by:, caseworker_information_requested:,
       date:, feedback_url:]
    end

    include_examples 'creates a feedback mailer'
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
