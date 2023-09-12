module ClaimDetails
  class OtherInfo < Base
    attr_reader :claim_details

    def initialize(claim_details)
      @claim_details = claim_details
      @key = 'other_info'
    end

    def data
      [
        {
          title: I18n.t('.claim_details.other_info.is_other_info'),
          value: claim_details.is_other_info&.capitalize
        },
        {
          title: I18n.t('.claim_details.other_info.other_info'),
          value: ApplicationController.helpers.multiline_text(claim_details.other_info)
        },
        {
          title: I18n.t('.claim_details.other_info.concluded'),
          value: claim_details.concluded&.capitalize
        },
        {
          title: I18n.t('.claim_details.other_info.conclusion'),
          value: ApplicationController.helpers.multiline_text(claim_details.conclusion)
        }
      ]
    end
  end
end