# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nsm::EmailToProviderMailer, type: :mailer do
  let(:recipient) { 'provider@example.com' }
  let(:laa_case_reference) { 'LAA-FHaMVK' }
  let(:ufn) { '123456/001' }
  let(:main_defendant_name) { 'Tracy Linklater' }
  let(:defendant_reference) { 'MAAT ID number: AB12123' }
  let(:claim_total) { '£359.76' }
  let(:date) { DateTime.now.to_fs(:stamp) }

  describe 'granted' do
    context 'with maat id' do
      let(:submission) { build(:claim, state: 'granted', data: data) }
      let(:data) { build(:nsm_data, solicitor: { 'contact_email' => recipient }) }
      let(:feedback_template) { '80c0dcd2-597b-4c82-8c94-f6e26af71a40' }
      let(:personalisation) do
        [laa_case_reference:, ufn:, main_defendant_name:, defendant_reference:, claim_total:, date:]
      end

      include_examples 'creates a feedback mailer'
    end

    context 'with cntp id' do
      let(:defendant_reference) { "Client's CNTP number: CNTP12345" }
      let(:submission) { build(:claim, state: 'granted', data: data) }
      let(:data) do
        build(
          :nsm_data,
          solicitor: { 'contact_email' => recipient },
          cntp_order: 'CNTP12345'
        ).tap do |data|
          data['defendants'].first['maat'] = nil
        end
      end

      let(:feedback_template) { '80c0dcd2-597b-4c82-8c94-f6e26af71a40' }
      let(:personalisation) do
        [laa_case_reference:, ufn:, main_defendant_name:, defendant_reference:, claim_total:, date:]
      end

      include_examples 'creates a feedback mailer'
    end
  end

  describe 'part granted' do
    let(:submission) { build(:claim, state: 'part_grant', data: data) }
    let(:data) { build(:nsm_data, solicitor: { 'contact_email' => recipient }) }
    let(:feedback_template) { '9df38f19-f76b-42f9-a4e1-da36a65d6aca' }
    let(:part_grant_total) { '£359.76' }
    let(:caseworker_decision_explanation) { '' }
    let(:personalisation) do
      [laa_case_reference:, ufn:, main_defendant_name:,
       defendant_reference:, claim_total:, part_grant_total:, caseworker_decision_explanation:,
       date:]
    end

    include_examples 'creates a feedback mailer'
  end

  describe 'rejected' do
    let(:submission) { build(:claim, state: 'rejected', data: data) }
    let(:data) { build(:nsm_data, solicitor: { 'contact_email' => recipient }) }
    let(:feedback_template) { '7e807120-b661-452c-95a6-1ae46f411cfe' }
    let(:caseworker_decision_explanation) { '' }
    let(:personalisation) do
      [laa_case_reference:, ufn:, main_defendant_name:, defendant_reference:, claim_total:,
       caseworker_decision_explanation:, date:]
    end

    include_examples 'creates a feedback mailer'
  end

  describe 'further information' do
    let(:submission) { build(:claim, state: 'sent_back') }
    let(:data) { build(:nsm_data, solicitor: { 'contact_email' => recipient }) }
    let(:feedback_template) { '9ecdec30-83d7-468d-bec2-cf770a2c9828' }
    let(:date_to_respond_by) { 7.days.from_now.to_fs(:stamp) }
    let(:caseworker_information_requested) { '' }
    let(:personalisation) do
      [laa_case_reference:, ufn:, main_defendant_name:,
       defendant_reference:, claim_total:, date_to_respond_by:,
       caseworker_information_requested:, date:]
    end

    include_examples 'creates a feedback mailer'
  end

  describe 'other status' do
    let(:submission) { build(:claim, state: 'submitted') }
    let(:data) { build(:nsm_data, solicitor: { 'contact_email' => recipient }) }
    let(:feedback_template) { '9ecdec30-83d7-468d-bec2-cf770a2c9828' }
    let(:date_to_respond_by) { 7.days.from_now.to_fs(:stamp) }
    let(:caseworker_information_requested) { '' }
    let(:personalisation) do
      [laa_case_reference:, ufn:, main_defendant_name:, defendant_reference:,
       claim_total:, date_to_respond_by:, caseworker_information_requested:,
       date:]
    end

    include_examples 'creates a feedback mailer'
  end

  it_behaves_like 'notification client error handler' do
    let(:submission) { build(:claim, state: 'granted') }
  end
end
