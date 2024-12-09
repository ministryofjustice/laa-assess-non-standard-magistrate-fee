require 'rails_helper'

RSpec.describe Nsm::MakeDecisionForm do
  subject(:form) { described_class.new(params) }

  let(:claim) { build(:claim) }

  describe '#validate' do
    context 'when state is not set' do
      let(:params) { { claim: } }

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
        end

        it 'form object is valid' do
          expect(form).to be_valid
        end
      end

      context 'with a reduced work item adjustment' do
        before do
          claim.data['work_items'].first['time_spent_original'] = claim.data['work_items'].first['time_spent']
          claim.data['work_items'].first['time_spent'] -= 1
          claim.data['work_items'].first['adjustment_comment'] = 'reducing this work item'
        end

        it 'form object is invalid' do
          expect(form).to be_invalid
          expect(form.errors.messages[:state]).to include(expected_message)
        end
      end

      context 'with an increased disbursement adjustment' do
        before do
          disbursement = claim.data['disbursements'].first
          disbursement['total_cost_without_vat_original'] = disbursement['total_cost_without_vat']
          disbursement['total_cost_without_vat'] += 1.0
          disbursement['adjustment_comment'] = 'increasing this disbursement'
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
        end

        it 'form object is invalid' do
          expect(form).to be_invalid
          expect(form.errors.messages[:state]).to include(expected_message)
        end
      end

      context 'with an increased letter or call adjustment' do
        before do
          letters = claim.data['letters_and_calls'].find { |ltc| ltc['type'] == 'letters' }
          letters['count_original'] = letters['count']
          letters['count'] += 1
          letters['adjustment_comment'] = 'increasing letter count'
        end

        it 'form object is valid' do
          expect(form).to be_valid
        end
      end

      context 'with a reduced letter or call adjustment' do
        before do
          letters = claim.data['letters_and_calls'].find { |ltc| ltc['type'] == 'letters' }
          letters['count_original'] = letters['count']
          letters['count'] -= 1
          letters['adjustment_comment'] = 'reducing letter count'
        end

        it 'form object is invalid' do
          expect(form).to be_invalid
          expect(form.errors.messages[:state]).to include(expected_message)
        end
      end

      context 'with a mixture of upward and downward adjustments' do
        before do
          work_item = claim.data['work_items'].first
          work_item['time_spent_original'] = work_item['time_spent']
          work_item['time_spent'] += 1
          work_item['adjustment_comment'] = 'reducing this work item'
          letters = claim.data['letters_and_calls'].find { |ltc| ltc['type'] == 'letters' }
          letters['count_original'] = letters['count']
          letters['count'] -= 1
          letters['adjustment_comment'] = 'reducing letter count'
        end

        it 'form object is invalid' do
          expect(form).to be_invalid
          expect(form.errors.messages[:state]).to include(expected_message)
        end
      end
    end

    context 'when state is part_grant with downward adjustments' do
      let(:claim) { build(:claim) }

      before do
        claim.data['work_items'].first['time_spent_original'] = claim.data['work_items'].first['time_spent']
        claim.data['work_items'].first['time_spent'] -= 1
        claim.data['work_items'].first['adjustment_comment'] = 'reducing this work item'
      end

      context 'with blank partial_comment' do
        let(:params) { { claim: claim, state: 'part_grant', partial_comment: nil } }

        it 'is invalid' do
          expect(form).to be_invalid
          expect(form.errors.of_kind?(:partial_comment, :blank)).to be(true)
        end
      end

      context 'with partial_comment set' do
        let(:params) { { claim: claim, state: 'part_grant', partial_comment: 'part grant comment' } }

        it { expect(form).to be_valid }
      end
    end

    context 'when state is part_grant with only upward adjustments' do
      let(:params) { { claim: claim, state: 'part_grant', partial_comment: 'part grant comment' } }

      let(:expected_message) do
        'You can only part-grant an application if you have made adjustments to provider costs where some or all of the ' \
          'adjustments reduce the costs. If you have made adjustments that increase the claim, you should grant it'
      end

      before do
        claim.data['work_items'].first['time_spent_original'] = claim.data['work_items'].first['time_spent']
        claim.data['work_items'].first['time_spent'] += 60
        claim.data['work_items'].first['adjustment_comment'] = 'increasing this work item'
      end

      it 'form object is invalid' do
        expect(form).to be_invalid
        expect(form.errors.messages[:state]).to include(expected_message)
      end
    end

    context 'when state is part_grant with no adjustments' do
      let(:params) { { claim: claim, state: 'part_grant', partial_comment: 'part grant comment' } }

      let(:expected_message) do
        'You can only part-grant an application if you have made adjustments to provider costs where some ' \
          'or all of the adjustments reduce the costs'
      end

      it 'form object is invalid' do
        expect(form).to be_invalid
        expect(form.errors.messages[:state]).to include(expected_message)
      end
    end

    context 'when state is rejected with no adjustments' do
      context 'with blank reject_comment' do
        let(:params) { { claim: claim, state: 'rejected', reject_comment: nil } }

        it 'is invalid' do
          expect(form).to be_invalid
          expect(form.errors.of_kind?(:reject_comment, :blank)).to be(true)
        end
      end

      context 'with reject_comment set' do
        let(:params) { { claim: claim, state: 'rejected', reject_comment: 'reject comment' } }

        it { expect(form).to be_valid }
      end
    end

    context 'when state is rejected with any adjustment' do
      before do
        claim.data['work_items'].first['time_spent_original'] = claim.data['work_items'].first['time_spent']
        claim.data['work_items'].first['time_spent'] -= 1
        claim.data['work_items'].first['adjustment_comment'] = 'reducing this work item'
      end

      context 'with reject_comment set' do
        let(:params) { { claim: claim, state: 'rejected', reject_comment: 'reject comment' } }

        it { expect(form).to be_valid }
      end
    end
  end

  describe '#save' do
    let(:user) { instance_double(User) }
    let(:claim) { build(:claim, data:) }
    let(:data) { build(:nsm_data) }
    let(:params) { { claim: claim, state: 'part_grant', partial_comment: 'part comment', current_user: user } }

    before do
      claim.data['work_items'].first['time_spent_original'] = claim.data['work_items'].first['time_spent']
      claim.data['work_items'].first['time_spent'] -= 1
      claim.data['work_items'].first['adjustment_comment'] = 'reducing this work item'
      allow(Event::Decision).to receive(:build)
      allow(NotifyAppStore).to receive(:perform_now)
    end

    it { expect(form.save).to be_truthy }

    it 'updates the state' do
      expect { form.save }.to change(claim, :state).from('submitted').to('part_grant')
    end

    it 'adds an assessment comment' do
      expect { form.save }.to change { claim.data['assessment_comment'] }.from(nil).to('part comment')
    end

    it 'creates a Decision event' do
      form.save
      expect(Event::Decision).to have_received(:build).with(
        submission: claim, comment: 'part comment', previous_state: 'submitted', current_user: user
      )
    end

    it 'trigger an update to the app store' do
      form.save
      expect(NotifyAppStore).to have_received(:perform_now).with(submission: claim)
    end

    context 'when not valid' do
      let(:params) { { claim: } }

      it { expect(form.save).to be_falsey }
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
