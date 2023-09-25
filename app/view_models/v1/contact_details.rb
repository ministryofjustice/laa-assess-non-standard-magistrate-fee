module V1
  class ContactDetails < BaseViewModel
    attribute :firm_office
    attribute :solicitor

    def key
      'contact_details'
    end

    def title
      I18n.t(".claim_details.#{key}.title")
    end

    def firm_name
      firm_office['name']
    end

    def firm_account_number
      firm_office['account_number']
    end

    def solicitor_full_name
      solicitor['full_name']
    end

    def solicitor_ref_number
      solicitor['reference_number']
    end

    def firm_address
      ApplicationController.helpers.sanitize([
        firm_office['address_line_1'],
        firm_office['address_line_2'],
        firm_office['town'],
        firm_office['postcode']
      ].join('<br>'),
                                             tags: %w[br])
    end

    # rubocop:disable Metrics/MethodLength
    def data
      [
        {
          title: I18n.t(".claim_details.#{key}.firm_name"),
          value: firm_name
        },
        {
          title: I18n.t(".claim_details.#{key}.firm_account_number"),
          value: firm_account_number
        },
        {
          title: I18n.t(".claim_details.#{key}.firm_address"),
          value: firm_address
        },
        {
          title: I18n.t(".claim_details.#{key}.solicitor_full_name"),
          value: solicitor_full_name
        },
        {
          title: I18n.t(".claim_details.#{key}.solicitor_ref_number"),
          value: solicitor_ref_number
        }
      ]
    end
    # rubocop:enable Metrics/MethodLength

    def rows
      { title:, data: }
    end
  end
end
