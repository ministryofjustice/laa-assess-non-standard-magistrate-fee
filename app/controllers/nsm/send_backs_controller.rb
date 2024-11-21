module Nsm
  class SendBacksController < Nsm::BaseController
    include NameConstructable

    def show
      authorize(claim)
    end

    def edit
      authorize(claim)
      send_back = SendBackForm.new(claim: claim, send_back_comment: claim.data['send_back_comment'])
      render locals: { claim:, send_back: }
    end

    def update
      authorize(claim)
      send_back = SendBackForm.new(claim:, **send_back_params)
      if params['save_and_exit']
        send_back.stash
        redirect_to your_nsm_claims_path
      elsif send_back.save
        redirect_to nsm_claim_send_back_path(claim)
      else
        render :edit, locals: { claim:, send_back: }
      end
    end

    private

    def claim
      @claim ||= Claim.load_from_app_store(params[:claim_id])
    end

    def send_back_params
      params.require(:nsm_send_back_form).permit(
        :send_back_comment,
      ).merge(current_user:)
    end
  end
end
