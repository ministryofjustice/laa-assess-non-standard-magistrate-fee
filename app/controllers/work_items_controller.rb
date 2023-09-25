class WorkItemsController < ApplicationController
  layout nil

  def index
    claim = Claim.find(params[:claim_id])
    work_items = BaseViewModel.build_all(:work_item, claim, 'work_items').group_by(&:completed_on)
    work_items_summary = BaseViewModel.build(:work_items_summary, claim)

    render locals: { claim:, work_items:, work_items_summary: }
  end
end
