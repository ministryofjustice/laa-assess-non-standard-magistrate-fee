require 'rails_helper'

RSpec.describe NotifyAppStore::MessageBuilder do
  subject { described_class.new(submission:) }

  let(:submission) do
    instance_double(Claim, id: SecureRandom.uuid, state: 'granted', risk: 'high', data: { 'version' => 'data' },
   events: events, application_type: 'crm7')
  end
  let(:tester) { double(:tester, process: true) }
  let(:events) do
    [instance_double(Event, as_json: { 'event' => 1 }), instance_double(Event, as_json: { 'event' => 2 })]
  end

  it 'generates and sends the data message for a submission' do
    tester.process(subject.message)

    expect(tester).to have_received(:process).with(
      application: { 'version' => 'data' },
      events: [
        { 'event' => 1 },
        { 'event' => 2 }
      ],
      application_id: submission.id,
      application_state: 'granted',
      application_risk: 'high',
      json_schema_version: 1,
      application_type: 'crm7'
    )
  end

  context 'when building a PA application' do
    let(:submission) do
      create(:prior_authority_application)
    end

    it 'does not raise an error when validating' do
      expect { subject.message }.not_to raise_error
    end

    context 'when there is a validation issue' do
      before do
        submission.data.delete('status')
      end

      it 'raises an appropriate error' do
        expect { subject.message }.to raise_error do |error|
          expect(error.message).to include submission.id
          expect(error.message).to include "did not contain a required property of 'status'"
        end
      end
    end
  end
end
