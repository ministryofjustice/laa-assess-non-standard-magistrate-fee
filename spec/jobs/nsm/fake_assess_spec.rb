require 'rails_helper'

RSpec.describe Nsm::FakeAssess do
  subject { described_class.new }

  let(:claim) { create(:claim, state: :submitted) }

  context 'when harnessing randomness' do
    before do
      create(:caseworker)
      allow(NotifyAppStore).to receive(:perform_later)
      allow(SecureRandom).to receive(:rand).and_return random_choice
      subject.perform([claim.id])
    end

    context 'when granting claims' do
      let(:random_choice) { 0 }

      context 'when claim is not assessable' do
        let(:claim) { create(:claim, state: :rejected) }

        it 'does not change the claim' do
          expect(claim.reload.state).to eq 'rejected'
        end
      end

      it 'marks as granted' do
        expect(claim.reload.state).to eq 'granted'
      end

      it 'notifies the app store' do
        expect(NotifyAppStore).to have_received(:perform_later).with(submission: claim)
      end
    end

    context 'when part-granting claims' do
      let(:random_choice) { 1 }

      it 'marks as part-granted' do
        expect(claim.reload.state).to eq 'part_grant'
      end

      it 'notifies the app store' do
        expect(NotifyAppStore).to have_received(:perform_later).with(submission: claim)
      end
    end

    context 'when rejecting claims' do
      let(:random_choice) { 2 }

      it 'marks as rejected' do
        expect(claim.reload.state).to eq 'rejected'
      end

      it 'notifies the app store' do
        expect(NotifyAppStore).to have_received(:perform_later).with(submission: claim)
      end
    end

    context 'when sending back claims for further info' do
      let(:random_choice) { 3 }

      it 'marks as sent back' do
        expect(claim.reload.state).to eq 'further_info'
      end

      it 'notifies the app store' do
        expect(NotifyAppStore).to have_received(:perform_later).with(submission: claim)
      end
    end

    context 'when sending back claims as provider requested' do
      let(:random_choice) { 4 }

      it 'marks as sent back' do
        expect(claim.reload.state).to eq 'provider_requested'
      end

      it 'notifies the app store' do
        expect(NotifyAppStore).to have_received(:perform_later).with(submission: claim)
      end
    end
  end

  context 'when randomness goes wrong' do
    before { allow(SecureRandom).to receive(:rand).and_return 5 }

    it 'raises an error' do
      expect { subject.perform([claim.id]) }.to raise_error StandardError
    end
  end
end
