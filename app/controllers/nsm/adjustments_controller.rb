module Nsm
  class AdjustmentsController < Nsm::BaseController
    def confirm_deletion
      authorize claim, :update?
      form = DeleteAdjustmentsForm.new

      render :confirm_deletion_adjustments, locals: { deletion_path:, form: }
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def delete_all
      authorize claim, :update?

      form = DeleteAdjustmentsForm.new(**safe_params)
      deleter = Nsm::AllAdjustmentsDeleter.new(params, nil, current_user, claim)

      records = BaseViewModel.build(:additional_fees_summary, claim)
      claim_summary = BaseViewModel.build(:claim_summary, claim)
      core_cost_summary = BaseViewModel.build(:core_cost_summary, claim)
      summary = nil
      scope = :work_items
      pagy = nil
      type_changed_records = BaseViewModel.build(:work_item, claim, 'work_items').filter do |work_item|
        work_item.work_type != work_item.original_work_type
      end
      success_locals = { claim:, records:, summary:, claim_summary:, core_cost_summary:, pagy:, scope:, type_changed_records: }

      if form.valid?
        deleter.call!
        redirect_to 'nsm/review_and_adjusts/show',
                    locals: success_locals, flash: { success: t('.success') }
      else
        render :confirm_deletion_adjustments, locals: { deletion_path:, form: }
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    private

    def claim
      @claim ||= Claim.load_from_app_store(params[:claim_id])
    end

    def deletion_path
      delete_all_nsm_claim_adjustments_path(params[:claim_id])
    end

    def safe_params
      params.require(:nsm_delete_adjustments_form).permit(:comment)
    end
  end
end
