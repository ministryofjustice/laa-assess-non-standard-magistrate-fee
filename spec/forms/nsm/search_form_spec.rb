require 'rails_helper'

RSpec.describe Nsm::SearchForm do
  subject { described_class.new }

  describe '#statuses' do
    it 'does not contain auto_grant, provider_updated, expired status' do
      statuses = subject.statuses.map(&:value)
      %i[auto_grant provider_updated expired].each do |status|
        expect(statuses).not_to include(status)
      end
    end

    context 'when feature flag is enabled' do
      before do
        allow(FeatureFlags).to receive(:nsm_rfi_loop).and_return(
          instance_double(FeatureFlags::EnabledFeature, enabled?: true)
        )
      end

      it 'does contain provider_updated and expired' do
        statuses = subject.statuses.map(&:value)
        %i[provider_updated expired].each do |status|
          expect(statuses).to include(status)
        end
      end
    end
  end
end
