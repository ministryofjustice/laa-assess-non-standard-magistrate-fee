class BaseViewModel
  include ActiveModel::Model
  include ActiveModel::Attributes

  ID_FIELDS = ['id'].freeze

  class Builder
    attr_reader :klass, :submission, :rows, :return_array

    def initialize(class_type, submission, *nesting)
      @klass = "#{submission.namespace}::V#{submission.json_schema_version}::#{class_type.to_s.camelcase}".constantize
      @submission = submission
      if nesting.any?
        @rows = submission.data.dig(*nesting)
        @return_array = true
      else
        @rows = [submission.data]
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
      submission.attributes
                .merge(submission.data)
                .merge(attributes, 'submission' => submission)
                .slice(*klass.attribute_names)
    end

    def process(&block)
      result = rows.map(&block)
      return_array ? result : result[0]
    end

    def all_adjustments
      @all_adjustments ||=
        submission.events
                  .select { _1.linked_type == klass::LINKED_TYPE }
                  .sort_by(&:created_at)
                  .group_by { |event| [event.linked_type, event.linked_id] }
    end

    def adjustments?
      klass.const_defined?(:LINKED_TYPE)
    end
  end

  class << self
    def build(class_type, submission, *)
      Builder.new(class_type, submission, *).build
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
