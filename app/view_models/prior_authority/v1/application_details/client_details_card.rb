module PriorAuthority
  module V1
    class ApplicationDetails
      class ClientDetailsCard < BaseCard
        CARD_ROWS = %i[client_name date_of_birth].freeze

        delegate :client_name, :defendant, to: :application_details

        def date_of_birth
          Date.parse(defendant['date_of_birth']).to_fs(:stamp)
        end
      end
    end
  end
end
