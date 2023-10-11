module V1
  class YourClaims < BaseViewModel
    attribute :laa_reference
    attribute :defendants
    attribute :firm_office
    attribute :created_at, :date
    attribute :id
    attribute :risk

    def main_defendant_name
      main_defendant = defendants.detect { |defendant| defendant['main'] }
      main_defendant ? main_defendant['full_name'] : ''
    end

    def firm_name
      firm_office['name']
    end

    def date_created
      { text: I18n.l(created_at, format: '%-d %b %Y'), sort_value: created_at.to_fs(:db) }
    end

    def case_worker_name
      '#Pending#'
    end

    def get_risk(item)
      case item
      when 'high'
        { text: item, sort_value: 1 }
      when 'medium'
        {  text: item, sort_value: 2 }
      when 'low'
        { text: item, sort_value: 3 }
      end
    end

    def table_fields
      [
        { laa_reference: laa_reference, claim_id: id },
        firm_name,
        main_defendant_name,
        date_created,
        case_worker_name,
        get_risk(risk)
      ]
    end
  end
end
