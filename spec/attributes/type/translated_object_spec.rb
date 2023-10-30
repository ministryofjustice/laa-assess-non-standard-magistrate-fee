require 'rails_helper'

RSpec.describe Type::TranslatedObject do
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
    let(:value) { { 'en' => 'Apple', 'value' => 'apple', 'cy' => 'Afal' } }

    before { allow(I18n).to receive(:locale).and_return(locale) }

    context 'when locale is english' do
      let(:locale) { :en }

      it { expect(coerced_value).to eq('Apple') }
    end

    context 'when locale is welsh' do
      let(:locale) { :cy }

      it { expect(coerced_value).to eq('Afal') }
    end

    context 'when locale is unknown it returns the `value`' do
      let(:locale) { :ru }

      it { expect(coerced_value).to eq('apple') }
    end
  end

  describe 'when value is `nil`' do
    let(:value) { nil }

    it { expect(coerced_value).to eq('') }
  end

  describe 'when value is `Array`' do
    let(:value) { ['Apple'] }

    it { expect { coerced_value }.to raise_error('Invalid Type for ["Apple"]') }
  end

  describe 'when value is `string`' do
    let(:value) { 'Apple' }

    it { expect { coerced_value }.to raise_error('Invalid Type for "Apple"') }
  end

  describe '#serialize' do
    let(:value) { 'Apple' }

    it 'raises an error' do
      expect { subject.serialize(value) }.to raise_error('Value cannot be re-serialized')
    end
  end

  context 'when `array:true` is passed in' do
    subject { described_class.new(array: true) }

    describe 'when value is `hash` of translations' do
      let(:value) { { 'en' => 'Apple', 'value' => 'apple', 'cy' => 'Afal' } }

      it { expect { coerced_value }.to raise_error('Invalid Type for {"en"=>"Apple", "value"=>"apple", "cy"=>"Afal"}') }
    end

    describe 'when value is `nil`' do
      let(:value) { nil }

      it { expect(coerced_value).to eq('') }
    end

    describe 'when value is `Array`' do
      let(:value) { [{ 'en' => 'Apple', 'value' => 'apple', 'cy' => 'Afal' }] }
      let(:locale) { :en }

      before { allow(I18n).to receive(:locale).and_return(locale) }

      context 'when locale is english' do
        it { expect(coerced_value).to eq(['Apple']) }
      end

      context 'when locale is welsh' do
        let(:locale) { :cy }

        it { expect(coerced_value).to eq(['Afal']) }
      end

      context 'when locale is unknown it returns the `value`' do
        let(:locale) { :ru }

        it { expect(coerced_value).to eq(['apple']) }
      end

      context 'when translation keys match' do
        it 'translated object match' do
          translation1 = subject.cast(value)
          translation2 = subject.cast(value)
          expect(translation1).to eq(translation2)
        end
      end

      context 'when translation keys do not match' do
        let(:pear) { [{ 'en' => 'Pear', 'value' => 'pear', 'cy' => 'Gellygen' }] }

        it 'translated object do not match' do
          expect(subject.cast(value)).not_to eq(subject.cast(pear))
        end
      end
    end

    describe 'when value is `string`' do
      let(:value) { 'Apple' }

      it { expect { coerced_value }.to raise_error('Invalid Type for "Apple"') }
    end
  end
end
