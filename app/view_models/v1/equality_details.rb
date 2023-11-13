module V1
  class EqualityDetails < BaseViewModel
    attribute :answer_equality
    attribute :ethnic_group
    attribute :gender
    attribute :disability

    def key
      'equality_details'
    end

    def title
      I18n.t(".claim_details.#{key}.title")
    end

    # rubocop:disable Metrics/MethodLength
    def data
      [
        {
          title: I18n.t(".claim_details.#{key}.questions"),
          value: answer_equality.to_s
        },
        {
          title: I18n.t(".claim_details.#{key}.ethnic_group"),
          value: ethnic_group.to_s
        },
        {
          title: I18n.t(".claim_details.#{key}.identification"),
          value: gender.to_s
        },
        {
          title: I18n.t(".claim_details.#{key}.disability"),
          value: disability.to_s
      },

      ]
    end
    # rubocop:enable Metrics/MethodLength

    def rows
      { title:, data: }
    end
  end
end
