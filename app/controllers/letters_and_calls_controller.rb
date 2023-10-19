class LettersAndCallsController < ApplicationController
  layout nil

  def index
    claim = Claim.find(params[:claim_id])
    letters_and_calls = BaseViewModel.build(:letters_and_calls_summary, claim)

    render locals: { claim:, letters_and_calls: }
  end

  def edit
    claim = Claim.find(params[:claim_id])
    item = BaseViewModel.build_all(:letter_and_call, claim, 'letters_and_calls').detect do |model|
      model.type.value == params[:id]
    end
    form = LettersCallsForm.new(id: claim.id, **item.form_attributes)

    render locals: { claim:, item:, form: }
  end
end
