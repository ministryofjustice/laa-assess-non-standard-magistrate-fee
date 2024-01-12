module PriorAuthority
  class Application
    attr_reader :local_record, :data

    delegate :id, to: :local_record

    def initialize(claim)
      @local_record = claim
      @data = JSON.parse claim.data.to_json, object_class: OpenStruct
    end

    def date_created_str
      I18n.l(local_record.created_at, format: '%-d %b %Y')
    end
  end
end
