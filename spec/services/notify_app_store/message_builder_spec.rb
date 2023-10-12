require 'rails_helper'

RSpec.describe NotifyAppStore::MessageBuilder do
  subject { described_class.new(claim:) }

  let(:claim) do
    instance_double(Claim, id: SecureRandom.uuid, state: 'grant', risk: 'high', current_version_record: version,
   events: events)
  end
  let(:version) { instance_double(Version, data: { 'version' => 'data' }) }
  let(:tester) { double(:tester, process: true) }
  let(:events) do
    [instance_double(Event, as_json: { 'event' => 1 }), instance_double(Event, as_json: { 'event' => 2 })]
  end

  it 'will generate and send the data message for a claim' do
    tester.process(subject.message)

    expect(tester).to have_received(:process).with(
      application: { 'version' => 'data' },
      events: [
        { 'event' => 1 },
        { 'event' => 2 }
      ],
      application_id: claim.id,
      application_state: 'grant',
      application_risk: 'high',
      json_schema_version: 1
    )
  end
end
