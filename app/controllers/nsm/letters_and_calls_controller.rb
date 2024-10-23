module Nsm
  class LettersAndCallsController < Nsm::BaseController
    layout nil

    include Nsm::AdjustmentConcern

    FORMS = {
      'letters' => LettersCallsForm::Letters,
      'calls' => LettersCallsForm::Calls
    }.freeze

    def index
      claim = Claim.find(params[:claim_id])
      authorize(claim, :show?)
      records = BaseViewModel.build(:letters_and_calls_summary, claim)
      claim_summary = BaseViewModel.build(:claim_summary, claim)
      core_cost_summary = BaseViewModel.build(:core_cost_summary, claim)
      summary = nil
      scope = :letters_and_calls
      pagy = nil
      type_changed_records = BaseViewModel.build(:work_item, claim, 'work_items').filter do |work_item|
        work_item.work_type != work_item.original_work_type
      end

      render 'nsm/review_and_adjusts/show',
             locals: { claim:, records:, summary:, claim_summary:, core_cost_summary:, pagy:, scope:, type_changed_records: }
    end

    def adjusted
      claim = Claim.find(params[:claim_id])
      authorize(claim, :show?)
      records = BaseViewModel.build(:letters_and_calls_summary, claim)
      claim_summary = BaseViewModel.build(:claim_summary, claim)
      core_cost_summary = BaseViewModel.build(:core_cost_summary, claim)
      scope = :letters_and_calls
      pagy = nil

      render 'nsm/adjustments/show', locals: { claim:, records:, claim_summary:, core_cost_summary:, pagy:, scope: }
    end

    def show
      claim = Claim.find(params[:claim_id])
      authorize(claim)
      item = BaseViewModel.build(:letter_and_call, claim, 'letters_and_calls').detect do |model|
        model.type.value == params[:id]
      end

      render locals: { claim:, item: }
    end

    def edit
      claim = Claim.find(params[:claim_id])
      authorize(claim)
      item = BaseViewModel.build(:letter_and_call, claim, 'letters_and_calls').detect do |model|
        model.type.value == params[:id]
      end
      form = form_class.new(claim:, item:, **item.form_attributes)

      render locals: { claim:, item:, form: }
    end

    def update
      claim = Claim.find(params[:claim_id])
      authorize(claim)
      item = BaseViewModel.build(:letter_and_call, claim, 'letters_and_calls').detect do |model|
        model.type.value == params[:id]
      end
      form = form_class.new(claim:, item:, **form_params)

      if form.save
        redirect_to nsm_claim_letters_and_calls_path(claim)
      else
        render :edit, locals: { claim:, item:, form: }
      end
    end

    private

    def form_class
      FORMS[params[:id]]
    end

    def form_params
      params.require(:"nsm_letters_calls_form_#{params[:id]}").permit(
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
