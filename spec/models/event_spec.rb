require 'rails_helper'

RSpec.describe Event do
  describe '#as_json' do
    it 'generates the desired JSON' do
      event = build(:event, :new_version)
      expect(event.as_json).to match(
        'submission_version' => 1,
        'id' => event.id,
        'created_at' => an_instance_of(String),
        'details' => {},
        'primary_user_id' => nil,
        'secondary_user_id' => nil,
        'updated_at' => an_instance_of(String),
        :event_type => 'new_version',
        :does_not_constitute_update => false,
      )
    end

    context 'when event_type is public' do
      it 'generates the desired public JSON' do
        event = build(:event, :decision)

        expect(event.as_json).to match(
          'submission_version' => 1,
          'id' => event.id,
          'created_at' => an_instance_of(String),
          'details' => { 'from' => 'submitted', 'to' => 'granted' },
          'primary_user_id' => nil,
          'secondary_user_id' => nil,
          'updated_at' => an_instance_of(String),
          :event_type => 'decision',
          :does_not_constitute_update => false,
        )
      end
    end
  end

  describe '.rehydrate' do
    it 'can handle standard events' do
      rehydrated = described_class.rehydrate(
        {
          'event_type' => 'new_version',
          'submission_version' => 3
        },
        'crm4'
      )

      expect(rehydrated).to be_a(Event::NewVersion)
      expect(rehydrated.submission_version).to eq 3
    end

    it 'can handle namespaced events' do
      rehydrated = described_class.rehydrate(
        {
          'event_type' => 'send_back',
          'submission_version' => 3
        },
        'crm4'
      )

      expect(rehydrated).to be_a(PriorAuthority::Event::SendBack)
      expect(rehydrated.submission_version).to eq 3
    end

    it 'can handle unrecognised events' do
      rehydrated = described_class.rehydrate(
        {
          'event_type' => 'edit',
          'submission_version' => 3
        },
        'crm4'
      )

      expect(rehydrated).to be_nil
    end
  end
end
