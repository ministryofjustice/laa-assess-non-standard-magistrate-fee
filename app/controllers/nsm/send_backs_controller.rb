module Nsm
  class SendBacksController < Nsm::BaseController
    include NameConstructable

    def edit
      send_back = SendBackForm.new(claim:)
      render locals: { claim:, send_back:, defendant_name: }
    end

    # TODO: put some sort of permissions here for non supervisors?
    def update
      send_back = SendBackForm.new(claim:, **send_back_params)
      if send_back.save
        reference = BaseViewModel.build(:laa_reference, claim)
        success_notice = t(
          '.decision',
          ref: reference.laa_reference,
          url: nsm_claim_claim_details_path(claim.id)
        )
        redirect_to your_nsm_claims_path, flash: { success: success_notice }
      else
        render :edit, locals: { claim:, send_back:, defendant_name: }
      end
    end

    private

    def claim
      @claim ||= Claim.find(params[:claim_id])
    end

    def defendant_name
      defendants = claim.data['defendants']
      main_defendant = defendants.detect { |defendant| defendant['main'] }
      main_defendant ? construct_name(main_defendant) : ''
    end

    def send_back_params
      params.require(:nsm_send_back_form).permit(
        :state, :comment,
      ).merge(current_user:)
    end
  end
end
