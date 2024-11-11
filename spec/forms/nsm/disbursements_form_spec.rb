require 'rails_helper'

RSpec.describe Nsm::DisbursementsForm do
  let(:claim) do
    create(
      :claim,
      disbursements: [
        {
          'id' => id,
          'details' => 'Details',
          'pricing' => pricing,
          'vat_rate' => vat_rate,
          'apply_vat' => original_apply_vat,
          'miles' => original_miles,
          'total_cost_without_vat' => original_total_cost_without_vat,
          'vat_amount' => vat_amount,
          'other_type' => 'apples',
        }
      ]
    )
  end
  let(:item) do
    BaseViewModel.build(:disbursement, claim, 'disbursements').first
  end
  let(:id) { SecureRandom.uuid }
  let(:total_cost_without_vat) { 100.0 }
  let(:original_total_cost_without_vat) { total_cost_without_vat }
  let(:vat_amount) { 20 }
  let(:vat_rate) { 0.2 }
  let(:miles) { nil }
  let(:original_miles) { nil }
  let(:original_apply_vat) { 'true' }
  let(:apply_vat) { original_apply_vat }
  let(:pricing) { 1.0 }
  let(:form) do
    described_class.new(
      claim:,
      total_cost_without_vat:,
      miles:,
      apply_vat:,
      item:,
      explanation:,
      current_user:
    )
  end
  let(:explanation) { 'change to disbursements' }
  let(:current_user) { create(:caseworker) }
  let(:app_store_client) { instance_double(AppStoreClient, create_events: true) }

  before { allow(AppStoreClient).to receive(:new).and_return(app_store_client) }

  describe '#save' do
    context 'when the form is valid' do
      let(:original_total_cost_without_vat) { total_cost_without_vat + 10 }

      it 'processes the fields and saves the claim' do
        expect(form.save).to be(true)
        expect(claim.data.dig('disbursements', 0, 'total_cost_without_vat')).to eq total_cost_without_vat
        expect(claim.data.dig('disbursements', 0, 'total_cost_without_vat_original')).to eq original_total_cost_without_vat
      end
    end

    context 'VAT is changed' do
      let(:apply_vat) { 'false' }

      it 'processes the fields and saves the claim' do
        expect(form.save).to be(true)
        expect(claim.data.dig('disbursements', 0, 'apply_vat')).to eq 'false'
        expect(claim.data.dig('disbursements', 0, 'apply_vat_original')).to eq original_apply_vat
      end
    end

    context 'when the form is miles-based' do
      let(:original_miles) { 10 }
      let(:original_total_cost_without_vat) { 10 }
      let(:total_cost_without_vat) { nil }
      let(:miles) { 5 }

      it 'processes the fields and saves the claim' do
        expect(form.save).to be(true)
        expect(claim.data.dig('disbursements', 0, 'miles')).to eq miles
        expect(claim.data.dig('disbursements', 0, 'miles_original')).to eq original_miles
      end
    end

    context 'when the form is not valid because nothing has changed' do
      it 'does not continue' do
        expect(form.save).to be(false)
      end
    end
  end
end
