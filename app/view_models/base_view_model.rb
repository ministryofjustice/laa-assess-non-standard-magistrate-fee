class BaseViewModel
  include ActiveModel::Model
  include ActiveModel::Attributes

  class << self
    def build(class_type, claim, *nesting)
      klass = "V#{claim.json_schema_version}::#{class_type.to_s.camelcase}".constantize

      attributes = claim.attributes.merge(claim.data, 'claim' => claim)
      attributes = attributes.dig(*nesting) if nesting.any?

      klass.new(attributes.slice(*klass.attribute_names))
    end

    def build_all(class_type, claim, *)
      klass = "V#{claim.json_schema_version}::#{class_type.to_s.camelcase}".constantize

      rows = claim.data[*]

      klass.build_from_hash(rows, claim)
    end

    def build_from_hash(rows, claim)
      raise 'can not be called on BaseViewModel' if self == BaseViewModel

      if const_defined?(:LINKED_TYPE)
        all_adjustments = all_adjustments(claim, rows)

        rows.map do |attributes|
          key = [attributes.dig('type', 'value') || self::LINKED_TYPE, attributes['id']]
          adjustments = all_adjustments.fetch(key, [])
          new(adjustments:, **attributes.slice(*attribute_names))
        end
      else
        rows.map { |attributes| build_self(attributes) }
      end
    end

    def build_self(attributes)
      new(attributes.slice(*attribute_names))
    end

    private

    def all_adjustments(claim, rows)
      linked_ids = rows.pluck('id')

      claim.events
           .where(linked_type: self::LINKED_TYPE, linked_id: linked_ids)
           .order(:created_at)
           .group_by { |event| [event.linked_type, event.linked_id] }
    end
  end

  def [](val)
    public_send(val)
  end
end
