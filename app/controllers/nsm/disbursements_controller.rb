module Nsm
  class DisbursementsController < Nsm::BaseController
    ITEM_COUNT_OVERRIDE = 100
    layout nil

    before_action :set_default_table_sort_options, only: %i[index adjusted]

    include Nsm::AdjustmentConcern

    def index
      claim = Claim.find(params[:claim_id])
      claim_summary = BaseViewModel.build(:claim_summary, claim)
      core_cost_summary = BaseViewModel.build(:core_cost_summary, claim)
      items = BaseViewModel.build(:disbursement, claim, 'disbursements')
      sorted_items = Sorters::DisbursementsSorter.call(items, @sort_by, @sort_direction)
      pagy, records = pagy_array(sorted_items, limit: ITEM_COUNT_OVERRIDE)
      summary = nil
      scope = :disbursements
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
      items = BaseViewModel.build(:disbursement, claim, 'disbursements').filter(&:any_adjustments?)
      sorted_items = Sorters::DisbursementsSorter.call(items, @sort_by, @sort_direction)
      pagy, records = pagy_array(sorted_items, limit: ITEM_COUNT_OVERRIDE)
      scope = :disbursements

      render 'nsm/adjustments/show', locals: { claim:, records:, claim_summary:, core_cost_summary:, pagy:, scope: }
    end

    def show
      claim = Claim.find(params[:claim_id])
      item = BaseViewModel.build(:disbursement, claim, 'disbursements').detect do |model|
        model.id == params[:id]
      end

      render locals: { claim:, item: }
    end

    def edit
      claim = Claim.find(params[:claim_id])
      item = BaseViewModel.build(:disbursement, claim, 'disbursements').detect do |model|
        model.id == params[:id]
      end

      form = DisbursementsForm.new(claim:, item:, **item.form_attributes)
      render locals: { claim:, item:, form: }
    end

    def update
      claim = Claim.find(params[:claim_id])
      item = BaseViewModel.build(:disbursement, claim, 'disbursements').detect do |model|
        model.id == params[:id]
      end
      form = DisbursementsForm.new(claim:, item:, **form_params)
      if form.save
        redirect_to nsm_claim_disbursements_path(claim)
      else
        render :edit, locals: { claim:, item:, form: }
      end
    end

    private

    def form_params
      params.require(:nsm_disbursements_form).permit(
        :total_cost_without_vat,
        :explanation,
        :miles,
        :apply_vat,
      ).merge(
        current_user:
      )
    end

    def set_default_table_sort_options
      default = 'item'
      @sort_by = params.fetch(:sort_by, default)
      @sort_direction = params.fetch(:sort_direction, 'ascending')
    end
  end
end
