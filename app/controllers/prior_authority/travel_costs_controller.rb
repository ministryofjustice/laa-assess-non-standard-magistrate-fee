module PriorAuthority
  class TravelCostsController < PriorAuthority::BaseController
    def edit
      submission = PriorAuthorityApplication.find(params[:application_id])
      all_travel_costs = BaseViewModel.build(:travel_cost, submission, 'quotes')

      item = all_travel_costs.find do |model|
        model.id == params[:id]
      end

      form = TravelCostForm.new(submission:, item:, **item.form_attributes)

      render locals: { submission:, item:, form: }
    end

    def update
      submission = PriorAuthorityApplication.find(params[:application_id])
      all_travel_costs = BaseViewModel.build(:travel_cost, submission, 'quotes')

      item = all_travel_costs.find do |model|
        model.id == params[:id]
      end

      form = TravelCostForm.new(submission:, item:, **form_params)

      if form.save
        redirect_to prior_authority_application_adjustments_path(submission)
      else
        render :edit, locals: { submission:, item:, form: }
      end
    end

    private

    def form_params
      params.require(:prior_authority_travel_cost_form).permit(
        :travel_time,
        :travel_cost_per_hour,
        :explanation,
      ).merge(
        current_user: current_user,
        id: params[:id]
      )
    end
  end
end
