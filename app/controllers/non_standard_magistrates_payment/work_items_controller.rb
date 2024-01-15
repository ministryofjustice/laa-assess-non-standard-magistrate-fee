module NonStandardMagistratesPayment
  class WorkItemsController < ApplicationController
    layout nil

    def index
      claim = Claim.find(params[:claim_id])
      work_items = BaseViewModel.build(:work_item, claim, 'work_items')
      travel_and_waiting = BaseViewModel.build(:travel_and_waiting, claim)

      render locals: { claim:, work_items:, travel_and_waiting: }
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
        redirect_to non_standard_magistrates_payment_claim_adjustments_path(claim, anchor: 'work-items-tab')
      else
        render :edit, locals: { claim:, item:, form: }
      end
    end

    private

    def form_params
      params.require(:non_standard_magistrates_payment_work_item_form).permit(
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
