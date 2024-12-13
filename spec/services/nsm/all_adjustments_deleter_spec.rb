require 'rails_helper'

RSpec.describe Nsm::AllAdjustmentsDeleter do
  describe '.call' do
    subject(:service) { described_class.new(params, nil, user, claim) }

    let(:params) { { claim_id: claim.id, id: item_id, nsm_delete_adjustments_form: { comment: 'test' } } }
    let(:item_id) { '1234-adj' }
    let(:user) { create(:caseworker) }
    let(:claim) { build(:claim, data:) }
    let(:data) { build(:nsm_data, :with_adjustments) }
    let(:app_store_client) { instance_double(AppStoreClient, create_events: true) }

    before do
      allow(AppStoreClient).to receive(:new).and_return(app_store_client)
      allow(Claim).to receive(:load_from_app_store).and_return(claim)
      claim.assigned_user_id = user.id
    end

    context 'when deleting disbursement adjustments' do
      before { service.call }

      it 'reverts changes' do
        expect(claim.data.dig('disbursements', 0, 'total_cost')).to eq 130
        expect(claim.data.dig('disbursements', 0, 'vat_amount')).to eq 1.0
        expect(claim.data.dig('disbursements', 0, 'total_cost_without_vat')).to eq 100
        expect(claim.data.dig('disbursements', 0, 'total_cost_original')).to be_nil
        expect(claim.data.dig('disbursements', 0, 'vat_amount_original')).to be_nil
        expect(claim.data.dig('disbursements', 0, 'total_cost_without_vat_original')).to be_nil
        expect(claim.data.dig('disbursements', 0, 'adjustment_comment')).to be_nil
      end

      it 'creates relevant events' do
        event = claim.events.find { _1.details[:field] == 'total_cost_without_vat' }
        expect(event).to be_a Event::UndoEdit
        expect(event).to have_attributes(
          linked_id: item_id,
          linked_type: 'disbursements',
          details: {
            field: 'total_cost_without_vat',
            from: 130.0,
            to: 100.0,
          }
        )
      end
    end

    context 'when deleting work_item adjustments' do
      before { service.call }

      it 'reverts changes' do
        expect(claim.data.dig('work_items', 0, 'uplift')).to eq 50
        expect(claim.data.dig('work_items', 0, 'work_type')).to eq 'attendance_without_counsel'
        expect(claim.data.dig('work_items', 0, 'time_spent')).to eq 181
        expect(claim.data.dig('work_items', 0, 'uplift_original')).to be_nil
        expect(claim.data.dig('work_items', 0, 'work_type_original')).to be_nil
        expect(claim.data.dig('work_items', 0, 'time_spent_original')).to be_nil
        expect(claim.data.dig('work_items', 0, 'adjustment_comment')).to be_nil
      end

      it 'creates relevant events' do
        event = claim.events.find { _1.details[:field] == 'time_spent' }
        expect(event).to be_a Event::UndoEdit
        expect(event).to have_attributes(
          linked_id: item_id,
          linked_type: 'work_items',
          details: {
            field: 'time_spent',
            from: 161,
            to: 181,
          }
        )
      end
    end

    context 'when deleting calls adjustments' do
      before { service.call }

      it 'reverts call changes' do
        expect(claim.data.dig('letters_and_calls', 1, 'uplift')).to eq 50
        expect(claim.data.dig('letters_and_calls', 1, 'count')).to eq 5
        expect(claim.data.dig('letters_and_calls', 1, 'uplift_original')).to be_nil
        expect(claim.data.dig('letters_and_calls', 1, 'count_original')).to be_nil
        expect(claim.data.dig('letters_and_calls', 1, 'adjustment_comment')).to be_nil
      end

      it 'creates relevant events' do
        event = claim.events.find { _1.linked_type == 'calls' && _1.details[:field] == 'count' }
        expect(event).to be_a Event::UndoEdit
        expect(event).to have_attributes(
          linked_id: nil,
          linked_type: 'calls',
          details: {
            field: 'count',
            from: 4,
            to: 5,
          }
        )
      end
    end

    context 'when deleting letters adjustments' do
      before { service.call }

      it 'reverts letter changes' do
        expect(claim.data.dig('letters_and_calls', 0, 'uplift')).to eq 50
        expect(claim.data.dig('letters_and_calls', 0, 'count')).to eq 5
        expect(claim.data.dig('letters_and_calls', 0, 'uplift_original')).to be_nil
        expect(claim.data.dig('letters_and_calls', 0, 'count_original')).to be_nil
        expect(claim.data.dig('letters_and_calls', 0, 'adjustment_comment')).to be_nil
      end

      it 'creates relevant events' do
        event = claim.events.find { _1.linked_type == 'letters' && _1.details[:field] == 'count' }
        expect(event).to be_a Event::UndoEdit
        expect(event).to have_attributes(
          linked_id: nil,
          linked_type: 'letters',
          details: {
            field: 'count',
            from: 12,
            to: 5,
          }
        )
      end
    end

    context 'deleting youth court fee adjustments' do
      before { service.call }

      it 'reverts youth court fee change' do
        expect(claim.data['include_youth_court_fee']).to be(true)
        expect(claim.data['include_youth_court_fee_original']).to be_nil
        expect(claim.data['youth_court_fee_adjustment_comment']).to be_nil
      end
    end

    context 'no adjustments' do
      it 'wont try to remove disbursement adjustments if none' do
        allow(subject).to receive(:work_items).and_return nil
        expect(subject).not_to receive(:delete_work_item_adjustments)
        subject.call
      end

      it 'wont try to remove work_item adjustments if none' do
        allow(subject).to receive(:letters_and_calls).and_return nil
        expect(subject).not_to receive(:delete_letters_and_calls_adjustments)
        subject.call
      end

      it 'wont try to remove letter and call adjustments if none' do
        allow(subject).to receive(:disbursements).and_return nil
        expect(subject).not_to receive(:delete_disbursement_adjustments)
        subject.call
      end

      it 'wont try to remove youth court fee adjustment if none' do
        allow(subject).to receive(:youth_court_fee_adjustment_comment).and_return nil
        expect(subject).not_to receive(:delete_youth_court_fee_adjustment)
        subject.call
      end
    end
  end
end
