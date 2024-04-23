module PriorAuthority
  module V1
    class ApplicationDetails
      class ReasonWhyCard < BaseCard
        CARD_ROWS = %i[reason_why supporting_document_string].freeze

        delegate :supporting_documents, to: :application_details

        def reason_why
          simple_format(application_details.reason_why)
        end

        def supporting_document_string
          return I18n.t('prior_authority.application_details.none') if supporting_documents.blank?

          safe_join(
            supporting_documents.map { [document_link(_1), tag.br] }.flatten
          )
        end

        def document_link(supporting_document_json)
          link_to(
            supporting_document_json['file_name'],
            url_helpers.prior_authority_download_path(supporting_document_json['file_path'],
                                                      file_name: supporting_document_json['file_name'])
          )
        end
      end
    end
  end
end
