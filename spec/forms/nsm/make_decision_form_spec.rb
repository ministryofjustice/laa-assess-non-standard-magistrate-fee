require 'rails_helper'

RSpec.describe Nsm::MakeDecisionForm do
  subject(:form) { described_class.new(params) }

  let(:claim) { create(:claim) }

  describe '#validate' do
    context 'when state is not set' do
      let(:params) { {} }

      it 'is invalid' do
        expect(form).to be_invalid
        expect(form.errors.of_kind?(:state, :inclusion)).to be(true)
      end
    end

    context 'when state is invalid' do
      let(:params) { { claim: claim, state: 'other' } }

      it 'is invalid' do
        expect(form).to be_invalid
        expect(form.errors.of_kind?(:state, :inclusion)).to be(true)
      end
    end

    context 'when state is granted' do
      let(:params) { { claim: claim, state: 'granted' } }

      let(:expected_message) do
        'You cannot grant an application after making adjustments that reduce any of the provider costs. ' \
          'You can either keep those adjustments and part-grant it, or delete those adjustments to accept it'
      end

      context 'with no adjustments' do
        it { expect(form).to be_valid }
      end

      context 'with an increased work item adjustment' do
        before do
          claim.data['work_items'].first['time_spent_original'] = claim.data['work_items'].first['time_spent']
          claim.data['work_items'].first['time_spent'] += 60
          claim.data['work_items'].first['adjustment_comment'] = 'increasing this work item'
          claim.save!
        end

        it 'form object is valid' do
          expect(form).to be_valid
        end
      end

      context 'with a reduced work item adjustment' do
        before do
          claim.data['work_items'].first['time_spent_original'] = claim.data['work_items'].first['time_spent']
          claim.data['work_items'].first['time_spent'] = 0
          claim.data['work_items'].first['adjustment_comment'] = 'reducing this work item'
          claim.save!
        end

        it 'form object is invalid' do
          expect(form).to be_invalid
          expect(form.errors.of_kind?(:state, :invalid)).to be(true)
          expect(form.errors.messages[:state]).to include(expected_message)
        end
      end

      context 'with an increased disbursement adjustment' do
        before do
          disbursement = claim.data['disbursements'].first
          disbursement['total_cost_without_vat_original'] = disbursement['total_cost_without_vat']
          disbursement['total_cost_without_vat'] += 1.0
          disbursement['adjustment_comment'] = 'increasing this disbursement'
          claim.save!
        end

        it 'form object is valid' do
          expect(form).to be_valid
        end
      end

      context 'with a reduced disbursement adjustment' do
        before do
          disbursement = claim.data['disbursements'].first
          disbursement['total_cost_without_vat_original'] = disbursement['total_cost_without_vat']
          disbursement['total_cost_without_vat'] -= 1.0
          disbursement['adjustment_comment'] = 'reducing this disbursement'
          claim.save!
        end

        it 'form object is invalid' do
          expect(form).to be_invalid
          expect(form.errors.of_kind?(:state, :invalid)).to be(true)
          expect(form.errors.messages[:state]).to include(expected_message)
        end
      end

      context 'with an increased letter or call adjustment' do
        before do
          letters = claim.data['letters_and_calls'].find { |ltc| ltc['type']['value'] == 'letters' }
          letters['count_original'] = letters['count']
          letters['count'] += 1
          letters['adjustment_comment'] = 'increasing letter count'
          claim.save!
        end

        it 'form object is valid' do
          expect(form).to be_valid
        end
      end

      context 'with a reduced letter or call adjustment' do
        before do
          letters = claim.data['letters_and_calls'].find { |ltc| ltc['type']['value'] == 'letters' }
          letters['count_original'] = letters['count']
          letters['count'] -= 1
          letters['adjustment_comment'] = 'reducing letter count'
          claim.save!
        end

        it 'form object is invalid' do
          expect(form).to be_invalid
          expect(form.errors.of_kind?(:state, :invalid)).to be(true)
          expect(form.errors.messages[:state]).to include(expected_message)
        end
      end
    end

    context 'when state is part_grant' do
      context 'when partial_comment is blank' do
        let(:params) { { claim: claim, state: 'part_grant', partial_comment: nil } }

        it 'is invalid' do
          expect(form).to be_invalid
          expect(form.errors.of_kind?(:partial_comment, :blank)).to be(true)
        end
      end

      context 'when partial_comment is set' do
        let(:params) { { claim: claim, state: 'part_grant', partial_comment: 'part grant comment' } }

        it { expect(form).to be_valid }
      end
    end

    context 'when state is rejected' do
      context 'when reject_comment is blank' do
        let(:params) { { claim: claim, state: 'rejected', reject_comment: nil } }

        it 'is invalid' do
          expect(form).to be_invalid
          expect(form.errors.of_kind?(:reject_comment, :blank)).to be(true)
        end
      end

      context 'when reject_comment is set' do
        let(:params) { { claim: claim, state: 'rejected', reject_comment: 'reject comment' } }

        it { expect(form).to be_valid }
      end
    end
  end

  describe '#save' do
    let(:user) { instance_double(User) }
    let(:claim) { create(:claim) }
    let(:params) { { claim: claim, state: 'part_grant', partial_comment: 'part comment', current_user: user } }

    before do
      allow(Event::Decision).to receive(:build)
      allow(NotifyAppStore).to receive(:perform_later)
    end

    it { expect(form.save).to be_truthy }

    it 'updates the state' do
      form.save
      expect(claim.reload).to have_attributes(state: 'part_grant')
    end

    it 'adds an assessment comment' do
      form.save
      expect(claim.reload.data).to include('assessment_comment' => 'part comment')
    end

    it 'creates a Decision event' do
      form.save
      expect(Event::Decision).to have_received(:build).with(
        submission: claim, comment: 'part comment', previous_state: 'submitted', current_user: user
      )
    end

    it 'trigger an update to the app store' do
      form.save
      expect(NotifyAppStore).to have_received(:perform_later).with(submission: claim)
    end

    context 'when not valid' do
      let(:params) { {} }

      it { expect(form.save).to be_falsey }
    end

    context 'when error during save' do
      before do
        allow(Claim).to receive(:find_by).and_return(claim)
        allow(claim).to receive(:update!).and_raise('not found')
      end

      it { expect { form.save }.to raise_error('not found') }
    end
  end

  describe '#comment' do
    let(:params) do
      { state: state, partial_comment: 'part comment', reject_comment: 'reject comment', grant_comment: 'grant comment' }
    end

    context 'when state is granted' do
      let(:state) { 'granted' }

      it 'uses the grant comment' do
        expect(form.comment).to eq('grant comment')
      end
    end

    context 'when state is part_grant' do
      let(:state) { 'part_grant' }

      it 'uses the partial_comment field' do
        expect(form.comment).to eq('part comment')
      end
    end

    context 'when state is rejected' do
      let(:state) { 'rejected' }

      it 'uses the reject_comment field' do
        expect(form.comment).to eq('reject comment')
      end
    end

    context 'when state is not set' do
      let(:state) { nil }

      it 'returns nil' do
        expect(form.comment).to be_nil
      end
    end
  end
end
