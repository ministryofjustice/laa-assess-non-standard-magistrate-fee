require 'rails_helper'

RSpec.describe ReceiveApplicationMetadata do
  subject { described_class.new(submission_id) }

  let(:params) do
    { id: submission_id, risk: 'high', current_version: current_version, state: state, application_type: 'crm7' }
  end

  let(:state) { 'submitted' }
  let(:current_version) { 1 }

  before do
    allow(PullLatestVersionData).to receive(:perform_later).and_return(true)
  end

  context 'when submission does not already exits' do
    let(:submission_id) { SecureRandom.uuid }

    it 'creates a new submission' do
      expect { subject.save(params) }.to change(Submission, :count).by(1)
      expect(Submission.last).to have_attributes(
        risk: 'high',
        current_version: 1,
        received_on: Time.zone.today,
        state: 'submitted',
      )
    end

    it 'triggers the pull callback' do
      subject.save(params)

      expect(PullLatestVersionData).to have_received(:perform_later).with(Submission.last)
    end
  end

  context 'when submission already exits' do
    let(:submission) { create(:claim) }
    let(:submission_id) { submission.id }
    let(:state) { 're-submitted' }
    let(:current_version) { 2 }

    before { submission }

    it 'does not create a new submission' do
      expect { subject.save(params) }.not_to change(Submission, :count)
    end

    it 'triggers the pull callback' do
      subject.save(params)

      expect(PullLatestVersionData).to have_received(:perform_later).with(Submission.last)
    end

    it 'updates the existing submission' do
      expect { subject.save(params) }.not_to change(Submission, :count)
      expect(Submission.last).to have_attributes(
        risk: 'high',
        current_version: 2,
        received_on: Date.yesterday,
        state: 're-submitted',
      )
    end
  end

  context 'when submission fails to save' do
    let(:submission) { create(:claim) }
    let(:submission_id) { submission.id }
    let(:current_version) { -1 }

    it 'returns false' do
      expect(subject.save(params)).to be_falsey
    end
  end
end
