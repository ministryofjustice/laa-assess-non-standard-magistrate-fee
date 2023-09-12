module ClaimDetails
  class HearingDetails < Base
    attr_reader :claim_details

    def initialize(claim_details)
      @claim_details = claim_details
      @key = 'hearing_details'
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def data
      [
        {
          title: I18n.t('.claim_details.hearing_details.first_hearing_date'),
          value: ApplicationController.helpers.format_date_string(claim_details.first_hearing_date)
        },
        {
          title: I18n.t('.claim_details.hearing_details.number_of_hearing'),
          value: claim_details.number_of_hearing
        },
        {
          title: I18n.t('.claim_details.hearing_details.court'),
          value: claim_details.court
        },
        {
          title: I18n.t('.claim_details.hearing_details.in_area'),
          value: claim_details.in_area&.capitalize
        },
        {
          title: I18n.t('.claim_details.hearing_details.youth_court'),
          value: claim_details.youth_count&.capitalize
        },
        {
          title: I18n.t('.claim_details.hearing_details.hearing_outcome'),
          value: claim_details.hearing_outcome_en
        },
        {
          title: I18n.t('.claim_details.hearing_details.matter_type'),
          value: claim_details.matter_type_en
        }
      ]
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  end
end
