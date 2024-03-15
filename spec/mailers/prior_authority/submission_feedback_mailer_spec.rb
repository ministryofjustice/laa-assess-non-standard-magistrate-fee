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

  let(:base_application) do
    build(
      :prior_authority_application,
      data: build(
        :prior_authority_data,
        laa_reference: 'LAA-FHaMVK',
        ufn: '111111/111',
        provider: { 'email' => 'provider@example.com' },
        defendant: { 'last_name' => 'Abrahams', 'first_name' => 'Abe' },
      )
    )
  end

  context 'with granted state' do
    let(:application) { base_application.tap { |app| app.update!(state: 'granted') } }
    let(:feedback_template) { 'd4f3da60-4da5-423e-bc93-d9235ff01a7b' }

    let(:personalisation) do
      [laa_case_reference:, ufn:, defendant_name:,
       application_total:, date:, feedback_url:]
    end

    include_examples 'creates a prior authority feedback mailer'
  end

  context 'with part granted state' do
    let(:application) do
      create(
        :prior_authority_application,
        state: 'part_grant',
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
      )
    end

    let(:application_total) { '£300.00' }
    let(:part_grant_total) { '£150.00' }

    let(:feedback_template) { '97c0245f-9fec-4ec1-98cc-c9d392a81254' }
    let(:caseworker_decision_explanation) { '' }

    let(:personalisation) do
      [laa_case_reference:, ufn:, defendant_name:,
       application_total:, part_grant_total:,
       caseworker_decision_explanation:, date:, feedback_url:]
    end

    include_examples 'creates a prior authority feedback mailer'
  end

  context 'with rejected state' do
    let(:application) { base_application.tap { |app| app.update!(state: 'rejected') } }
    let(:feedback_template) { '81e9222e-c6bd-4fba-91ff-d90d3d61af87' }
    let(:caseworker_decision_explanation) { '' }

    let(:personalisation) do
      [laa_case_reference:, ufn:, defendant_name:,
      application_total:, caseworker_decision_explanation:,
      date:, feedback_url:]
    end

    include_examples 'creates a prior authority feedback mailer'
  end

  context 'with further information state' do
    let(:application) { base_application.tap { |app| app.update!(state: 'further_information') } }
    let(:feedback_template) { 'c8abf9ee-5cfe-44ab-9253-72111b7a35ba' }
    let(:date_to_respond_by) { 14.days.from_now.strftime('%d %B %Y') }
    let(:caseworker_information_requested) { '' }

    let(:personalisation) do
      [laa_case_reference:, ufn:, defendant_name:,
       application_total:, date_to_respond_by:,
       caseworker_information_requested:, date:, feedback_url:]
    end

    include_examples 'creates a prior authority feedback mailer'
  end

  context 'with other state for further information request' do
    let(:application) { base_application.tap { |app| app.update!(state: 'fake') } }
    let(:feedback_template) { 'c8abf9ee-5cfe-44ab-9253-72111b7a35ba' }
    let(:date_to_respond_by) { 14.days.from_now.strftime('%d %B %Y') }
    let(:caseworker_information_requested) { '' }

    let(:personalisation) do
      [laa_case_reference:, ufn:, defendant_name:,
       application_total:, date_to_respond_by:,
       caseworker_information_requested:, date:, feedback_url:]
    end

    include_examples 'creates a prior authority feedback mailer'
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
