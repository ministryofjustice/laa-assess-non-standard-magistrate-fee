# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Autograntable do
  subject(:autograntable) { described_class.new(submission:) }
  before do
    allow(LocationService).to receive(:inside_m25?).and_return(true)
  end

  context 'when no limit exists for service' do
    let(:submission) { build(:prior_authority_application) }

    it 'is not autograntable' do
      expect(autograntable).not_to be_grantable
      expect(autograntable.reason).to eq(:unknown_service)
    end
  end

  context 'when current version is greater than 1' do
    let(:submission) { build(:prior_authority_application, current_version: 2) }

    it 'is not autograntable' do
      expect(autograntable).not_to be_grantable
      expect(autograntable.reason).to eq(:version)
    end
  end

  context 'when limits exists for the service' do
    let(:additional_costs) { [] }
    let(:quotes) { [build(:primary_quote, *primary_quote_settings)] }
    let(:primary_quote_settings) { [] }
    let(:prison_law) { false }
    let(:data) { build(:prior_authority_data, additional_costs:, quotes:, prison_law:) }
    let(:submission) { build(:prior_authority_application, data:) }

    context 'and is not prison law (uses rep_order_date - 2023/01/02)' do
      context 'and date is before limit start date' do
        before do
          create(:limits, start_date: Date.new(2023, 1, 3))
        end

        it 'is not autograntable' do
          expect(autograntable).not_to be_grantable
          expect(autograntable.reason).to eq(:unknown_service)
        end
      end

      context 'and date is after limit start date' do
        before do
          create(:limits, start_date: Date.new(2023, 1, 1), max_units: 8, max_rate_london: '3.6',
travel_rate_london: '101.0', travel_hours: 4)
        end

        it { expect(autograntable).to be_grantable }
      end
    end

    context 'and is prison law (uses ufn - \'130324/001\')' do
      let(:prison_law) { true }

      context 'and date is before limit start date' do
        before do
          create(:limits, start_date: Date.new(2024, 3, 14))
        end

        it 'is not autograntable' do
          expect(autograntable).not_to be_grantable
          expect(autograntable.reason).to eq(:unknown_service)
        end
      end

      context 'and date is after limit start date' do
        before do
          create(:limits, start_date: Date.new(2024, 3, 12), max_units: 8, max_rate_london: '3.6',
travel_rate_london: '101.0', travel_hours: 4)
        end

        it { expect(autograntable).to be_grantable }
      end
    end

    context 'and its for a different service' do
      before do
        create(:limits, service: 'apples')
      end

      it 'is not autograntable' do
        expect(autograntable).not_to be_grantable
        expect(autograntable.reason).to eq(:unknown_service)
      end
    end

    context 'and additional costs exists' do
      let(:additional_costs) { [{}] }

      it 'is not autograntable' do
        expect(autograntable).not_to be_grantable
        expect(autograntable.reason).to eq(:additional_costs)
      end
    end

    context 'and location is London' do
      context 'and unit_type matches service cost type (per_item)' do
        let(:max_units) { 8 }
        let(:max_rate_london) { '3.6' }
        let(:travel_rate_london) { '101.0' }
        let(:travel_hours) { 4 }

        before do
          create(:limits, max_units:, max_rate_london:, travel_rate_london:, travel_hours:)
        end

        context 'and no travel costs' do
          let(:primary_quote_settings) { [:no_travel] }

          context 'and units and rate is below max limit' do
            it { expect(autograntable).to be_grantable }
          end

          context 'and units is above units max limit' do
            let(:max_units) { 6 }

            it 'is not autograntable' do
              expect(autograntable).not_to be_grantable
              expect(autograntable.reason).to eq(:exceed_service_costs)
            end
          end

          context 'and rate is above units max limit' do
            let(:max_rate_london) { '3.4' }

            it 'is not autograntable' do
              expect(autograntable).not_to be_grantable
              expect(autograntable.reason).to eq(:exceed_service_costs)
            end
          end
        end

        context 'and travel costs exists' do
          context 'and units and rate for quote and travel is below max limit' do
            it { expect(autograntable).to be_grantable }
          end

          context 'and units for quote is above units max limit' do
            let(:max_units) { 6 }

            it 'is not autograntable' do
              expect(autograntable).not_to be_grantable
              expect(autograntable.reason).to eq(:exceed_service_costs)
            end
          end

          context 'and rate for quote is above units max limit' do
            let(:max_rate_london) { '3.4' }

            it 'is not autograntable' do
              expect(autograntable).not_to be_grantable
              expect(autograntable.reason).to eq(:exceed_service_costs)
            end
          end

          context 'and units for travel is above units max limit' do
            let(:travel_hours) { 2 }

            it 'is not autograntable' do
              expect(autograntable).not_to be_grantable
              expect(autograntable.reason).to eq(:exceed_travel_costs)
            end
          end

          context 'and rate for travel is above units max limit' do
            let(:travel_rate_london) { '99.0' }

            it 'is not autograntable' do
              expect(autograntable).not_to be_grantable
              expect(autograntable.reason).to eq(:exceed_travel_costs)
            end
          end
        end
      end

      context 'and unit_type matches service cost type (per_hour)' do
        let(:unit_type) { 'per_hour' }
        let(:max_units) { 8 }
        let(:max_rate_london) { '91' }
        let(:travel_rate_london) { '101.0' }
        let(:travel_hours) { 4 }

        before do
          create(:limits, unit_type:, max_units:, max_rate_london:, travel_rate_london:, travel_hours:)
        end

        context 'and no travel costs' do
          let(:primary_quote_settings) { [:no_travel, :per_hour] }

          context 'and units and rate is below max limit' do
            it { expect(autograntable).to be_grantable }
          end

          context 'and units is above units max limit' do
            let(:max_units) { 6 }

            it 'is not autograntable' do
              expect(autograntable).not_to be_grantable
              expect(autograntable.reason).to eq(:exceed_service_costs)
            end
          end

          context 'and rate is above units max limit' do
            let(:max_rate_london) { '79' }

            it 'is not autograntable' do
              expect(autograntable).not_to be_grantable
              expect(autograntable.reason).to eq(:exceed_service_costs)
            end
          end
        end

        context 'and travel costs exists' do
          let(:primary_quote_settings) { [:per_hour] }

          context 'and units and rate for quote and travel is below max limit' do
            it { expect(autograntable).to be_grantable }
          end

          context 'and units for quote is above units max limit' do
            let(:max_units) { 6 }

            it 'is not autograntable' do
              expect(autograntable).not_to be_grantable
              expect(autograntable.reason).to eq(:exceed_service_costs)
            end
          end

          context 'and rate for quote is above units max limit' do
            let(:max_rate_london) { '79' }

            it 'is not autograntable' do
              expect(autograntable).not_to be_grantable
              expect(autograntable.reason).to eq(:exceed_service_costs)
            end
          end

          context 'and units for travel is above units max limit' do
            let(:travel_hours) { 2 }

            it 'is not autograntable' do
              expect(autograntable).not_to be_grantable
              expect(autograntable.reason).to eq(:exceed_travel_costs)
            end
          end

          context 'and rate for travel is above units max limit' do
            let(:travel_rate_london) { '99.0' }

            it 'is not autograntable' do
              expect(autograntable).not_to be_grantable
              expect(autograntable.reason).to eq(:exceed_travel_costs)
            end
          end
        end
      end

      context 'and unit_type does not match service cost type' do
        let(:unit_type) { 'per_hour' }

        before do
          create(:limits, unit_type:)
        end

        it 'is not autograntable' do
          expect(autograntable).not_to be_grantable
          expect(autograntable.reason).to eq(:unknown_service)
        end
      end
    end

    context 'and location is not London' do
      before do
        allow(LocationService).to receive(:inside_m25?).and_return(false)
      end

      context 'and unit_type matches service cost type (per_item)' do
        let(:max_units) { 8 }
        let(:max_rate_non_london) { '3.6' }
        let(:travel_rate_non_london) { '101.0' }
        let(:travel_hours) { 4 }

        before do
          create(:limits, max_units:, max_rate_non_london:, travel_rate_non_london:, travel_hours:)
        end

        context 'and no travel costs' do
          let(:primary_quote_settings) { [:no_travel] }

          context 'and units and rate is below max limit' do
            it { expect(autograntable).to be_grantable }
          end

          context 'and units is above units max limit' do
            let(:max_units) { 6 }

            it 'is not autograntable' do
              expect(autograntable).not_to be_grantable
              expect(autograntable.reason).to eq(:exceed_service_costs)
            end
          end

          context 'and rate is above units max limit' do
            let(:max_rate_non_london) { '3.4' }

            it 'is not autograntable' do
              expect(autograntable).not_to be_grantable
              expect(autograntable.reason).to eq(:exceed_service_costs)
            end
          end
        end

        context 'and travel costs exists' do
          context 'and units and rate for quote and travel is below max limit' do
            it { expect(autograntable).to be_grantable }
          end

          context 'and units for quote is above units max limit' do
            let(:max_units) { 6 }

            it 'is not autograntable' do
              expect(autograntable).not_to be_grantable
              expect(autograntable.reason).to eq(:exceed_service_costs)
            end
          end

          context 'and rate for quote is above units max limit' do
            let(:max_rate_non_london) { '3.4' }

            it 'is not autograntable' do
              expect(autograntable).not_to be_grantable
              expect(autograntable.reason).to eq(:exceed_service_costs)
            end
          end

          context 'and units for travel is above units max limit' do
            let(:travel_hours) { 2 }

            it 'is not autograntable' do
              expect(autograntable).not_to be_grantable
              expect(autograntable.reason).to eq(:exceed_travel_costs)
            end
          end

          context 'and rate for travel is above units max limit' do
            let(:travel_rate_non_london) { '99.0' }

            it 'is not autograntable' do
              expect(autograntable).not_to be_grantable
              expect(autograntable.reason).to eq(:exceed_travel_costs)
            end
          end
        end
      end

      context 'and unit_type matches service cost type (per_hour)' do
        let(:unit_type) { 'per_hour' }
        let(:max_units) { 8 }
        let(:max_rate_non_london) { '91' }
        let(:travel_rate_non_london) { '101.0' }
        let(:travel_hours) { 4 }

        before do
          create(:limits, unit_type:, max_units:, max_rate_non_london:, travel_rate_non_london:, travel_hours:)
        end

        context 'and no travel costs' do
          let(:primary_quote_settings) { [:no_travel, :per_hour] }

          context 'and units and rate is below max limit' do
            it { expect(autograntable).to be_grantable }
          end

          context 'and units is above units max limit' do
            let(:max_units) { 6 }

            it 'is not autograntable' do
              expect(autograntable).not_to be_grantable
              expect(autograntable.reason).to eq(:exceed_service_costs)
            end
          end

          context 'and rate is above units max limit' do
            let(:max_rate_non_london) { '79' }

            it 'is not autograntable' do
              expect(autograntable).not_to be_grantable
              expect(autograntable.reason).to eq(:exceed_service_costs)
            end
          end
        end

        context 'and travel costs exists' do
          let(:primary_quote_settings) { [:per_hour] }

          context 'and units and rate for quote and travel is below max limit' do
            it { expect(autograntable).to be_grantable }
          end

          context 'and units for quote is above units max limit' do
            let(:max_units) { 6 }

            it 'is not autograntable' do
              expect(autograntable).not_to be_grantable
              expect(autograntable.reason).to eq(:exceed_service_costs)
            end
          end

          context 'and rate for quote is above units max limit' do
            let(:max_rate_non_london) { '79' }

            it 'is not autograntable' do
              expect(autograntable).not_to be_grantable
              expect(autograntable.reason).to eq(:exceed_service_costs)
            end
          end

          context 'and units for travel is above units max limit' do
            let(:travel_hours) { 2 }

            it 'is not autograntable' do
              expect(autograntable).not_to be_grantable
              expect(autograntable.reason).to eq(:exceed_travel_costs)
            end
          end

          context 'and rate for travel is above units max limit' do
            let(:travel_rate_non_london) { '99.0' }

            it 'is not autograntable' do
              expect(autograntable).not_to be_grantable
              expect(autograntable.reason).to eq(:exceed_travel_costs)
            end
          end
        end
      end

      context 'and unit_type does not match service cost type' do
        let(:unit_type) { 'per_hour' }

        before do
          create(:limits, unit_type:)
        end

        it 'is not autograntable' do
          expect(autograntable).not_to be_grantable
          expect(autograntable.reason).to eq(:unknown_service)
        end
      end
    end
  end
end
