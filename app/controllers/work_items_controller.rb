class WorkItemsController < ApplicationController
  layout nil

  def index
    claim = Claim.find(params[:claim_id])
    work_items = BaseViewModel.build(:work_item, claim, 'work_items').group_by(&:completed_on)
    travel_and_waiting = BaseViewModel.build(:travel_and_waiting, claim)

    render locals: { claim:, work_items:, travel_and_waiting: }
  end

  def edit
    claim = Claim.find(params[:claim_id])
    item = BaseViewModel.build(:work_item, claim, 'work_items').detect do |model|
      model.id == params[:id]
    end

    form = WorkItemForm.new(claim:, item:)

    render locals: { claim:, item:, form: }
  end

  def update
    claim = Claim.find(params[:claim_id])
    item = BaseViewModel.build(:work_item, claim, 'work_items').detect do |model|
      model.id == params[:id]
    end

    form = WorkItemForm.new(claim:, item:, **form_params)

    if form.save
      redirect_to claim_adjustments_path(claim, anchor: 'work-items-tab')
    else
      render :edit, locals: { claim:, item:, form: }
    end
  end

  private

  def form_params
    params.require(:work_item_form).permit(
      :work_type,
      :uplift,
      :time_spent,
      :explanation
    ).merge(
      current_user: current_user,
      id: params[:id]
    )
  end
end
