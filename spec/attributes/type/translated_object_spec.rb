require 'rails_helper'

RSpec.describe Type::TranslatedObject do
  subject { described_class.new(scope: 'nsm.claim_type') }

  let(:coerced_value) { subject.cast(value).to_s }

  describe 'registry' do
    it 'is registered with type `:translated`' do
      expect(
        ActiveModel::Type.lookup(:translated).is_a?(described_class)
      ).to be(true)
    end

    it 'has an underlying type of `:translated`' do
      expect(subject.type).to eq(:translated)
    end
  end

  describe 'when value is `hash` of translations' do
    let(:value) { { 'en' => 'Apple', 'value' => 'non_standard_magistrate' } }

    it 'ignores the embedded translation and uses the gem' do
      expect(coerced_value).to eq("Non-standard magistrates' court payment")
    end
  end

  describe 'when value is `nil`' do
    let(:value) { nil }

    it { expect(coerced_value).to eq('') }
  end

  describe 'when value is `string`' do
    let(:value) { 'non_standard_magistrate' }

    it 'uses the gem' do
      expect(coerced_value).to eq("Non-standard magistrates' court payment")
    end
  end
end
