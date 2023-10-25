class BaseViewModel
  include ActiveModel::Model
  include ActiveModel::Attributes

  class Builder
    attr_reader :klass, :claim, :rows, :return_array

    def initialize(class_type, claim, *nesting)
      @klass = "V#{claim.json_schema_version}::#{class_type.to_s.camelcase}".constantize
      @claim = claim
      if nesting.any?
        @rows = claim.data.dig(*nesting)
        @return_array = true
      else
        @rows = [claim.data]
        @return_array = false
      end
    end

    def build
      process do |attributes|
        data = attributes.slice(*klass.attribute_names)

        if klass.const_defined?(:LINKED_TYPE)
          key = [attributes.dig('type', 'value') || klass::LINKED_TYPE, attributes['id']]
          data[:adjustments] = all_adjustments.fetch(key, [])
        end

        klass.new(data)
      end
    end

    private

    def process(&block)
      result = rows.map(&block)
      return_array ? result : result[0]
    end

    def all_adjustments
      @all_adjustments ||= begin
        linked_ids = rows.pluck('id')

        claim.events
             .where(linked_type: klass::LINKED_TYPE, linked_id: linked_ids)
             .order(:created_at)
             .group_by { |event| [event.linked_type, event.linked_id] }
      end
    end
  end

  class << self
    def build(class_type, claim, *)
      Builder.new(class_type, claim, *).build
    end
  end

  def [](val)
    public_send(val)
  end
end
