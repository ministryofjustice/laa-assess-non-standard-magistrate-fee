module PriorAuthority
  module V1
    class KeyInformation < ApplicationSummary
      def key_information_card
        ApplicationDetails::KeyInformationCard.new(self)
      end
    end
  end
end
