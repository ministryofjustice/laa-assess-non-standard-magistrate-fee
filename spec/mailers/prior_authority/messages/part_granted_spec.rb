# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PriorAuthority::Messages::PartGranted do
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
        quotes: [
          build(:primary_quote, :with_adjustments),
        ],
        assessment_comment: 'Caseworker part granted coz...',
      )
    )
  end

  let(:feedback_template) { '97c0245f-9fec-4ec1-98cc-c9d392a81254' }
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
    it 'has expected content' do
      expect(feedback.contents).to include(
        laa_case_reference: 'LAA-FHaMVK',
        ufn: '111111/111',
        defendant_name: 'Abe Abrahams',
        application_total: '£300.00',
        part_grant_total: '£150.00',
        service_required: 'Pathologist report',
        service_provider_details: 'ABC DEF, ABC, HIJ, SW1 1AA',
        caseworker_decision_explanation: 'Caseworker part granted coz...',
        date: DateTime.now.to_fs(:stamp),
      )
    end
  end
end
