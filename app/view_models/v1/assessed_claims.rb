module V1
  class AssessedClaims < BaseViewModel
    attribute :laa_reference
    attribute :defendants
    attribute :firm_office
    attribute :updated_at, :date
    attribute :id
    attribute :state

    def main_defendant_name
      main_defendant = defendants.detect { |defendant| defendant['main'] }
      main_defendant ? main_defendant['full_name'] : ''
    end

    def firm_name
      firm_office['name']
    end

    def date_assessed
      { text: I18n.l(updated_at, format: '%-d %b %Y'), sort_value: updated_at.to_fs(:db) }
    end

    def case_worker_name
      '#Pending#'
    end

    def get_colour(item)
      case item
      when 'grant'
        'green'
      when 'part_grant'
        'blue'
      when 'reject'
        'red'
      else
        'grey'
      end
    end

    def table_fields
      [
        { laa_reference: laa_reference, claim_id: id },
        firm_name,
        main_defendant_name,
        date_assessed,
        case_worker_name,
        { colour: get_colour(state), text: state }
      ]
    end
  end
end
