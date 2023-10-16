class WorkItemsController < ApplicationController
  layout nil

  def index
    claim = Claim.find(params[:claim_id])
    work_items = BaseViewModel.build_all(:work_item, claim, 'work_items').group_by(&:completed_on)
    travel_and_waiting = BaseViewModel.build(:travel_and_waiting, claim)

    render locals: { claim:, work_items:, travel_and_waiting: }
  end
end
