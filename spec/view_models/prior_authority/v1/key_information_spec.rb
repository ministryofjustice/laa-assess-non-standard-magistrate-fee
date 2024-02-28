require 'rails_helper'

RSpec.describe PriorAuthority::V1::KeyInformation do
  describe '#main_offence' do
    subject(:key_information) { described_class.new(main_offence: 'Bad stuff') }

    it 'returns the main offence' do
      expect(key_information.main_offence).to eq('Bad stuff')
    end
  end

  describe '#key_information_card' do
    subject(:key_information) { described_class.new(submission:) }

    let(:submission) { build(:prior_authority_application) }

    it 'returns the key information card object' do
      expect(key_information.key_information_card)
        .to be_instance_of(PriorAuthority::V1::ApplicationDetails::KeyInformationCard)
    end
  end
end
