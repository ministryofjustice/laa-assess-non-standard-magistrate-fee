require 'rails_helper'

RSpec.describe Nsm::AllAdjustmentsDeleter do
  describe '.call' do
    subject(:service) { described_class.new(params, nil, user) }

    let(:params) { { claim_id: claim.id, nsm_delete_adjustments_form: { comment: 'some comment' } } }
    let(:user) { create(:caseworker) }
    let(:claim) { create(:claim, :with_adjustments) }
    let(:client) { instance_double(AppStoreClient, get_submission: app_store_record) }
    let(:app_store_record) do
      {
        'version' => 1,
        'json_schema_version' => 1,
        'application_state' => 'submitted',
        'application_type' => 'crm7',
        'application' => claim.data.merge('adjusted' => false),
        'events' => [],
        'application_id' => claim.id,
      }
    end

    before do
      allow(AppStoreClient).to receive(:new).and_return(client)
      create(:assignment, submission: claim, user: user)
      claim.data.merge('adjusted' => true)
    end

    context 'when deleting disbursement adjustments' do
      before { service.call }

      it 'reverts changes' do
        expect(claim.reload.data['adjusted']).to be false
      end

      it 'creates and event' do
        expect(claim.events.last.details['comment']).to eq('some comment')
      end
    end

    context 'no adjustments' do
      before do
        allow(subject.submission).to receive(:any_adjustments?).and_return(false)
      end

      it 'raises an error if no adjustments' do
        expect { service.call }.to raise_error(StandardError, "no adjustments to delete for id:#{claim.id}")
      end
    end
  end
end
