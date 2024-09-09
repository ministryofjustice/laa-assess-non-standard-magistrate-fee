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
      pagy, records = pagy_array(sorted_items, limit: ITEM_COUNT_OVERRIDE)
      summary = BaseViewModel.build(:work_item_summary, claim)
      scope = :work_items
      type_changed_records = BaseViewModel.build(:work_item, claim, 'work_items').filter do |work_item|
        work_item.work_type != work_item.original_work_type
      end

      render 'nsm/review_and_adjusts/show',
             locals: { claim:, records:, summary:, claim_summary:, core_cost_summary:, pagy:, scope:, type_changed_records: }
    end

    def adjusted
      claim = Claim.find(params[:claim_id])
      claim_summary = BaseViewModel.build(:claim_summary, claim)
      core_cost_summary = BaseViewModel.build(:core_cost_summary, claim)
      items = BaseViewModel.build(:work_item, claim, 'work_items').filter(&:any_adjustments?)
      sorted_items = Sorters::WorkItemsSorter.call(items, @sort_by, @sort_direction)
      pagy, records = pagy_array(sorted_items, limit: ITEM_COUNT_OVERRIDE)
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

      form = WorkItemForm.new(**common_form_attributes(claim, item),
                              **item.form_attributes)

      render locals: { claim:, item:, form: }
    end

    def update
      claim = Claim.find(params[:claim_id])
      item = BaseViewModel.build(:work_item, claim, 'work_items').detect do |model|
        model.id == params[:id]
      end

      form = WorkItemForm.new(**common_form_attributes(claim, item), **form_params)

      if form.save
        redirect_to nsm_claim_work_items_path(claim)
      else
        render :edit, locals: { claim:, item:, form: }
      end
    end

    def confirm_deletion
      render 'nsm/shared/confirm_delete_adjustment',
             locals: { item_name: t('.work_item'),
                       deletion_path: nsm_claim_work_items_path(params[:claim_id],
                                                                params[:id]),
                       nsm_adjustments_path: adjusted_nsm_claim_work_items_path }
    end

    def destroy
      Nsm::AdjustmentDeleter.new(params, :work_item, current_user).call
      redirect_to nsm_claim_adjustments_path(params[:application_id])
    end

    private

    def common_form_attributes(claim, item)
      {
        claim: claim,
        item: item,
        work_item_pricing: claim.data['work_item_pricing'],
      }
    end

    def form_params
      params.require(:nsm_work_item_form).permit(
        :uplift,
        :time_spent,
        :explanation,
        :work_type_value,
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
