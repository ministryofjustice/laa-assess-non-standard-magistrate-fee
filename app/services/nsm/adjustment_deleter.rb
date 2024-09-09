module Nsm
  class AdjustmentDeleter < AdjustmentDeleterBase
    attr_reader :params, :adjustment_type, :current_user, :submission

    def call
      case adjustment_type
      when :work_item
        delete_work_item_adjustment
      when :letters
        delete_letters_adjustment
      when :calls
        delete_calls_adjustment
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

    def delete_letters_adjustment
      %w[uplift count].each do |field|
        revert(letters, field, 'letters')
        letters.delete('adjustment_comment')
      end
    end

    def delete_calls_adjustment
      %w[uplift count].each do |field|
        revert(calls, field, 'calls')
        calls.delete('adjustment_comment')
      end
    end

    def delete_disbursement_adjustment
      %w[total_cost vat_amount total_cost_without_vat].each do |field|
        revert(disbursement, field, 'disbursements')
      end
      disbursement.delete('adjustment_comment')
    end

    def letters
      @letters ||= submission.data['letters_and_calls'].find { _1.dig('type', 'value') == 'letters' }
    end

    def calls
      @calls ||= submission.data['letters_and_calls'].find { _1.dig('type', 'value') == 'calls' }
    end

    def disbursement
      @disbursement ||= submission.data['disbursements'].find { _1['id'] == params[:id] }
    end

    def work_item
      @work_item ||= submission.data['work_items'].find { _1['id'] == params[:id] }
    end

    def submission_scope
      @submission_scope ||= Claim.find(params[:application_id])
    end
  end
end
