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
        solicitor: { 'contact_email' => 'solicitor-contact@example.com' },
        defendant: { 'last_name' => 'Abrahams', 'first_name' => 'Abe' },
        incorrect_information_explanation: incorrect_information_explanation,
        further_information_explanation: further_information_explanation,
      )
    ).tap do |app|
      create(
        :event,
        event_type: PriorAuthority::Event::SendBack.to_s,
        details: {
          comment: 'This message is set but not used by the mailer',
        },
        submission: app,
      )
    end
  end

  let(:feedback_template) { 'c8abf9ee-5cfe-44ab-9253-72111b7a35ba' }
  let(:recipient) { 'provider@example.com' }

  let(:incorrect_information_explanation) { '' }
  let(:further_information_explanation) { '' }

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
        application_total: '£324.50',
        date_to_respond_by: 14.days.from_now.to_fs(:stamp),
        date: DateTime.now.to_fs(:stamp),
      )
    end

    context 'with incorrect and further information' do
      let(:incorrect_information_explanation) { 'Please correct this information...' }
      let(:further_information_explanation) { 'Please provide this further info...' }

      it 'has expected content' do
        expect(feedback.contents).to include(
          caseworker_information_requested: "## Amendment request\n\n" \
                                            "Please correct this information...\n\n" \
                                            "## Further information request\n\n" \
                                            'Please provide this further info...',
        )
      end
    end

    context 'with incorrect information request only' do
      let(:incorrect_information_explanation) { 'Please correct this information...' }
      let(:further_information_explanation) { '' }

      it 'has expected content' do
        expect(feedback.contents).to include(
          caseworker_information_requested: "## Amendment request\n\n" \
                                            'Please correct this information...',
        )

        expect(feedback.contents).not_to include('Amendment request')
      end
    end

    context 'with further information request only' do
      let(:incorrect_information_explanation) { '' }
      let(:further_information_explanation) { 'Please provide this further info...' }

      it 'has expected content' do
        expect(feedback.contents).to include(
          caseworker_information_requested: "## Further information request\n\n" \
                                            'Please provide this further info...',
        )

        expect(feedback.contents).not_to include('Further information request')
      end
    end
  end
end
