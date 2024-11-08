module Nsm
  module V1
    class ContactDetails < BaseViewModel
      attribute :firm_office
      attribute :solicitor
      attribute :submission

      def key
        'contact_details'
      end

      def title
        I18n.t(".nsm.claim_details.#{key}.title")
      end

      def firm_name
        firm_office['name']
      end

      def solicitor_full_name
        construct_name(solicitor)
      end

      def solicitor_ref_number
        solicitor['reference_number']
      end

      def contact_full_name
        construct_name(solicitor, prefix: 'contact_')
      end

      def contact_email
        solicitor['contact_email']
      end

      def firm_address
        sanitize([
          firm_office['address_line_1'],
          firm_office['address_line_2'],
          firm_office['town'],
          firm_office['postcode']
        ].compact.join('<br>'),
                 tags: %w[br])
      end

      def vat_registered
        if firm_office['vat_registered'] == 'yes'
          "#{(submission.rates.vat * 100).to_i}%"
        else
          'No'
        end
      end

      # rubocop:disable Metrics/MethodLength
      def data
        [
          {
            title: I18n.t(".nsm.claim_details.#{key}.firm_name"),
            value: firm_name
          },
          {
            title: I18n.t(".nsm.claim_details.#{key}.firm_address"),
            value: firm_address
          },
          {
            title: I18n.t(".nsm.claim_details.#{key}.vat_registered"),
            value: vat_registered
          },
          {
            title: I18n.t(".nsm.claim_details.#{key}.solicitor_full_name"),
            value: solicitor_full_name
          },
          {
            title: I18n.t(".nsm.claim_details.#{key}.solicitor_ref_number"),
            value: solicitor_ref_number
          },
          *contact_details,
        ]
      end
      # rubocop:enable Metrics/MethodLength

      def rows
        { title:, data: }
      end

      # rubocop:disable Metrics/MethodLength
      def contact_details
        if contact_email.blank?
          [
            {
              title: I18n.t(".nsm.claim_details.#{key}.contact_details.title"),
              value: I18n.t(".nsm.claim_details.#{key}.contact_details.value")
            },
          ]
        else
          [
            {
              title: I18n.t(".nsm.claim_details.#{key}.contact_full_name"),
              value: contact_full_name
            },
            {
              title: I18n.t(".nsm.claim_details.#{key}.contact_email"),
              value: contact_email
            },
          ]
        end
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
