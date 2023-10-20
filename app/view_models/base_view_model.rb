class BaseViewModel
  include ActiveModel::Model
  include ActiveModel::Attributes

  def self.build(class_type, claim, *nesting)
    version = claim.current_version_record
    klass = "V#{version.json_schema_version}::#{class_type.to_s.camelcase}".constantize

    attributes = claim.attributes.merge(version.data, 'claim' => claim)
    attributes = attributes.dig(*nesting) if nesting.any?

    klass.new(attributes.slice(*klass.attribute_names))
  end

  def self.build_all(class_type, claim, *)
    version = claim.current_version_record
    klass = "V#{version.json_schema_version}::#{class_type.to_s.camelcase}".constantize

    rows = version.data.dig(*)

    build_from_hash(klass, rows, claim)
  end

  def self.build_from_hash(klass, rows, claim)
    if klass.const_defined?(:LINKED_TYPE)
      linked_ids = rows.map { |row| row['id'] }
      all_adjustments = claim.events
                             .where(linked_type: klass::LINKED_TYPE, linked_id: linked_ids)
                             .group_by { |event| [event.linked_type, event.linked_id] }

      rows.map do |attributes|
        key = [attributes.dig('type', 'value') || klass::LINKED_TYPE, attributes['id']]
        adjustments = all_adjustments.fetch(key, [])
        klass.new(adjustments:, **attributes.slice(*klass.attribute_names))
      end
    else
      rows.map do |attributes|
        klass.new(attributes.slice(*klass.attribute_names))
      end
    end
  end

  def self.build_self(attributes)
    new(attributes.slice(*attribute_names))
  end

  def [](val)
    public_send(val)
  end
end
