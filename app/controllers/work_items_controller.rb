class WorkItemsController < ApplicationController
  layout nil

  def index
    claim = Claim.find(params[:claim_id])
    claim_summary = BaseViewModel.build(:claim_summary, claim)
    work_items = BaseViewModel.build_all(:work_item, claim, 'work_items').group_by(&:completed_on)

    render locals: { claim:, claim_summary:, work_items: }
  end
end
