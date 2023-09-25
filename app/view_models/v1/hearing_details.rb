module V1
  class HearingDetails < BaseViewModel
    attribute :first_hearing_date
    attribute :number_of_hearing
    attribute :court
    attribute :in_area
    attribute :youth_count
    attribute :hearing_outcome
    attribute :matter_type

    def key
      'hearing_details'
    end

    def title
      I18n.t(".claim_details.#{key}.title")
    end

    def matter_type_en
      matter_type['en']
    end

    def hearing_outcome_en
      hearing_outcome['en']
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def data
      [
        {
          title: I18n.t(".claim_details.#{key}.first_hearing_date"),
          value: ApplicationController.helpers.format_date_string(first_hearing_date)
        },
        {
          title: I18n.t(".claim_details.hearing_details.number_of_hearing"),
          value: number_of_hearing
        },
        {
          title: I18n.t(".claim_details.#{key}.court"),
          value: court
        },
        {
          title: I18n.t(".claim_details.#{key}.in_area"),
          value: in_area&.capitalize
        },
        {
          title: I18n.t(".claim_details.#{key}.youth_court"),
          value: youth_count&.capitalize
        },
        {
          title: I18n.t(".claim_details.#{key}.hearing_outcome"),
          value: hearing_outcome_en
        },
        {
          title: I18n.t(".claim_details.#{key}.matter_type"),
          value: matter_type_en
        }
      ]
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    def rows
      { title:, data: }
    end
  end
end
