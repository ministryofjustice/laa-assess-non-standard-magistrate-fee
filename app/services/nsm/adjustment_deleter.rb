module Nsm
  class AdjustmentDeleter < AdjustmentDeleterBase
    attr_reader :params, :adjustment_type, :current_user, :submission

    def call
      return false if submission.assessed?

      case adjustment_type
      when :work_item
        delete_work_item_adjustment
      when :letter_and_call
        delete_letters_and_calls_adjustment
      when :disbursement
        delete_disbursement_adjustment
      else
        raise "Unknown adjustment type '#{adjustment_type}'"
      end
      submission.save!
    end

    def delete_work_item_adjustment
      %w[uplift pricing work_type time_spent].each do |field|
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

    def letters_and_calls
      @letters_and_calls ||= submission.data['letters_and_calls'].find { _1.dig('type', 'value') == params[:id] }
    end

    def disbursement
      @disbursement ||= submission.data['disbursements'].find { _1['id'] == params[:id] }
    end

    def work_item
      @work_item ||= submission.data['work_items'].find { _1['id'] == params[:id] }
    end

    def submission_scope
      @submission_scope ||= Claim.pending_and_assigned_to(current_user).find(params[:claim_id])
    end
  end
end
