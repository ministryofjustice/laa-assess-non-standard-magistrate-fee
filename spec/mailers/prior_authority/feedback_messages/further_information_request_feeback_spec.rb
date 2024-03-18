# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PriorAuthority::FeedbackMessages::FurtherInformationRequestFeedback do
  subject(:feedback) { described_class.new(application) }

  let(:application) do
    create(
      :prior_authority_application,
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
          comment: 'Caseworker wants...',
        },
        submission: app,
      )
    end
  end

  let(:feedback_template) { 'c8abf9ee-5cfe-44ab-9253-72111b7a35ba' }
  let(:recipient) { 'provider@example.com' }

  describe '#template' do
    it 'has correct template id' do
      expect(feedback.template).to eq(feedback_template)
    end
  end

  describe '#contents' do
    it 'has expected content' do
      expect(feedback.contents).to include(
        laa_case_reference: 'LAA-FHaMVK',
        ufn: '111111/111',
        defendant_name: 'Abe Abrahams',
        application_total: '£324.50',
        date_to_respond_by: 14.days.from_now.to_fs(:stamp),
        caseworker_information_requested: 'Caseworker wants...',
        date: DateTime.now.to_fs(:stamp),
        feedback_url: 'tbc',
      )
    end
  end

  describe '#recipient' do
    it 'has correct recipient' do
      expect(feedback.recipient).to eq('provider@example.com')
    end
  end
end
