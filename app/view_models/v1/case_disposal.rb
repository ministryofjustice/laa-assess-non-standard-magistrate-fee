module V1
  class CaseDisposal < BaseViewModel
    attribute :plea, :translated
    attribute :plea_category, :translated

    def key
      'case_disposal'
    end

    def title
      I18n.t(".non_standard_magistrates_payment.claim_details.#{key}.title")
    end

    def data
      [
        {
          title: plea_category.to_s,
          value:  plea.to_s
        }
      ]
    end

    def rows
      { title:, data: }
    end
  end
end
