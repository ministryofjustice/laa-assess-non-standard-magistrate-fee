module ClaimDetails
  class Base
    attr_accessor :key

    def title
      I18n.t(".claim_details.#{key}.title")
    end

    def data
      []
    end

    def rows
      { title:, data: }
    end
  end
end
