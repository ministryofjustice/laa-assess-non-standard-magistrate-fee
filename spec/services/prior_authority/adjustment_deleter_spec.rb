require 'rails_helper'

RSpec.describe PriorAuthority::AdjustmentDeleter do
  describe '.call' do
    subject(:service) { described_class.new(params, adjustment_type, user, application) }

    let(:params) { { application_id: application.id, id: item_id } }
    let(:item_id) { '123' }
    let(:user) { create(:caseworker) }
    let(:application) { build(:prior_authority_application) }
    let(:app_store_client) { instance_double(AppStoreClient, create_events: true, adjust: true) }

    before do
      allow(AppStoreClient).to receive(:new).and_return(app_store_client)
      allow(PriorAuthorityApplication).to receive(:load_from_app_store).and_return(application)
    end

    context 'when adjustment type is unknown' do
      let(:adjustment_type) { :some_new_adjustment }

      it 'raises an appropriate error' do
        expect { service.call }.to raise_error "Unknown adjustment type 'some_new_adjustment'"
      end
    end

    context 'when deleting adjustments' do
      let(:adjustment_type) { :service_cost }
      let(:application) do
        build(:prior_authority_application,
              data: build(:prior_authority_data,
                          quotes: [build(:primary_quote,
                                         id: item_id,
                                         items: 8,
                                         items_original: 9,
                                         adjustment_comment: 'Too many items')]))
      end

      before { service.call! }

      it 'reverts changes' do
        expect(application.data.dig('quotes', 0, 'items')).to eq 9
        expect(application.data.dig('quotes', 0, 'items_original')).to be_nil
        expect(application.data.dig('quotes', 0, 'adjustment_comment')).to be_nil
      end

      it 'creates relevant events' do
        event = application.events.last
        expect(event).to be_a Event::UndoEdit
        expect(event).to have_attributes(
          linked_id: item_id,
          linked_type: 'quotes',
          details: {
            field: 'items',
            from: 8,
            to: 9,
          }
        )
      end
    end
  end
end
