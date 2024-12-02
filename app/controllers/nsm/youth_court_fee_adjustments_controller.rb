module Nsm
  class YouthCourtFeeAdjustmentsController < Nsm::BaseController
    include Nsm::AdjustmentConcern

    def edit
      authorize claim
      form = YouthCourtFeeForm.new(claim:, item:, **item.form_attributes)
      render locals: { claim:, item:, form: }
    end

    def update
      authorize claim
      form = YouthCourtFeeForm.new(claim:, item:, **form_params)
      if form.save!
        redirect_to nsm_claim_work_items_path(claim)
      else
        render :edit, locals: { claim:, item:, form: }
      end
    end

    private

    def form_params
      params.require(:nsm_youth_court_fee_form)
            .permit(:remove_youth_court_fee, :explanation)
            .merge(current_user:)
    end

    def item
      @item ||= BaseViewModel.build(:youth_court_fee, claim)
    end

    def claim
      @claim ||= Claim.load_from_app_store(params[:claim_id])
    end
  end
end
