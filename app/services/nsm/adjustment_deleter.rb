module Nsm
  class AdjustmentDeleter < AdjustmentDeleterBase
    attr_reader :params, :adjustment_type, :current_user, :submission

    def call
      case adjustment_type
      when :work_item
        delete_work_item_adjustment
      when :letter_and_call
        delete_letters_and_calls_adjustment
      when :disbursement
        delete_disbursement_adjustment
      when :youth_court_fee
        delete_youth_court_fee_adjustment
      else
        raise "Unknown adjustment type '#{adjustment_type}'"
      end
    end

    def delete_work_item_adjustment
      %w[uplift work_type time_spent].each do |field|
        revert(work_item, field, 'work_items')
      end
      work_item.delete('adjustment_comment')
    end

    def delete_letters_and_calls_adjustment
      %w[uplift count].each do |field|
        revert(letters_and_calls, field, params[:id])
        letters_and_calls.delete('adjustment_comment')
      end
    end

    def delete_disbursement_adjustment
      %w[total_cost vat_amount total_cost_without_vat].each do |field|
        revert(disbursement, field, 'disbursements')
      end
      disbursement.delete('adjustment_comment')
    end

    def delete_youth_court_fee_adjustment
      revert(submission.data, 'include_youth_court_fee', 'additional_fees')
      submission.data.delete('youth_court_fee_adjustment_comment')
    end

    def letters_and_calls
      @letters_and_calls ||= submission.data['letters_and_calls'].find do |row|
        Type::TranslatedObject.new.cast(row['type']).value == params[:id]
      end
    end

    def disbursement
      @disbursement ||= submission.data['disbursements'].find { _1['id'] == params[:id] }
    end

    def work_item
      @work_item ||= submission.data['work_items'].find { _1['id'] == params[:id] }
    end
  end
end
