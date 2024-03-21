# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe PriorAuthority::SubmissionFeedbackMailer, type: :mailer do
  let(:recipient) { 'provider@example.com' }
  let(:laa_case_reference) { 'LAA-FHaMVK' }
  let(:ufn) { '111111/111' }
  let(:defendant_name) { 'Abe Abrahams' }
  let(:application_total) { '£324.50' }
  let(:date) { DateTime.now.to_fs(:stamp) }
  let(:feedback_url) { 'tbc' }

  let(:application) do
    create(
      :prior_authority_application,
      state: state,
      data: build(
        :prior_authority_data,
        laa_reference: 'LAA-FHaMVK',
        ufn: '111111/111',
        provider: { 'email' => 'provider@example.com' },
        defendant: { 'last_name' => 'Abrahams', 'first_name' => 'Abe' },
      )
    ).tap do |app|
      create(
        :event,
        event_type: Event::Decision.to_s,
        details: {
          field: 'state',
          from: 'submitted',
          to: state,
          comment: caseworker_comment,
        },
        submission: app,
        submission_version: app.current_version
      )
    end
  end

  context 'with granted state' do
    let(:state) { 'granted' }
    let(:caseworker_comment) { '' }
    let(:feedback_template) { 'd4f3da60-4da5-423e-bc93-d9235ff01a7b' }

    let(:personalisation) do
      [laa_case_reference:, ufn:, defendant_name:,
       application_total:, date:, feedback_url:]
    end

    include_examples 'creates a prior authority feedback mailer'
  end

  context 'with part granted state' do
    let(:state) { 'part_grant' }

    let(:application) do
      create(
        :prior_authority_application,
        state: state,
        data: build(
          :prior_authority_data,
          laa_reference: 'LAA-FHaMVK',
          ufn: '111111/111',
          provider: { 'email' => 'provider@example.com' },
          defendant: { 'last_name' => 'Abrahams', 'first_name' => 'Abe' },
          quotes: [
            build(:primary_quote, :with_adjustments),
          ]
        )
      ).tap do |app|
        create(
          :event,
          event_type: Event::Decision.to_s,
          details: {
            field: 'state',
            from: 'submitted',
            to: state,
            comment: caseworker_comment,
          },
          submission: app,
          submission_version: app.current_version
        )
      end
    end

    let(:application_total) { '£300.00' }
    let(:part_grant_total) { '£150.00' }

    let(:feedback_template) { '97c0245f-9fec-4ec1-98cc-c9d392a81254' }
    let(:caseworker_decision_explanation) { caseworker_comment }
    let(:caseworker_comment) { 'part granting because...' }

    let(:personalisation) do
      [laa_case_reference:, ufn:, defendant_name:,
       application_total:, part_grant_total:,
       caseworker_decision_explanation:, date:, feedback_url:]
    end

    include_examples 'creates a prior authority feedback mailer'
  end

  context 'with rejected state' do
    let(:state) { 'rejected' }
    let(:caseworker_comment) { 'rejected because...' }
    let(:feedback_template) { '81e9222e-c6bd-4fba-91ff-d90d3d61af87' }
    let(:caseworker_decision_explanation) { caseworker_comment }

    let(:personalisation) do
      [laa_case_reference:, ufn:, defendant_name:,
      application_total:, caseworker_decision_explanation:,
      date:, feedback_url:]
    end

    include_examples 'creates a prior authority feedback mailer'
  end

  context 'with further information state' do
    let(:feedback_template) { 'c8abf9ee-5cfe-44ab-9253-72111b7a35ba' }
    let(:date_to_respond_by) { 14.days.from_now.strftime('%d %B %Y') }

    let(:caseworker_information_requested) do
      "Please correct this information...\n\n" \
        'Please provide this further info...'
    end

    let(:application) do
      create(
        :prior_authority_application,
        state: 'sent_back',
        data: build(
          :prior_authority_data,
          laa_reference: 'LAA-FHaMVK',
          ufn: '111111/111',
          provider: { 'email' => 'provider@example.com' },
          defendant: { 'last_name' => 'Abrahams', 'first_name' => 'Abe' },
          incorrect_information_explanation: 'Please correct this information...',
          further_information_explanation: 'Please provide this further info...',
        )
      ).tap do |app|
        create(
          :event,
          event_type: Event::SendBack.to_s,
          details: {
            comment: 'This message is set but not used by the mailer',
          },
          submission: app,
        )
      end
    end

    let(:personalisation) do
      [laa_case_reference:, ufn:, defendant_name:,
       application_total:, date_to_respond_by:,
       caseworker_information_requested:, date:, feedback_url:]
    end

    include_examples 'creates a prior authority feedback mailer'
  end

  context 'with an unhandled state' do
    let(:application) do
      create(
        :prior_authority_application,
        state: 'submitted',
        data: build(
          :prior_authority_data,
          laa_reference: 'LAA-FHaMVK',
          ufn: '111111/111',
          provider: { 'email' => 'provider@example.com' },
          defendant: { 'last_name' => 'Abrahams', 'first_name' => 'Abe' },
        )
      )
    end

    before do
      allow(Sentry).to receive(:capture_message)
    end

    it 'raises the error' do
      expect { described_class.notify(application).deliver_now }
        .to raise_error(
          described_class::InvalidState,
          "submission with id '#{application.id}' has unhandlable state '#{application.state}'"
        )
    end

    it 'captures the message' do
      described_class.notify(application).deliver_now
    rescue described_class::InvalidState
      expect(Sentry)
        .to have_received(:capture_message)
        .with("submission with id '#{application.id}' has unhandlable state '#{application.state}'")
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
