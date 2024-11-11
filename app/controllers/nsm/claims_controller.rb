module Nsm
  class ClaimsController < Nsm::BaseController
    include AssignmentConcern
    before_action :set_default_table_sort_options, only: %i[your open closed]
    before_action :authorize_list, only: %i[your open closed]

    def your
      return redirect_to open_nsm_claims_path unless policy(Claim).assign?

      @current_section = :your
      model = Nsm::V1::YourClaims.new(params.permit(:page, :sort_by, :sort_direction).merge(current_user:))
      model.execute
      render locals: { your_claims: model.results, pagy: model.pagy }
    end

    def open
      @current_section = :open
      model = Nsm::V1::OpenClaims.new(params.permit(:page, :sort_by, :sort_direction))
      model.execute
      @pagy = model.pagy
      @claims = model.results
    end

    def closed
      @current_section = :closed
      model = Nsm::V1::ClosedClaims.new(params.permit(:page, :sort_by, :sort_direction))
      model.execute
      @pagy = model.pagy
      @claims = model.results
    end

    def create
      authorize Claim, :assign?
      claim_data = AppStoreClient.new.auto_assign(Submission::APPLICATION_TYPES[:nsm], current_user.id)

      if claim_data
        claim = Claim.find_by(id: claim_data['application_id']) || UpdateSubmission.call(claim_data)
        assign(claim, tell_app_store: false)
        redirect_to nsm_claim_claim_details_path(claim)
      else
        redirect_to your_nsm_claims_path, flash: { notice: t('.no_pending_claims') }
      end
    end

    private

    def set_default_table_sort_options
      default = 'date_updated'
      @sort_by = params.fetch(:sort_by, default)
      @sort_direction = params.fetch(:sort_direction, 'descending')
    end

    def authorize_list
      authorize Claim, :index?
    end

    def submission_id
      params[:id]
    end

    def secondary_id
      nil
    end
  end
end
