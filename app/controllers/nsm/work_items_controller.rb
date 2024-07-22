module Nsm
  class WorkItemsController < Nsm::BaseController
    ITEM_COUNT_OVERRIDE = 100
    layout nil

    before_action :set_default_table_sort_options, only: %i[index adjusted]

    def index
      claim = Claim.find(params[:claim_id])
      claim_summary = BaseViewModel.build(:claim_summary, claim)
      core_cost_summary = BaseViewModel.build(:core_cost_summary, claim)
      items = BaseViewModel.build(:work_item, claim, 'work_items')
      sorted_items = Sorters::WorkItemsSorter.call(items, @sort_by, @sort_direction)
      pagy, records = pagy_array(sorted_items, items: ITEM_COUNT_OVERRIDE)
      summary = BaseViewModel.build(:work_item_summary, claim)
      scope = :work_items

      render 'nsm/review_and_adjusts/show', locals: { claim:, records:, summary:, claim_summary:, core_cost_summary:, pagy:, scope:  }
    end

    def adjusted
      claim = Claim.find(params[:claim_id])
      claim_summary = BaseViewModel.build(:claim_summary, claim)
      core_cost_summary = BaseViewModel.build(:core_cost_summary, claim)
      items = BaseViewModel.build(:work_item, claim, 'work_items').filter(&:any_adjustments?)
      sorted_items = Sorters::WorkItemsSorter.call(items, @sort_by, @sort_direction)
      pagy, records = pagy_array(sorted_items, items: ITEM_COUNT_OVERRIDE)
      scope = :work_items

      render 'nsm/adjustments/show', locals: { claim:, records:, claim_summary:, core_cost_summary:, pagy:, scope: }
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
        redirect_to nsm_claim_work_items_path(claim)
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

    def set_default_table_sort_options
      default = 'item'
      @sort_by = params.fetch(:sort_by, default)
      @sort_direction = params.fetch(:sort_direction, 'ascending')
    end
  end
end
