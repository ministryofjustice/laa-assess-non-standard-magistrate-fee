require 'rails_helper'

RSpec.describe AppStoreService do
  include StubHelpers

  let(:fixed_arbitrary_date) { Time.zone.local(2023, 2, 1, 9, 0) }
  let(:token_provider) { instance_double(AppStore::TokenProvider, bearer_token: 'token') }
  let(:user) { create(:caseworker) }
  let(:existing_submission) { build(:claim, data: { foo: :bar }) }
  let(:application_hash) do
    {
      application_type: application_type,
      application_state: 'submitted',
      application_risk: 'low',
      application_id: '123',
      version: 1,
      updated_at: 1.day.ago,
      created_at: 2.days.ago,
      json_schema_version: 1,
      application: {
        foo: :bar
      },
      assigned_user_id: user.id,
      events: [{ event_type: 'new_version', created_at: 1.day.ago }]
    }
  end

  let(:application_type) { 'crm7' }

  let(:submission_attributes) do
    {
      state: 'submitted',
      id: '123',
      risk: 'low',
      current_version: 1,
      json_schema_version: 1,
      data: { 'foo' => 'bar' },
      assigned_user: user,
      created_at: 2.days.ago,
      updated_at: 1.day.ago
    }
  end

  let(:serialised_claim) do
    { 'application_id' => existing_submission.id,
      'json_schema_version' => 1,
      'application_type' => 'crm7',
      'application_state' => 'submitted',
      'application' => { 'foo' => 'bar' },
      'events' => [],
      'application_risk' => 'low',
      'foo' => 'bar' }
  end

  before do
    travel_to fixed_arbitrary_date
    allow(AppStore::TokenProvider).to receive(:instance).and_return(token_provider)
  end

  describe '.list' do
    context 'when returning claims' do
      it 'passes in params' do
        stub = stub_api_request(
          :get,
          '/v1/submissions?application_type=crm7&assessed=true',
          response: { applications: [], total: 0 }
        )
        claims, total = described_class.list(application_type: 'crm7', assessed: true)
        expect(total).to eq 0
        expect(claims).to eq []
        expect(stub).to have_been_requested
      end

      it 'hydrates claims' do
        stub_api_request(
          :get,
          '/v1/submissions?application_type=crm7&assessed=true',
          response: { applications: [application_hash], total: 1 }
        )
        claims, = described_class.list(application_type: 'crm7', assessed: true)
        claim = claims.first
        expect(claim).to be_a Claim
        expect(claim).to have_attributes(submission_attributes)
        expect(claim.events.first).to be_a Event::NewVersion
      end

      it 'raises errors on unexpected outcomes' do
        stub_api_request(
          :get,
          '/v1/submissions?application_type=crm7',
          status: 500
        )

        expect { described_class.list(application_type: 'crm7') }.to raise_error(
          "Unexpected response from AppStore - status 500 for '/v1/submissions'"
        )
      end
    end

    context 'when returning PA applications' do
      let(:application_type) { 'crm4' }

      it 'hydrates applications' do
        stub_api_request(
          :get,
          '/v1/submissions?application_type=crm4',
          response: { applications: [application_hash], total: 1 }
        )
        applications, = described_class.list(application_type: 'crm4')
        application = applications.first
        expect(application).to be_a PriorAuthorityApplication
        expect(application).to have_attributes(submission_attributes)
      end
    end
  end

  describe '.get' do
    it 'hydrates a single submission' do
      stub_api_request(
        :get,
        '/v1/submissions/123',
        response: application_hash.merge(assigned_user_id: nil)
      )
      claim = described_class.get('123')
      expect(claim).to be_a Claim
      expect(claim).to have_attributes(submission_attributes.merge(assigned_user: nil))
      expect(claim.events.first).to be_a Event::NewVersion
    end

    it 'raises errors on unexpected outcomes' do
      stub_api_request(
        :get,
        '/v1/submissions/123',
        status: 500
      )

      expect { described_class.get('123') }.to raise_error(
        "Unexpected response from AppStore - status 500 for '/v1/submissions/123'"
      )
    end
  end

  describe '.assign' do
    it 'hydrates a single submission if one is returned' do
      stub_api_request(
        :post,
        '/v1/submissions/assignments',
        body: { user_id: '123', application_type: 'crm7' },
        response: application_hash
      )
      claim = described_class.assign('123', 'crm7')
      expect(claim).to be_a Claim
      expect(claim).to have_attributes(submission_attributes)
      expect(claim.events.first).to be_a Event::NewVersion
    end

    it 'returns nothing if no submission is found' do
      stub_api_request(
        :post,
        '/v1/submissions/assignments',
        body: { user_id: '123', application_type: 'crm7' },
        status: 404
      )
      ret = described_class.assign('123', 'crm7')
      expect(ret).to be_nil
    end
  end

  describe '.unassign' do
    it 'fires an appropriate request' do
      stub = stub_api_request(
        :delete,
        "/v1/submissions/#{existing_submission.id}/assignment",
        body: { comment: 'foo', user_id: user.id },
        response: application_hash
      )
      described_class.unassign(existing_submission, 'foo', user)
      expect(stub).to have_been_requested
    end
  end

  describe '.change_risk' do
    it 'fires an appropriate request' do
      stub = stub_api_request(
        :post,
        "/v1/submissions/#{existing_submission.id}/risk_changes",
        body: { comment: 'foo', user_id: '123', application_risk: 'low' }
      )
      described_class.change_risk(existing_submission, comment: 'foo', user_id: '123', application_risk: 'low')
      expect(stub).to have_been_requested
    end
  end

  describe '.create_note' do
    it 'fires an appropriate request' do
      stub = stub_api_request(
        :post,
        "/v1/submissions/#{existing_submission.id}/notes",
        body: { note: 'foo', user_id: '123' }
      )
      described_class.create_note(existing_submission, note: 'foo', user_id: '123')
      expect(stub).to have_been_requested
    end
  end

  describe '.change_state' do
    it 'fires an appropriate request' do
      stub = stub_api_request(
        :post,
        "/v1/submissions/#{existing_submission.id}/state_changes",
        body: { comment: 'foo', user_id: '123', application_state: 'granted' }
      )
      described_class.change_state(existing_submission, comment: 'foo', user_id: '123', application_state: 'granted')
      expect(stub).to have_been_requested
    end
  end

  describe '.adjust' do
    it 'fires an appropriate request' do
      stub = stub_api_request(
        :post,
        "/v1/submissions/#{existing_submission.id}/adjustments",
        body: serialised_claim
      )
      described_class.adjust(existing_submission, { foo: :bar })
      expect(stub).to have_been_requested
    end
  end
end
