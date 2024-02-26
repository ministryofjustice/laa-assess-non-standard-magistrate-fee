module PriorAuthority
  module V1
    class ApplicationDetails
      class NextHearingCard < BaseCard
        CARD_ROWS = %i[next_hearing_string].freeze

        delegate :next_hearing, :next_hearing_date, to: :application_details

        def next_hearing_string
          if next_hearing
            next_hearing_date.to_fs(:stamp)
          else
            I18n.t('prior_authority.application_details.not_known')
          end
        end
      end
    end
  end
end
