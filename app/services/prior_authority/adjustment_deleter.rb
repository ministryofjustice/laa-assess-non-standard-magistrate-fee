module PriorAuthority
  class AdjustmentDeleter < AdjustmentDeleterBase
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

    def submission_scope
      @submission_scope ||= PriorAuthorityApplication.find(params[:application_id])
    end
  end
end
