class LettersAndCallsController < ApplicationController
  layout nil

  def index
    claim = Claim.find(params[:claim_id])
    letters_and_calls = BaseViewModel.build(:letters_and_calls_summary, claim)

    render locals: { claim:, letters_and_calls: }
  end

  def edit
    claim = Claim.find(params[:claim_id])
    item = BaseViewModel.build(:letter_and_call, claim, 'letters_and_calls').detect do |model|
      model.type.value == params[:id]
    end
    form = LettersCallsForm.new(claim:, **item.form_attributes)

    render locals: { claim:, item:, form: }
  end

  def update
    claim = Claim.find(params[:claim_id])
    item = BaseViewModel.build(:letter_and_call, claim, 'letters_and_calls').detect do |model|
      model.type.value == params[:id]
    end
    form = LettersCallsForm.new(claim:, item:, **form_params)

    if form.save
      redirect_to claim_adjustments_path(claim, anchor: 'letters-and-calls-tab')
    else
      render :edit, locals: { claim:, item:, form: }
    end
  end

  private

  def form_params
    params.require(:letters_calls_form).permit(
      :uplift,
      :count,
      :explanation,
    ).merge(
      current_user: current_user,
      type: params[:id]
    )
  end
end
