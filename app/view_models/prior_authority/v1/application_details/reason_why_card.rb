module PriorAuthority
  module V1
    class ApplicationDetails
      class ReasonWhyCard < BaseCard
        CARD_ROWS = %i[reason_why supporting_document_string].freeze

        delegate :reason_why, :supporting_documents, to: :application_details

        def supporting_document_string
          return I18n.t('prior_authority.application_details.none') if supporting_documents.blank?

          safe_join(
            supporting_documents.map { [document_link(_1), tag.br] }.flatten
          )
        end

        def document_link(supporting_document_json)
          link_to(
            supporting_document_json['file_name'],
            supporting_document_json['file_path']
          )
        end
      end
    end
  end
end
