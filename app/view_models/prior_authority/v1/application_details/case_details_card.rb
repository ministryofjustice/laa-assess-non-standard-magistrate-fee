module PriorAuthority
  module V1
    class ApplicationDetails
      class CaseDetailsCard < BaseCard
        CARD_ROWS = %i[main_offence rep_order_date_string maat client_detained_string subject_to_poca_string].freeze

        delegate :main_offence, :rep_order_date, :client_detained, :subject_to_poca, :defendant,
                 to: :application_details

        def rep_order_date_string
          rep_order_date.to_fs(:stamp)
        end

        def maat
          defendant['maat']
        end

        def client_detained_string
          I18n.t("shared.#{client_detained}")
        end

        def subject_to_poca_string
          I18n.t("shared.#{subject_to_poca}")
        end
      end
    end
  end
end
