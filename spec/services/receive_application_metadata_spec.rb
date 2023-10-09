require 'rails_helper'

RSpec.describe ReceiveApplicationMetadata do
  subject { described_class.new(claim_id) }

  let(:params) { { id: claim_id, risk: 'high', current_version: current_version } }
  let(:current_version) { 1 }

  before do
    allow(PullLatestVersionData).to receive(:perform_later).and_return(true)
  end

  context 'when claim does not already exits' do
    let(:claim_id) { SecureRandom.uuid }

    it 'creates a new claim' do
      expect { subject.save(params, 'submitted') }.to change(Claim, :count).by(1)
      expect(Claim.last).to have_attributes(
        risk: 'high',
        current_version: 1,
        received_on: Time.zone.today,
        state: 'submitted',
      )
    end

    it 'triggers the pull callback' do
      subject.save(params, 'submitted')

      expect(PullLatestVersionData).to have_received(:perform_later).with(Claim.last)
    end

    context 'but state is not valid' do
      it 'does not create a new claim' do
        expect { subject.save(params, 'grant') }.not_to change(Claim, :count)
      end
    end
  end

  context 'when claim already exits and version is unchanged' do
    let(:claim) { create(:claim) }
    let(:claim_id) { claim.id }

    before { claim }

    it 'does not create a new claim' do
      expect { subject.save(params, 're-submitted') }.not_to change(Claim, :count)
      expect(Claim.last).to have_attributes(
        risk: 'low',
        current_version: 1,
        received_on: Date.yesterday,
        state: 'submitted',
      )
    end

    it 'does not trigger the pull callback' do
      subject.save(params, 'submitted')

      expect(PullLatestVersionData).not_to have_received(:perform_later)
    end
  end

  context 'when claim already exits but the version is changed' do
    let(:claim) { create(:claim) }
    let(:claim_id) { claim.id }
    let(:current_version) { 2 }

    before { claim }

    it 'updates the existing claim' do
      expect { subject.save(params, 'submitted') }.not_to change(Claim, :count)
      expect(Claim.last).to have_attributes(
        risk: 'high',
        current_version: 2,
        received_on: Date.yesterday,
        state: 'submitted',
      )
    end

    it 'does not trigger the pull callback' do
      subject.save(params, 'submitted')

      expect(PullLatestVersionData).to have_received(:perform_later).with(claim)
    end

    context 'but state is not valid' do
      it 'does not update the existing claim' do
        expect { subject.save(params, 'grant') }.not_to change { claim.reload.attributes }
      end
    end
  end

  context 'when claim fails to save' do
    let(:claim) { create(:claim) }
    let(:claim_id) { claim.id }
    let(:current_version) { -1 }

    it 'returns false' do
      expect(subject.save(params, 'submitted')).to be_falsey
    end
  end
end
