require 'rails_helper'

RSpec.describe Nsm::LettersCallsForm do
  subject { described_class.new(params) }

  let(:claim) { build(:claim) }
  let(:params) { { claim:, type:, count:, uplift:, item:, explanation:, current_user: } }
  let(:type) { 'letters' }
  let(:count) { 2 }
  let(:uplift) { 'yes' }
  let(:item) do
    instance_double(
      Nsm::V1::LetterAndCall,
      count: 12,
      uplift: uplift_provided ? 95 : nil,
      original_uplift: original_uplift,
      uplift?: uplift_provided
    )
  end
  let(:uplift_provided) { !original_uplift.nil? }
  let(:original_uplift) { 95 }
  let(:explanation) { 'change to letters' }
  let(:current_user) { instance_double(User) }
  let(:app_store_client) { instance_double(AppStoreClient, create_events: true) }

  before { allow(AppStoreClient).to receive(:new).and_return(app_store_client) }

  describe '#validations' do
    describe '#type' do
      %w[letters calls].each do |type_value|
        context 'when it is letters' do
          let(:type) { type_value }

          it { expect(subject).to be_valid }
        end
      end

      context 'when it is something else' do
        let(:type) { 'other' }

        it 'is not valid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:type, :inclusion)).to be(true)
        end
      end
    end

    context 'uplift' do
      ['yes', 'no', 0, 95].each do |uplift_value|
        context 'when it is letters' do
          let(:uplift) { uplift_value }

          it { expect(subject).to be_valid }
        end
      end

      context 'when it is something else' do
        let(:uplift) { 'other' }

        it 'is not valid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:uplift, :inclusion)).to be(true)
        end
      end
    end

    context 'explanation' do
      context 'when it is blank' do
        let(:explanation) { '' }

        it 'is not valid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:explanation, :blank)).to be(true)
        end
      end
    end

    context 'when data has not changed' do
      let(:count) { 12 }
      let(:uplift) { 'no' }

      it 'is not valid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:base, :no_change)).to be(true)
      end

      context 'when there is no uplift to edit' do
        let(:original_uplift) { nil }

        it 'adds the error message to the one editable field' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:count, :no_change)).to be(true)
        end
      end

      context 'and explanation does not have an error' do
        let(:explanation) { '' }

        it 'is not valid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:explanation, :blank)).to be(false)
        end
      end
    end
  end

  describe '#uplift' do
    it 'can be set with a string' do
      expect(described_class.new(uplift: 'yes').uplift).to eq('yes')
      expect(described_class.new(uplift: 'no').uplift).to eq('no')
    end

    it 'can be set with an integer' do
      expect(described_class.new(uplift: 0).uplift).to eq('yes')
      expect(described_class.new(uplift: 95).uplift).to eq('no')
    end

    it 'not set when nil' do
      expect(described_class.new(uplift: nil).uplift).to be_nil
    end
  end

  describe '#persistance' do
    let(:current_user) { create(:caseworker) }

    context 'when record is invalid' do
      let(:count) { nil }

      it { expect(subject.save).to be_falsey }
    end

    it { expect(subject.save).to be_truthy }

    context 'when only count has changed' do
      let(:uplift) { 'no' }

      it 'creates a event for the count change' do
        expect(Event::Edit).to receive(:build).with(
          submission: claim,
          linked: {
            type: 'letters_and_calls',
            id: 'letters',
          },
          details: {
            field: 'count',
            from: 12,
            to: 2,
            change: -10,
            comment: 'change to letters'
          },
          current_user: current_user,
        )

        subject.save
      end

      it 'updates the JSON data' do
        subject.save
        letters = claim.data['letters_and_calls']
                       .detect { |row| row['type'] == 'letters' }
        expect(letters).to eq(
          'count' => 2,
          'count_original' => 12,
          'pricing' => 3.56,
          'type' => 'letters',
          'uplift' => 95,
          'adjustment_comment' => 'change to letters',
        )
      end
    end

    context 'when only uplift has changed' do
      let(:count) { 12 }

      it 'creates a event for the uplift change' do
        expect(Event::Edit).to receive(:build).with(
          submission: claim,
          linked: {
            type: 'letters_and_calls',
            id: 'letters',
          },
          details: {
            field: 'uplift',
            from: 95,
            to: 0,
            change: -95,
            comment: 'change to letters'
          },
          current_user: current_user
        )

        subject.save
      end

      it 'updates the JSON data' do
        subject.save
        letters = claim.data['letters_and_calls']
                       .detect { |row| row['type'] == 'letters' }
        expect(letters).to eq(
          'count' => 12,
          'pricing' => 3.56,
          'type' => 'letters',
          'uplift' => 0,
          'uplift_original' => 95,
          'adjustment_comment' => 'change to letters'
        )
      end
    end

    context 'when uplift and count have changed' do
      it 'creates an event for each field changed' do
        expect(Event::Edit).to receive(:build).twice
        subject.save
      end

      it 'updates the JSON data' do
        subject.save
        letters = claim.data['letters_and_calls']
                       .detect { |row| row['type'] == 'letters' }
        expect(letters).to eq(
          'count' => 2,
          'count_original' => 12,
          'pricing' => 3.56,
          'type' => 'letters',
          'uplift' => 0,
          'uplift_original' => 95,
          'adjustment_comment' => 'change to letters',
        )
      end
    end

    context 'when claim has a legacy translation format' do
      let(:claim) { build(:claim, :legacy_translations) }

      it 'creates an event for each field changed' do
        expect(Event::Edit).to receive(:build).twice
        subject.save
      end

      it 'updates the JSON data' do
        subject.save
        letters = claim.data['letters_and_calls']
                       .detect { |row| row.dig('type', 'value') == 'letters' }
        expect(letters).to eq(
          'count' => 2,
          'count_original' => 12,
          'pricing' => 3.56,
          'type' => { 'en' => 'Letters', 'value' => 'letters' },
          'uplift' => 0,
          'uplift_original' => 95,
          'adjustment_comment' => 'change to letters',
        )
      end
    end

    context 'when error during save' do
      before do
        allow(Event::Edit).to receive(:build).and_raise(StandardError)
      end

      it { expect(subject.save).to be_falsey }
    end

    context 'when uplift is not populated from provider' do
      let(:original_uplift) { nil }

      it 'saves without error' do
        expect(Event::Edit).to receive(:build).once
        subject.save
      end
    end
  end
end
