require 'rails_helper'

RSpec.shared_examples 'correctly ordered work item results (both ascending and descending)' do |results|
  it { expect(subject).to eq(results) }

  context 'when descending order' do
    let(:sort_direction) { 'descending' }

    it { expect(subject).to eq(results.reverse) }
  end
end

RSpec.describe Sorters::WorkItemsSorter do
  subject { described_class.call(items, sort_by, sort_direction).map(&:id) }

  let(:items) do
    [
      instance_double(Nsm::V1::WorkItem, :id => 'A1', :position => 1, :any_adjustments? => adjustments_a1,
sort_field => sort_value_a1),
      instance_double(Nsm::V1::WorkItem, :id => 'B1', :position => 2, :any_adjustments? => adjustments_b1,
sort_field => sort_value_b1),
      instance_double(Nsm::V1::WorkItem, :id => 'C1', :position => 4, :any_adjustments? => adjustments_c1,
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
    let(:sort_field) { 'uplift' }

    it_behaves_like 'correctly ordered work item results (both ascending and descending)', %w[A1 B1 C1]
  end

  context 'when sorting by work_type' do
    let(:sort_by) { 'cost' }
    let(:sort_field) { 'work_type' }
    let(:sort_value_a1) { 'Waiting' }
    let(:sort_value_b1) { 'Travel' }

    it_behaves_like 'correctly ordered work item results (both ascending and descending)', %w[B1 C1 A1]
  end

  context 'when sorting by completed_on' do
    let(:sort_by) { 'date' }
    let(:sort_field) { 'completed_on' }
    let(:sort_value_a1) { Date.new(2023, 1, 2) }
    let(:sort_value_b1) { Date.new(2023, 1, 4) }
    let(:sort_value_c1) { Date.new(2023, 1, 1) }

    it_behaves_like 'correctly ordered work item results (both ascending and descending)', %w[C1 A1 B1]
  end

  context 'when sorting by claimed uplift' do
    let(:sort_by) { 'claimed_uplift' }
    let(:sort_field) { 'original_uplift' }
    let(:sort_value_a1) { 100 }
    let(:sort_value_b1) { nil } # nil treated as 0
    let(:sort_value_c1) { 100 }

    it_behaves_like 'correctly ordered work item results (both ascending and descending)', %w[B1 A1 C1]
  end

  context 'when sorting by allowed uplift' do
    let(:sort_by) { 'allowed_uplift' }
    let(:sort_field) { 'uplift' }
    let(:sort_value_a1) { 100 }
    let(:sort_value_b1) { nil } # nil treated as 0
    let(:sort_value_c1) { 100 }

    it_behaves_like 'correctly ordered work item results (both ascending and descending)', %w[B1 A1 C1]
  end

  context 'when sorting allowed_net_cost uplift' do
    let(:sort_by) { 'allowed_net_cost' }
    let(:sort_field) { 'caseworker_amount' }
    let(:sort_value_a1) { 75 }
    let(:sort_value_b1) { 100 } # nil treated as 0
    let(:sort_value_c1) { 50 }

    it_behaves_like 'correctly ordered work item results (both ascending and descending)', %w[C1 A1 B1]

    context 'when no adjustments exists on some records' do
      let(:adjustments_b1) { false }

      it_behaves_like 'correctly ordered work item results (both ascending and descending)', %w[B1 C1 A1]
    end
  end
end
