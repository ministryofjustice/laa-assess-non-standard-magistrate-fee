# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PriorAuthority::Messages::Granted do
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
    )
  end

  let(:feedback_template) { 'd4f3da60-4da5-423e-bc93-d9235ff01a7b' }

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
        service_required: 'Pathologist report',
        service_provider_details: 'ABC DEF, ABC, HIJ, SW1 1AA',
        defendant_name: 'Abe Abrahams',
        application_total: '£324.50',
        date: DateTime.now.to_fs(:stamp),
      )
    end
  end
end
