module V1
  class AllClaims < BaseViewModel
    attribute :laa_reference
    attribute :defendants
    attribute :firm_office
    attribute :created_at, :date

    def main_defendant_name
      main_defendant = defendants.detect { |defendant| defendant['main'] }
      main_defendant ? main_defendant['full_name'] : ''
    end

    def firm_name
      firm_office['name']
    end

    def case_worker_name
      '#Pending#'
    end

    def table_fields
      [
        laa_reference,
        main_defendant_name,
        firm_name,
        I18n.l(created_at, format: '%-d %B %Y'),
        case_worker_name
      ]
    end
  end
end
