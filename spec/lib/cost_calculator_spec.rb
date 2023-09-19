require 'rails_helper'

RSpec.describe CostCalculator do
  subject { described_class.cost(type, object) }

  context 'when type is unknownn' do
    let(:type) { :unknonwn }
    let(:object) { nil }

    it { expect(subject).to be_nil }
  end

  context 'when type is work_item' do
    let(:type) { :work_item }

    context 'when uplift is present' do
      let(:object) { V1::WorkItem.new('time_spent' => 90, 'pricing' => 24.4, 'uplift' => 25) }

      it 'calculates the time * price * uplift' do
        expect(subject).to eq(45.75) # (90 / 60) * 24.4 * (125 / 100)
      end
    end

    context 'when uplift is not set' do
      let(:object) { V1::WorkItem.new('time_spent' => 90, 'pricing' => 24.4, 'uplift' => nil) }

      it 'calculates the time * price' do
        expect(subject).to eq(36.6) # (90 / 60) * 24.4
      end
    end
  end

  context 'when type is disbursement' do
    let(:type) { :disbursement }

    context 'and type is not other' do
      let(:object) do
        V1::Disbursement.new('disbursement_type' => { 'value' => 'car' }, 'miles' => 90, 'pricing' => 0.45,
                             'vat_rate' => 0.2)
      end

      it { expect(subject).to eq(40.5) }
    end

    context 'and type is other' do
      let(:object) do
        V1::Disbursement.new('disbursement_type' => { 'value' => 'other' }, 'total_cost_without_vat' => 45.0,
                             'vat_rate' => 0.2)
      end

      it { expect(subject).to eq(45.0) }
    end
  end
end
