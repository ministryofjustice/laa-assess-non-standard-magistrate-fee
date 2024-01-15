class BaseViewModel
  include ActiveModel::Model
  include ActiveModel::Attributes

  ID_FIELDS = ['id'].freeze

  class Builder
    attr_reader :klass, :crime_application, :rows, :return_array

    def initialize(class_type, crime_application, *nesting)
      namespace = crime_application.is_a?(Claim) ? 'NonStandardMagistratesPayment' : 'PriorAuthority'
      @klass = "#{namespace}::V#{crime_application.json_schema_version}::#{class_type.to_s.camelcase}".constantize
      @crime_application = crime_application
      if nesting.any?
        @rows = crime_application.data.dig(*nesting)
        @return_array = true
      else
        @rows = [crime_application.data]
        @return_array = false
      end
    end

    def build
      process do |attributes|
        instance = klass.new(params(attributes))

        if adjustments?
          key = [klass::LINKED_TYPE, instance.id]
          instance.adjustments = all_adjustments.fetch(key, [])
        end

        instance
      end
    end

    private

    def params(attributes)
      key = crime_application.is_a?(Claim) ? 'claim' : 'application'
      crime_application.attributes
                       .merge(crime_application.data)
                       .merge(attributes, key => crime_application)
                       .slice(*klass.attribute_names)
    end

    def process(&block)
      result = rows.map(&block)
      return_array ? result : result[0]
    end

    def all_adjustments
      @all_adjustments ||=
        crime_application.events
                         .where(linked_type: klass::LINKED_TYPE)
                         .order(:created_at)
                         .group_by { |event| [event.linked_type, event.linked_id] }
    end

    def adjustments?
      klass.const_defined?(:LINKED_TYPE)
    end
  end

  class << self
    def build(class_type, crime_application, *)
      Builder.new(class_type, crime_application, *).build
    end
  end

  def [](val)
    public_send(val)
  end

  private

  delegate :sanitize, :format_in_zone, :format_period, :multiline_text,
           to: :helpers

  def helpers
    ApplicationController.helpers
  end
end
