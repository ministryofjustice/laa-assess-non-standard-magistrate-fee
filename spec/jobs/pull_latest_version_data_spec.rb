require 'rails_helper'

RSpec.describe PullLatestVersionData do
  let(:claim) do
    instance_double(Claim,
                    id: id,
                    current_version: current_version,
                    assign_attributes: true,
                    save!: true,
                    data: data,
                    namespace: Nsm)
  end
  let(:data) { {} }
  let(:id) { SecureRandom.uuid }
  let(:current_version) { 2 }
  let(:http_puller) { instance_double(HttpPuller, get: http_response) }
  let(:http_response) do
    {
      'version' => 2,
      'json_schema_version' => 1,
      'application_state' => 'submitted',
      'application' => { 'same' => 'data' },
      'events' => events_data
    }
  end
  let(:events_data) { nil }

  before do
    allow(Event::NewVersion).to receive(:build).and_return(true)
    allow(HttpPuller).to receive(:new).and_return(http_puller)
  end

  context 'when current version already exists' do
    let(:data) { { existing: :data } }

    it 'do nothing' do
      expect(subject.perform(claim)).to be_nil
      expect(HttpPuller).not_to have_received(:new)
    end
  end

  context 'when version does not already exist' do
    it 'pulls data via HttpPuller' do
      subject.perform(claim)

      expect(http_puller).to have_received(:get).with(claim)
    end

    context 'when event data exists' do
      let(:claim) { create(:claim, current_version: current_version, data: {}) }
      let(:user) { create(:supervisor) }
      let(:primary_user_id) { user.id }
      let(:events_data) do
        [{
          'submission_version' => 1,
          'primary_user_id' => primary_user_id,
          'secondary_user_id' => nil,
          'linked_type' => nil,
          'linked_id' => nil,
          'details' => { 'to' => 'granted', 'from' => 'submitted', 'field' => 'state', 'comment' => nil },
          'created_at' => '2023-10-02T14:41:45.136Z',
          'updated_at' => '2023-10-02T14:41:45.136Z',
          'public' => true,
          'event_type' => 'Event::Edit'
        }]
      end

      it 'rehydrates the events' do
        subject.perform(claim)
        expect(Event.count).to eq(1)
        expect(Event::Edit.last).to have_attributes(
          submission_id: claim.id,
          submission_version: 1,
          primary_user_id: primary_user_id,
          secondary_user_id: nil,
          linked_type: nil,
          linked_id: nil,
          details: { 'to' => 'granted', 'from' => 'submitted', 'field' => 'state', 'comment' => nil },
          created_at: Time.parse('2023-10-02T14:41:45.136Z'),
          updated_at: Time.parse('2023-10-02T14:41:45.136Z'),
        )
      end

      context 'an no primary user is set' do
        let(:events_data) do
          [{
            'submission_version' => 1,
            'primary_user_id' => nil,
            'secondary_user_id' => nil,
            'linked_type' => nil,
            'linked_id' => nil,
            'details' => {},
            'created_at' => '2023-10-02T14:41:45.136Z',
            'updated_at' => '2023-10-02T14:41:45.136Z',
            'public' => true,
            'event_type' => 'Event::NewVersion'
          }]
        end

        it 'rehydrates the events' do
          subject.perform(claim)
          expect(Event.count).to eq(1)
          expect(Event::NewVersion.last).to have_attributes(
            submission_id: claim.id,
            submission_version: 1,
            primary_user_id: nil,
            secondary_user_id: nil,
            linked_type: nil,
            linked_id: nil,
            details: {},
            created_at: Time.parse('2023-10-02T14:41:45.136Z'),
            updated_at: Time.parse('2023-10-02T14:41:45.136Z'),
          )
        end
      end

      context 'but the associated user does does exist' do
        let(:primary_user_id) { SecureRandom.uuid }

        context 'and it is the production environment' do
          before do
            allow(HostEnv).to receive(:production?).and_return(true)
          end

          it 'does not insert the event and raises and error' do
            expect do
              expect { subject.perform(claim) }.not_to change(Event, :count)
            end.to raise_error(ActiveRecord::InvalidForeignKey)
          end
        end

        context 'and it is not the production environment' do
          it 'creates a new user as it inserts the record' do
            claim
            expect { subject.perform(claim) }.to change(User, :count).by(1)

            expect(Event.count).to eq(1)
            expect(Event::Edit.last).to have_attributes(
              submission_id: claim.id,
              submission_version: 1,
              primary_user_id: primary_user_id,
            )
            expect(Event::Edit.last.primary_user).to have_attributes(
              first_name: primary_user_id.split('-').first,
              role: User::CASEWORKER,
              email: "#{primary_user_id}@fake.com",
              last_name: 'branchbuilder',
              auth_oid: primary_user_id,
              auth_subject_id: primary_user_id
            )
          end
        end
      end
    end

    context 'when pulled version matches current' do
      it 'creates the new version' do
        subject.perform(claim)

        expect(claim).to have_received(:assign_attributes).with(
          json_schema_version: 1,
          data: { 'same' => 'data' }
        )
        expect(claim).to have_received(:save!)
      end

      it 'creates a new version event' do
        subject.perform(claim)

        expect(Event::NewVersion).to have_received(:build).with(submission: claim)
      end
    end

    context 'when pulled version is higher than current' do
      let(:current_version) { 1 }

      it 'do nothing' do
        subject.perform(claim)

        expect(claim).not_to have_received(:assign_attributes)
      end
    end

    context 'when pulled version is lower than current' do
      let(:current_version) { 3 }

      it 'raise an error' do
        expect { subject.perform(claim) }.to raise_error(
          "Correct version not found on AppStore: #{claim.id} - 3 only found 2"
        )
      end
    end
  end

  context 'when pulling prior authority data' do
    let(:http_response) do
      {
        'version' => 1,
        'json_schema_version' => 1,
        'application_state' => 'submitted',
        'application_type' => 'crm4',
        'application' => data,
        'events' => []
      }
    end

    let(:application) { create(:prior_authority_application, current_version: 1, data: nil) }

    context 'when data is valid' do
      let(:data) { build(:prior_authority_data) }

      it 'updates the data' do
        subject.perform(application)
        expect(application.data).to eq data.with_indifferent_access
      end
    end

    context 'when pulled data can be auto-granted' do
      let(:autograntable) { double(Autograntable, grantable?: true) }
      let(:data) { build(:prior_authority_data) }

      before do
        allow(Autograntable).to receive(:new).and_return(autograntable)
        allow(Event::AutoDecision).to receive(:build)
        allow(NotifyAppStore).to receive(:process)
      end

      it 'updates the state to auto-grant' do
        subject.perform(application)
        expect(application.state).to eq('auto-grant')
      end

      it 'create an event record' do
        subject.perform(application)
        expect(Event::AutoDecision).to have_received(:build).with(submission: application, previous_state: 'submitted')
      end

      it 'notifys the app store' do
        subject.perform(application)
        expect(NotifyAppStore).to have_received(:process).with(submission: application)
      end
    end
  end
end
