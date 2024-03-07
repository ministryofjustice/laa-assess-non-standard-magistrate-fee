require 'rails_helper'

RSpec.describe PriorAuthority::V1::KeyInformation do
  describe '#key_information_card' do
    subject(:key_information) { described_class.new(submission:) }

    let(:submission) { build(:prior_authority_application) }

    it 'returns the key information card object' do
      expect(key_information.key_information_card)
        .to be_instance_of(PriorAuthority::V1::ApplicationDetails::KeyInformationCard)
    end
  end
end
