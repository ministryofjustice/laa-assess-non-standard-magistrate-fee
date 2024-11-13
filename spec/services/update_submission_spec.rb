require 'rails_helper'

RSpec.describe UpdateSubmission, :stub_oauth_token do
  let(:record) do
    {
      'application_id' => submission_id,
      'version' => current_version,
      'application_state' => state,
      'application_risk' => 'high',
      'updated_at' => 10,
      'application_type' => 'crm7',
      'events' => events_data,
    }
  end
  let(:state) { 'submitted' }
  let(:current_version) { 1 }
  let(:events_data) { nil }
  let(:submission_id) { nil }

  context 'when submission does not already exist' do
    let(:submission_id) { SecureRandom.uuid }

    it 'creates a new submission' do
      expect { described_class.call(record) }.to change(Submission, :count).by(1)
      expect(Submission.last).to have_attributes(
        risk: 'high',
        current_version: 1,
        received_on: Time.zone.today,
        state: 'submitted',
      )
    end
  end

  context 'when submission already exists' do
    let(:submission) { create(:claim, state:) }
    let(:submission_id) { submission.id }
    let(:state) { 'granted' }
    let(:current_version) { 2 }

    before { submission }

    it 'does not create a new submission' do
      expect { described_class.call(record) }.not_to change(Submission, :count)
    end

    it 'updates the existing submission' do
      described_class.call(record)
      expect(submission.reload).to have_attributes(
        risk: 'high',
        current_version: 2,
        received_on: Date.yesterday,
        state: 'granted',
      )
    end

    context 'when event data is provided' do
      let(:user) { create(:supervisor) }
      let(:primary_user_id) { user.id }
      let(:event_id) { SecureRandom.uuid }
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
          'event_type' => 'edit',
          'id' => event_id,
        }]
      end

      it 'rehydrates the events' do
        described_class.call(record)
        expect(Event::Edit.last).to have_attributes(
          submission_id: submission_id,
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

      context 'when event already exists in the local database' do
        before do
          create(:event, submission: submission, id: events_data.dig(0, 'id'))
        end

        it 'does not create another one' do
          expect { described_class.call(record) }.not_to change(Event::Edit, :count)
        end
      end

      context 'and no primary user is set' do
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
            'event_type' => 'new_version',
            'id' => event_id,
          }]
        end

        it 'rehydrates the events' do
          described_class.call(record)
          expect(Event.count).to eq(1)
          expect(Event.find(event_id)).to have_attributes(
            submission_id: submission.id,
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

      context 'but the associated user does does not exist' do
        let(:primary_user_id) { SecureRandom.uuid }

        context 'and it is the production environment' do
          before do
            allow(HostEnv).to receive(:production?).and_return(true)
          end

          it 'does not insert the event and raises and error' do
            expect do
              expect { described_class.call(record) }.not_to change(Event, :count)
            end.to raise_error(ActiveRecord::InvalidForeignKey)
          end
        end

        context 'and it is not the production environment' do
          it 'creates a new user as it inserts the record' do
            submission
            expect { described_class.call(record) }.to change(User, :count).by(1)

            expect(Event.count).to eq(1)
            expect(Event::Edit.last).to have_attributes(
              submission_id: submission.id,
              submission_version: 1,
              primary_user_id: primary_user_id,
            )
            expect(Event::Edit.last.primary_user).to have_attributes(
              first_name: primary_user_id.split('-').first,
              email: "#{primary_user_id}@fake.com",
              last_name: 'branchbuilder',
              auth_oid: primary_user_id,
              auth_subject_id: primary_user_id
            )
          end
        end
      end

      context 'when event is namespaced' do
        let(:events_data) do
          [{
            'submission_version' => 1,
            'primary_user_id' => primary_user_id,
            'public' => true,
            'event_type' => 'send_back',
            'id' => event_id
          }]
        end

        it 'rehydrates the event using the appropriate namespace' do
          described_class.call(record)
          expect(Event.find(event_id)).to be_a(Nsm::Event::SendBack)
        end
      end
    end
  end

  context 'when pulling prior authority data' do
    let(:record) do
      {
        'version' => 1,
        'json_schema_version' => 1,
        'application_state' => 'submitted',
        'application_type' => 'crm4',
        'application' => data,
        'events' => [],
        'application_id' => application.id
      }
    end

    let(:application) { create(:prior_authority_application, current_version: 1, data: nil) }

    context 'when data is valid' do
      let(:data) { build(:prior_authority_data) }

      it 'updates the data' do
        described_class.call(record)
        expect(application.reload.data).to eq data.with_indifferent_access
      end
    end
  end
end
