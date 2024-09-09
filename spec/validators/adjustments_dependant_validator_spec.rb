require 'rails_helper'

RSpec.describe AdjustmentsDependantValidator do
  subject(:instance) { klass.new(claim:, state:) }

  let(:klass) do
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ActiveRecord::AttributeAssignment

      def self.model_name
        ActiveModel::Name.new(self, nil, 'temp')
      end

      attribute :state
      attribute :claim

      validates :state, adjustments_dependant: true
    end
  end

  before do
    allow(claim).to receive(:assessment_direction).and_return(direction)
  end

  context 'when state is granted' do
    let(:claim) { create(:claim) }
    let(:state) { 'granted' }

    context 'with a :none assessment direction' do
      let(:direction) { :none }

      it 'form object is valid' do
        expect(instance).to be_valid
      end
    end

    context 'with an :up assessment direction' do
      let(:direction) { :up }

      it 'form object is valid' do
        expect(instance).to be_valid
      end
    end

    context 'with a :down assessment direction' do
      let(:direction) { :down }

      it 'adds :invalid error to attributes' do
        expect(instance).to be_invalid
        expect(instance.errors.of_kind?(:state, :'invalid.granted_with_reductions')).to be(true)
      end
    end

    context 'with a :mixed assessment direction' do
      let(:direction) { :mixed }

      it 'adds :invalid error to attributes' do
        expect(instance).to be_invalid
        expect(instance.errors.of_kind?(:state, :'invalid.granted_with_reductions')).to be(true)
      end
    end
  end

  context 'when state is part grant' do
    let(:claim) { create(:claim) }
    let(:state) { 'part_grant' }

    context 'with a :mixed assessment direction' do
      let(:direction) { :mixed }

      it 'form object is valid' do
        expect(instance).to be_valid
      end
    end

    context 'with a :down assessment direction' do
      let(:direction) { :down }

      it 'form object is valid' do
        expect(instance).to be_valid
      end
    end

    context 'with a :none assessment direction' do
      let(:direction) { :none }

      it 'adds :invalid error to attributes' do
        expect(instance).to be_invalid
        expect(instance.errors.of_kind?(:state, :'invalid.part_granted_without_changes')).to be(true)
      end
    end

    context 'with an :up assessment direction' do
      let(:direction) { :up }

      it 'adds :invalid error to attributes' do
        expect(instance).to be_invalid
        expect(instance.errors.of_kind?(:state, :'invalid.part_granted_with_increases')).to be(true)
      end
    end
  end
end
