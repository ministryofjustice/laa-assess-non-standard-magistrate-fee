module V1
  class EqualityDetails < BaseViewModel
    attribute :answer_equality, :translated
    attribute :ethnic_group, :translated
    attribute :gender, :translated
    attribute :disability, :translated

    def key
      'equality_details'
    end

    def title
      I18n.t(".non_standard_magistrates_payment.claim_details.#{key}.title")
    end

    def data
      [
        {
          title: I18n.t(".non_standard_magistrates_payment.claim_details.#{key}.questions"),
          value: answer_equality
        },
        *equality_answers
      ]
    end

    # rubocop:disable Metrics/MethodLength
    def equality_answers
      return [] unless answer_equality.value == 'yes'

      [
        {
          title: I18n.t(".non_standard_magistrates_payment.claim_details.#{key}.ethnic_group"),
          value: ethnic_group
        },
        {
          title: I18n.t(".non_standard_magistrates_payment.claim_details.#{key}.identification"),
          value: gender
        },
        {
          title: I18n.t(".non_standard_magistrates_payment.claim_details.#{key}.disability"),
          value: disability
        }
      ]
    end
    # rubocop:enable Metrics/MethodLength

    def rows
      { title:, data: }
    end
  end
end
