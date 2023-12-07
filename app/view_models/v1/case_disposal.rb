module V1
  class CaseDisposal < BaseViewModel
    attribute :plea, :translated
    attribute :plea_category, :translated

    def key
      'case_disposal'
    end

    def title
      I18n.t(".claim_details.#{key}.title")
    end

    def data
      [
        {
          title: plea_category,
          value:  plea.to_s
        }
      ]
    end

    def rows
      { title:, data: }
    end
  end
end
