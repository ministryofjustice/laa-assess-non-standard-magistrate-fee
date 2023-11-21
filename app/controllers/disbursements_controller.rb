class DisbursementsController < ApplicationController
  layout nil

  def index
    claim = Claim.find(params[:claim_id])
    disbursements = BaseViewModel.build(:disbursement, claim, 'disbursements').group_by(&:disbursement_date)

    render locals: { claim:, disbursements: }
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
      redirect_to claim_adjustments_path(claim, anchor: 'disbursements-tab')
    else
      render :edit, locals: { claim:, item:, form: }
    end
  end

  private

  def form_params
    params.require(:disbursements_form).permit(
      :total_cost_without_vat,
      :explanation,
    ).merge(
      current_user:
    )
  end
end
