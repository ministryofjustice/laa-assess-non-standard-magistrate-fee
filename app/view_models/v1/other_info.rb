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
      I18n.t(".claim_details.#{key}.title")
    end

    # rubocop:disable Metrics/MethodLength
    def data
      [
        {
          title: I18n.t('.claim_details.other_info.is_other_info'),
          value: is_other_info&.capitalize
        },
        *(unless is_other_info == 'no'
            {
              title: I18n.t('.claim_details.other_info.other_info'),
            value: ApplicationController.helpers.multiline_text(other_info)
            }
          end),
        {
          title: I18n.t('.claim_details.other_info.concluded'),
          value: concluded&.capitalize
        },
        *(unless concluded == 'no'
            {
              title: I18n.t('.claim_details.other_info.conclusion'),
            value: ApplicationController.helpers.multiline_text(conclusion)
            }
          end)
      ]
    end
    # rubocop:enable Metrics/MethodLength

    def rows
      { title:, data: }
    end
  end
end
