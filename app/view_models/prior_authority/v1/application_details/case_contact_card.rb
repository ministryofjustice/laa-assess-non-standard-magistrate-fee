module PriorAuthority
  module V1
    class ApplicationDetails
      class CaseContactCard < BaseCard
        CARD_ROWS = %i[case_contact firm_details].freeze

        delegate :solicitor, :firm_office, to: :application_details

        def case_contact
          safe_join([
                      solicitor['contact_full_name'],
                      tag.br,
                      solicitor['contact_email']
                    ])
        end

        def firm_details
          safe_join([
                      firm_office['name'],
                      tag.br,
                      firm_office['account_number']
                    ])
        end
      end
    end
  end
end
