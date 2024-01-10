require 'rails_helper'

RSpec.describe NotifyAppStore::MessageBuilder do
  subject { described_class.new(claim:) }

  let(:claim) do
    instance_double(Claim, id: SecureRandom.uuid, state: 'granted', risk: 'high', data: { 'version' => 'data' },
   events: events, application_type: 'crm7')
  end
  let(:tester) { double(:tester, process: true) }
  let(:events) do
    [instance_double(Event, as_json: { 'event' => 1 }), instance_double(Event, as_json: { 'event' => 2 })]
  end

  it 'generates and sends the data message for a claim' do
    tester.process(subject.message)

    expect(tester).to have_received(:process).with(
      application: { 'version' => 'data' },
      events: [
        { 'event' => 1 },
        { 'event' => 2 }
      ],
      application_id: claim.id,
      application_state: 'granted',
      application_risk: 'high',
      json_schema_version: 1,
      application_type: 'crm7'
    )
  end
end
