module Nsm
  class HistoriesController < Nsm::BaseController
    def show
      claim = Claim.load_from_app_store(params[:claim_id])
      authorize(claim)
      claim_summary = BaseViewModel.build(:claim_summary, claim)
      pagy, history_events = pagy(claim.events.history)
      claim_note = ClaimNoteForm.new(id: claim.id)

      render locals: { claim:, claim_summary:, history_events:, claim_note:, pagy: }
    end

    def create
      claim = Claim.load_from_app_store(params[:claim_id])
      authorize(claim, :edit?)
      claim_note = ClaimNoteForm.new(claim_note_params)
      if claim_note.save
        redirect_to nsm_claim_history_path(claim_note.id)
      else
        claim_summary = BaseViewModel.build(:claim_summary, claim)
        pagy, history_events = pagy(claim.events.history)

        render :show, locals: { claim:, claim_summary:, history_events:, claim_note:, pagy: }
      end
    end

    private

    def claim_note_params
      params.require(:nsm_claim_note_form).permit(
        :note
      ).merge(current_user: current_user, id: params[:claim_id])
    end
  end
end
