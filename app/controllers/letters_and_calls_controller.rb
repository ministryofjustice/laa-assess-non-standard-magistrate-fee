class LettersAndCallsController < ApplicationController
  layout nil

  def index
    claim = Claim.find(params[:claim_id])
    letters_and_calls_items = BaseViewModel.build_all(:letter_and_call, claim, 'letters_and_calls')
    letters_and_calls_summary = BaseViewModel.build(:letters_and_calls_summary, claim)
    render locals: { claim:, letters_and_calls_items:, letters_and_calls_summary: }
  end
end
