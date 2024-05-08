module PriorAuthority
  module V1
    class ApplicationDetails
      class FurtherInformationCard < BaseCard
        CARD_ROWS = %i[
          caseworker
          information_request
          provider_response
        ].freeze

        def initialize(application_details, further_information)
          @further_information = further_information
          super(application_details)
        end

        def caseworker
          User.find(@further_information['caseworker_id']).display_name
        end

        def information_request
          simple_format(@further_information['information_requested'])
        end

        def provider_response
          safe_join(
            [simple_format(@further_information['information_supplied'])] +
             documents.flat_map { [tag.br, document_link(_1)] }
          )
        end

        def document_link(document_json)
          link_to(
            document_json['file_name'],
            url_helpers.prior_authority_download_path(document_json['file_path'], file_name: document_json['file_name'])
          )
        end

        def requested_at_str
          Date.parse(@further_information['requested_at']).to_fs(:stamp)
        end

        def documents
          @further_information['documents'] || []
        end
      end
    end
  end
end
