require 'rails_helper'

RSpec.shared_examples 'a correctly ordered results (both ascending and descending)' do |results|
  it { expect(subject).to eq(results) }

  context 'when descending order' do
    let(:sort_direction) { 'descending' }

    it { expect(subject).to eq(results.reverse) }
  end
end

RSpec.describe Sorters::DisbursementsSorter do
  subject { described_class.call(items, sort_by, sort_direction).map(&:id) }

  let(:items) do
    [
      instance_double(Nsm::V1::Disbursement, :id => 'A1', :position => 1, :any_adjustments? => adjustments_a1,
sort_field => sort_value_a1),
      instance_double(Nsm::V1::Disbursement, :id => 'B1', :position => 2, :any_adjustments? => adjustments_b1,
sort_field => sort_value_b1),
      instance_double(Nsm::V1::Disbursement, :id => 'C1', :position => 4, :any_adjustments? => adjustments_c1,
sort_field => sort_value_c1),
    ]
  end
  let(:sort_value_a1) { nil }
  let(:sort_value_b1) { sort_value_a1 }
  let(:sort_value_c1) { sort_value_b1 }
  let(:sort_field) { sort_by }
  let(:sort_direction) { 'ascending' }
  let(:adjustments_a1) { true }
  let(:adjustments_b1) { true }
  let(:adjustments_c1) { true }

  context 'when sorting by position' do
    let(:sort_by) { 'item' }
    let(:sort_field) { 'type_name' }

    it_behaves_like 'a correctly ordered results (both ascending and descending)', %w[A1 B1 C1]
  end

  context 'when sorting by type_name' do
    let(:sort_by) { 'cost' }
    let(:sort_field) { 'type_name' }
    let(:sort_value_a1) { 'Waiting' }
    let(:sort_value_b1) { 'Travel' }

    it_behaves_like 'a correctly ordered results (both ascending and descending)', %w[B1 C1 A1]
  end

  context 'when sorting by completed_on' do
    let(:sort_by) { 'date' }
    let(:sort_field) { 'disbursement_date' }
    let(:sort_value_a1) { Date.new(2023, 1, 2) }
    let(:sort_value_b1) { Date.new(2023, 1, 4) }
    let(:sort_value_c1) { Date.new(2023, 1, 1) }

    it_behaves_like 'a correctly ordered results (both ascending and descending)', %w[C1 A1 B1]
  end

  context 'when sorting allowed_gross uplift' do
    let(:sort_by) { 'allowed_gross' }
    let(:sort_field) { 'caseworker_total_cost' }
    let(:sort_value_a1) { 75 }
    let(:sort_value_b1) { 100 } # nil treated as 0
    let(:sort_value_c1) { 50 }

    it_behaves_like 'a correctly ordered results (both ascending and descending)', %w[C1 A1 B1]

    context 'when no adjustments exists on some records' do
      let(:adjustments_b1) { false }

      it_behaves_like 'a correctly ordered results (both ascending and descending)', %w[B1 C1 A1]
    end
  end
end
