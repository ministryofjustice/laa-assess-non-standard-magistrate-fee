module Nsm
  class WorkItemsController < ApplicationController
    layout nil

    def index
      claim = Claim.find(params[:claim_id])
      items = BaseViewModel.build(:work_item, claim, 'work_items')
      pagy, work_items = pagy_array(items.sort_by(&:completed_on))
      work_item_summary = BaseViewModel.build(:work_item_summary, claim)

      render locals: { claim:, work_items:, work_item_summary:, pagy: }
    end

    def show
      claim = Claim.find(params[:claim_id])
      item = BaseViewModel.build(:work_item, claim, 'work_items').detect do |model|
        model.id == params[:id]
      end

      render locals: { claim:, item: }
    end

    def edit
      claim = Claim.find(params[:claim_id])
      item = BaseViewModel.build(:work_item, claim, 'work_items').detect do |model|
        model.id == params[:id]
      end

      form = WorkItemForm.new(claim:, item:, **item.form_attributes)

      render locals: { claim:, item:, form: }
    end

    def update
      claim = Claim.find(params[:claim_id])
      item = BaseViewModel.build(:work_item, claim, 'work_items').detect do |model|
        model.id == params[:id]
      end

      form = WorkItemForm.new(claim:, item:, **form_params)

      if form.save
        redirect_to nsm_claim_adjustments_path(claim, anchor: 'work-items-tab')
      else
        render :edit, locals: { claim:, item:, form: }
      end
    end

    private

    def form_params
      params.require(:nsm_work_item_form).permit(
        :uplift,
        :time_spent,
        :explanation
      ).merge(
        current_user: current_user,
        id: params[:id]
      )
    end
  end
end
