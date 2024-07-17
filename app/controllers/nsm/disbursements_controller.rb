module Nsm
  class DisbursementsController < Nsm::BaseController
    ITEM_COUNT_OVERRIDE = 100
    layout nil

    before_action :set_default_table_sort_options

    def index
      claim = Claim.find(params[:claim_id])
      items = BaseViewModel.build(:disbursement, claim, 'disbursements')
      sorted_items = Sorters::DisbursementsSorter.call(items, @sort_by, @sort_direction)
      pagy, disbursements = pagy_array(sorted_items, items: ITEM_COUNT_OVERRIDE)
      render locals: { claim:, disbursements:, pagy: }
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
        redirect_to nsm_claim_adjustments_path(claim, anchor: 'disbursements-tab')
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
