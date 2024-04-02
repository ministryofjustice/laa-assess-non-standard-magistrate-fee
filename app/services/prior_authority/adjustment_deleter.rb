module PriorAuthority
  class AdjustmentDeleter
    attr_reader :params, :adjustment_type, :current_user, :submission

    def initialize(params, adjustment_type, current_user)
      @params = params
      @adjustment_type = adjustment_type
      @current_user = current_user
      @submission = PriorAuthorityApplication.find(params[:application_id])
    end

    def call
      case adjustment_type
      when :service_cost
        delete_service_cost_adjustment
      when :travel_cost
        delete_travel_cost_adjustment
      when :additional_cost
        delete_additional_cost_adjustment
      else
        raise "Unknown adjustment type '#{adjustment_type}'"
      end
      submission.save!
    end

    def delete_service_cost_adjustment
      %w[items cost_per_item period cost_per_hour].each do |field|
        revert(quote, field, 'quotes')
      end
      quote.delete('adjustment_comment')
    end

    def delete_travel_cost_adjustment
      %w[travel_time travel_cost_per_hour].each do |field|
        revert(quote, field, 'quotes')
      end
      quote.delete('travel_adjustment_comment')
    end

    def delete_additional_cost_adjustment
      %w[items cost_per_item period cost_per_hour].each do |field|
        revert(additional_cost, field, 'additional_costs')
      end
      additional_cost.delete('adjustment_comment')
    end

    def quote
      @quote ||= submission.data['quotes'].find { _1['id'] == params[:id] }
    end

    def additional_cost
      @additional_cost ||= submission.data['additional_costs'].find { _1['id'] == params[:id] }
    end

    def revert(object, field, object_type)
      return unless object["#{field}_original"]

      if object[field] != object["#{field}_original"]
        create_event(field, object_type, object[field], object["#{field}_original"], object['id'])
      end

      object[field] = object["#{field}_original"]
      object.delete("#{field}_original")
    end

    def create_event(field, type, from, to_field, id_field)
      linked = { type: type, id: id_field }
      details = { field: field, from: from, to: to_field }
      ::Event::UndoEdit.build(submission:, linked:, details:, current_user:)
    end
  end
end
