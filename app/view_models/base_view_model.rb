class BaseViewModel
  include ActiveModel::Model
  include ActiveModel::Attributes

  def self.build(class_type, claim, *nesting)
    version = claim.current_version_record
    klass = "V#{version.json_schema_version}::#{class_type.to_s.camelcase}".constantize

    attributes = version.data
    attributes = attributes.dig(*nesting) if nesting.any?

    klass.new(attributes.slice(*klass.attribute_names))
  end

  def self.build_all(class_type, claim, *)
    version = claim.current_version_record
    klass = "V#{version.json_schema_version}::#{class_type.to_s.camelcase}".constantize

    rows = version.data[*]

    rows.map do |attributes|
      klass.new(attributes.slice(*klass.attribute_names))
    end
  end

  def self.build_self(attributes)
    new(attributes.slice(*attribute_names))
  end
end
