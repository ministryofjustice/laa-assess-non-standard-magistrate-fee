require 'rails_helper'

RSpec.describe CostItemTypeDependantValidator do
  subject(:instance) { klass.new(cost_per_item:) }

  let(:items_options) { {} }
  let(:klass) do
    # needs to be a local variable to allow use in class definition block
    items_options
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      def self.model_name
        ActiveModel::Name.new(self, nil, 'temp')
      end

      attribute :cost_per_item, :gbp

      validates :cost_per_item, cost_item_type_dependant: true
    end
  end

  context 'when attribute is a positive number' do
    let(:cost_per_item) { 100 }

    it 'form object is valid' do
      expect(instance).to be_valid
    end
  end

  context 'when attribute is a negative number' do
    let(:cost_per_item) { -100 }

    it 'form object is valid' do
      expect(instance).not_to be_valid
    end
  end

  context 'when attribute is nil' do
    let(:cost_per_item) { nil }

    it 'adds blank error' do
      expect(instance).not_to be_valid
      expect(instance.errors.of_kind?(:cost_per_item, :blank)).to be(true)
    end

    it 'adds cost_item_type option to error object' do
      instance.validate
      expect(instance.errors.map(&:options)).to all(include(:item_type))
    end
  end

  context 'when attribute is a string' do
    let(:cost_per_item) { '100 hundred' }

    it 'adds not_a_number error' do
      expect(instance).not_to be_valid
      expect(instance.errors.of_kind?(:cost_per_item, :not_a_number)).to be(true)
    end
  end

  context 'when attribute is zero or' do
    let(:cost_per_item) { 0 }

    it 'adds greater_than error' do
      expect(instance).not_to be_valid
      expect(instance.errors.of_kind?(:cost_per_item, :greater_than)).to be(true)
    end

    context 'when allow_zero is true' do
      let(:items_options) { { allow_zero: true } }

      it 'adds no greater_than error to cost_per_item' do
        expect(instance).not_to be_valid
        expect(instance.errors.of_kind?(:cost_per_item, :greater_than)).to be(true)
      end
    end
  end

  context 'when model has a cost_item_type attribute' do
    subject(:instance) { klass.new(cost_per_item:, cost_item_type:) }

    let(:klass) do
      Class.new do
        include ActiveModel::Model
        include ActiveModel::Attributes

        def self.model_name
          ActiveModel::Name.new(self, nil, 'temp')
        end

        attribute :cost_item_type, :string
        attribute :cost_per_item, :gbp
        validates :cost_per_item, cost_item_type_dependant: true
      end
    end

    let(:cost_per_item) { - 10 }
    let(:cost_item_type) { 'thousand_words' }

    it 'translates unit type' do
      instance.validate
      expect(instance.errors.details[:cost_per_item].flat_map(&:values)).to include('1000 words')
    end
  end
end
