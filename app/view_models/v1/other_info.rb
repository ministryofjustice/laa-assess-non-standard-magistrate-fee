module V1
  class OtherInfo < BaseViewModel
    attribute :is_other_info
    attribute :other_info
    attribute :concluded
    attribute :conclusion

    def key
      'other_info'
    end

    def title
      I18n.t(".non_standard_magistrates_payment.claim_details.#{key}.title")
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def data
      [
        {
          title: I18n.t(".non_standard_magistrates_payment.claim_details.#{key}.is_other_info"),
          value: is_other_info.capitalize
        },
        (unless is_other_info == 'no'
           {
             title: I18n.t(".non_standard_magistrates_payment.claim_details.#{key}.other_info"),
           value: multiline_text(other_info)
           }
         end),
        {
          title: I18n.t(".non_standard_magistrates_payment.claim_details.#{key}.concluded"),
          value: concluded.capitalize
        },
        (unless concluded == 'no'
           {
             title: I18n.t(".non_standard_magistrates_payment.claim_details.#{key}.conclusion"),
           value: multiline_text(conclusion)
           }
         end)
      ].compact
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    def rows
      { title:, data: }
    end
  end
end
