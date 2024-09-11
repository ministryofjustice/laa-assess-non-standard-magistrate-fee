module Nsm
  class AllAdjustmentsDeleter < AdjustmentDeleterBase
    attr_reader :params, :current_user, :submission

    def call
      delete_work_item_adjustments if work_items
      delete_letters_and_calls_adjustments if letters_and_calls
      delete_disbursement_adjustments if disbursements
      submission.save!
    end

    def delete_work_item_adjustments
      work_items.each do |work_item|
        %w[uplift pricing work_type time_spent].each do |field|
          revert(work_item, field, 'work_items')
        end
        work_item.delete('adjustment_comment')
      end
    end

    def delete_letters_and_calls_adjustments
      letters_and_calls.each do |letter_or_call|
        %w[uplift count].each do |field|
          revert(letter_or_call, field, letter_or_call['type']['value'])
          letter_or_call.delete('adjustment_comment')
        end
      end
    end

    def delete_disbursement_adjustments
      disbursements.each do |disbursement|
        %w[total_cost vat_amount total_cost_without_vat].each do |field|
          revert(disbursement, field, 'disbursements')
        end
        disbursement.delete('adjustment_comment')
      end
    end

    def letters_and_calls
      @letters_and_calls ||= submission.data['letters_and_calls'].filter { _1['adjustment_comment'] }
    end

    def disbursements
      @disbursements ||= submission.data['disbursements'].filter {_1['adjustment_comment'] }
    end

    def work_items
      @work_items ||= submission.data['work_items'].filter { _1['adjustment_comment'] }
    end

    def submission_scope
      @submission_scope ||= Claim.pending_and_assigned_to(current_user).find(params[:claim_id])
    end
  end
end
