module PriorAuthority
  module V1
    class ApplicationDetails
      class HearingDetailsCard < BaseCard
        CARD_ROWS = %i[next_hearing_string plea_string court_type_string psychiatric_liaison_string
                       psychiatric_liaison_reason_not youth_court_string].freeze

        delegate :next_hearing_date, :plea, :court_type, :psychiatric_liaison, :psychiatric_liaison_reason_not,
                 :youth_court, to: :application_details

        def next_hearing_string
          if next_hearing_date
            next_hearing_date.to_fs(:stamp)
          else
            I18n.t('prior_authority.application_details.not_known')
          end
        end

        def plea_string
          I18n.t("prior_authority.application_details.pleas.#{plea}")
        end

        def court_type_string
          I18n.t("prior_authority.application_details.court_types.#{court_type}")
        end

        def psychiatric_liaison_string
          I18n.t("shared.#{psychiatric_liaison}") unless psychiatric_liaison.nil?
        end

        def youth_court_string
          I18n.t("shared.#{youth_court}") unless youth_court.nil?
        end
      end
    end
  end
end
