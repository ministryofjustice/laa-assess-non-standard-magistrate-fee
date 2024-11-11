module PriorAuthority
  class TravelCostsController < PriorAuthority::BaseController
    def edit
      submission = PriorAuthorityApplication.load_from_app_store(params[:application_id])
      authorize(submission, :edit?)
      all_travel_costs = BaseViewModel.build(:travel_cost, submission, 'quotes')

      item = all_travel_costs.find do |model|
        model.id == params[:id]
      end

      form = TravelCostForm.new(submission:, item:, **item.form_attributes)

      render locals: { submission:, item:, form: }
    end

    def update
      submission = PriorAuthorityApplication.find(params[:application_id])
      authorize(submission, :update?)
      all_travel_costs = BaseViewModel.build(:travel_cost, submission, 'quotes')

      item = all_travel_costs.find do |model|
        model.id == params[:id]
      end

      form = TravelCostForm.new(submission:, item:, **form_params)

      if form.save!
        redirect_to prior_authority_application_adjustments_path(submission)
      else
        render :edit, locals: { submission:, item:, form: }
      end
    end

    def confirm_deletion
      authorize(PriorAuthorityApplication.load_from_app_store(params[:application_id]), :edit?)
      render 'prior_authority/shared/confirm_delete_adjustment',
             locals: { item_name: t('.travel_cost'),
                       deletion_path: prior_authority_application_travel_cost_path(params[:application_id],
                                                                                   params[:id]) }
    end

    def destroy
      deleter = PriorAuthority::AdjustmentDeleter.new(params, :travel_cost, current_user)
      authorize(deleter.submission, :update?)
      deleter.call!
      redirect_to prior_authority_application_adjustments_path(params[:application_id])
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
