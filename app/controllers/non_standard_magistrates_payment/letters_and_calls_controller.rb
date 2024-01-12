module NonStandardMagistratesPayment
  class LettersAndCallsController < ApplicationController
    layout nil

    FORMS = {
      'letters' => LettersCallsForm::Letters,
      'calls' => LettersCallsForm::Calls
    }.freeze

    def index
      claim = Claim.find(params[:claim_id])
      letters_and_calls = BaseViewModel.build(:letters_and_calls_summary, claim)

      render locals: { claim:, letters_and_calls: }
    end

    def show
      claim = Claim.find(params[:claim_id])
      item = BaseViewModel.build(:letter_and_call, claim, 'letters_and_calls').detect do |model|
        model.type.value == params[:id]
      end

      render locals: { claim:, item: }
    end

    def edit
      claim = Claim.find(params[:claim_id])
      item = BaseViewModel.build(:letter_and_call, claim, 'letters_and_calls').detect do |model|
        model.type.value == params[:id]
      end
      form = form_class.new(claim:, item:, **item.form_attributes)

      render locals: { claim:, item:, form: }
    end

    def update
      claim = Claim.find(params[:claim_id])
      item = BaseViewModel.build(:letter_and_call, claim, 'letters_and_calls').detect do |model|
        model.type.value == params[:id]
      end
      form = form_class.new(claim:, item:, **form_params)

      if form.save
        redirect_to non_standard_magistrates_payment_claim_adjustments_path(claim, anchor: 'letters-and-calls-tab')
      else
        render :edit, locals: { claim:, item:, form: }
      end
    end

    private

    def form_class
      FORMS[params[:id]]
    end

    def form_params
      params.require(:"letters_calls_form_#{params[:id]}").permit(
        :uplift,
        :count,
        :explanation,
      ).merge(
        current_user: current_user,
        type: params[:id]
      )
    end
  end
end
