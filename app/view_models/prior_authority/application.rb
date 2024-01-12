module PriorAuthority
  class Application
    attr_reader :local_record, :data

    delegate :id, to: :local_record

    def initialize(claim)
      @local_record = claim
      @data = structify(claim.data)
    end

    def date_created_str
      I18n.l(local_record.created_at, format: '%-d %b %Y')
    end

    private

    def structify(object)
      case object
      when Array
        object.map { structify(_1) }
      when Hash
        klass = Struct.new(*object.keys.map(&:to_sym))
        klass.new(*object.values.map { structify(_1) })
      else
        object
      end
    end
  end
end
