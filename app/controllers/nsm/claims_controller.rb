module Nsm
  class ClaimsController < Nsm::BaseController
    include AssignmentConcern
    before_action :set_default_table_sort_options, only: %i[your open closed]
    before_action :authorize_list, only: %i[your open closed]

    def your
      return redirect_to open_nsm_claims_path unless policy(Claim).assign?

      @current_section = :your
      model = Nsm::V1::YourClaims.new(controller_params.permit(:page, :sort_by, :sort_direction).merge(current_user:))
      model.execute
      render locals: { your_claims: model.results, pagy: model.pagy }
    end

    def open
      @current_section = :open
      model = Nsm::V1::OpenClaims.new(controller_params.permit(:page, :sort_by, :sort_direction))
      model.execute
      @pagy = model.pagy
      @claims = model.results
    end

    def closed
      @current_section = :closed
      model = Nsm::V1::ClosedClaims.new(controller_params.permit(:page, :sort_by, :sort_direction))
      model.execute
      @pagy = model.pagy
      @claims = model.results
    end

    def create
      authorize Claim, :assign?
      claim_data = AppStoreClient.new.auto_assign(Submission::APPLICATION_TYPES[:nsm], current_user.id)

      if claim_data
        claim = Claim.rehydrate(claim_data)
        assign(claim, tell_app_store: false)
        redirect_to nsm_claim_claim_details_path(claim)
      else
        redirect_to your_nsm_claims_path, flash: { notice: t('.no_pending_claims') }
      end
    end

    private

    def controller_params
      safe_params = params.permit(
        :id,
        :sort_by,
        :sort_direction,
        :page
      )
      param_model = Nsm::ControllerParams::Claims.new(safe_params)
      raise param_model.error_summary.to_s unless param_model.valid?

      safe_params
    end

    def set_default_table_sort_options
      default = 'date_updated'
      @sort_by = controller_params.fetch(:sort_by, default)
      @sort_direction = controller_params.fetch(:sort_direction, 'descending')
    end

    def authorize_list
      authorize Claim, :index?
    end

    def submission_id
      controller_params[:id]
    end

    def secondary_id
      nil
    end
  end
end
