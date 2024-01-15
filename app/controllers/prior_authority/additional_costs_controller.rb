module PriorAuthority
  class AdditionalCostsController < PriorAuthority::BaseController
    def edit
      crime_application = PriorAuthorityApplication.find(params[:application_id])
      all_costs = BaseViewModel.build(:additional_cost, crime_application, 'additional_costs')
      index = all_costs.index do |model|
        model.id == params[:id]
      end

      item = all_costs[index]
      form = AdditionalCostForm.new(crime_application:, item:, **item.form_attributes)

      render locals: { crime_application:, item:, form:, index: }
    end

    def update
      crime_application = PriorAuthorityApplication.find(params[:application_id])
      all_costs = BaseViewModel.build(:additional_cost, crime_application, 'additional_costs')
      index = all_costs.index do |model|
        model.id == params[:id]
      end

      item = all_costs[index]

      form = AdditionalCostForm.new(crime_application:, item:, **form_params)

      if form.save
        redirect_to prior_authority_application_adjustments_path(crime_application)
      else
        render :edit, locals: { crime_application:, item:, form:, index: }
      end
    end

    private

    def form_params
      params.require(:prior_authority_additional_cost_form).permit(
        :time_spent,
        :explanation,
      ).merge(
        current_user: current_user,
        id: params[:id]
      )
    end
  end
end
