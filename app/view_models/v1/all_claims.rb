module V1
  class AllClaims < BaseViewModel
    attribute :laa_reference
    attribute :defendants
    attribute :firm_office
    attribute :created_at, :date
    attribute :id

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
        { laa_reference: laa_reference, claim_id: id },
        firm_name,
        main_defendant_name,
        { text: I18n.l(created_at, format: '%-d %b %Y'), sort_value: created_at.to_fs(:db) },
        case_worker_name
      ]
    end
  end
end
