module Nsm
  class AllAdjustmentsDeleter < AdjustmentDeleterBase
    attr_reader :params, :current_user, :submission, :comment

    def initialize(params, adjustment_type, current_user)
      super
      @comment = params[:nsm_delete_adjustments_form][:comment]
    end

    def call
      return false if submission.assessed?

      raise StandardError, "no adjustments to delete for id:#{submission.id}" unless submission.any_adjustments?

      app_store_record = AppStoreClient.new.get_submission(submission)
      submission.update!(data: app_store_record['application'])

      ::Event::DeleteAdjustments.build(submission:, comment:, current_user:)
    end

    def submission_scope
      @submission_scope ||= Claim.pending_and_assigned_to(current_user).find(params[:claim_id])
    end
  end
end
