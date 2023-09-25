class HistoriesController < ApplicationController
  def show
    claim = Claim.find(params[:claim_id])
    claim_summary = BaseViewModel.build(:claim_summary, claim)
    history_events = claim.events.history

    render locals: { claim:, claim_summary:, history_events: }
  end
end
