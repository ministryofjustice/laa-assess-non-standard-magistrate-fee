# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PriorAuthority::FeedbackMessages::RejectedFeedback do
  subject(:feedback) { described_class.new(application) }

  let(:application) do
    create(
      :prior_authority_application,
      data: build(
        :prior_authority_data,
        laa_reference: 'LAA-FHaMVK',
        ufn: '111111/111',
        solicitor: { 'contact_email' => 'solicitor-contact@example.com' },
        defendant: { 'last_name' => 'Abrahams', 'first_name' => 'Abe' },
      )
    ).tap do |app|
      create(
        :event,
        event_type: Event::Decision.to_s,
        details: {
          comment: 'Caseworker rejected coz...',
        },
        submission: app,
      )
    end
  end

  let(:feedback_template) { '81e9222e-c6bd-4fba-91ff-d90d3d61af87' }
  let(:recipient) { 'provider@example.com' }

  describe '#template' do
    it 'has correct template id' do
      expect(feedback.template).to eq(feedback_template)
    end
  end

  describe '#recipient' do
    it 'sets recipient to be the solicitors contact email' do
      expect(feedback.recipient).to eq('solicitor-contact@example.com')
    end
  end

  describe '#contents' do
    it 'throws a not implemented exception' do
      expect(subject.contents).to include(
        laa_case_reference: 'LAA-FHaMVK',
        ufn: '111111/111',
        defendant_name: 'Abe Abrahams',
        application_total: '£324.50',
        caseworker_decision_explanation: 'Caseworker rejected coz...',
        date: DateTime.now.to_fs(:stamp),
        feedback_url: 'tbc',
      )
    end
  end
end
