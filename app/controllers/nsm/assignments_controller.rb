module Nsm
  class AssignmentsController < Nsm::BaseController
    before_action :claim, only: %i[new create]

    def new
      authorize claim, :self_assign?
      @form = AssignmentForm.new
    end

    def create
      @form = AssignmentForm.new(params.require(:nsm_assignment_form).permit(:comment))
      if @form.valid?
        process_assignment(@form.comment)
      else
        skip_authorization
        render :new
      end
    end

    private

    def process_assignment(comment)
      claim.with_lock do
        if claim.assignments.none?
          authorize(claim, :self_assign?)
          assign_claim(comment)

          redirect_to nsm_claim_claim_details_path(claim)
        else
          skip_authorization
          redirect_to nsm_claim_claim_details_path(claim), flash: { notice: t('.already_assigned') }
        end
      end
    end

    def assign_claim(comment)
      Claim.transaction do
        claim.assignments.create!(user: current_user)
        ::Event::Assignment.build(submission: claim, current_user: current_user, comment: comment)
      end
    end

    def claim
      @claim ||= Claim.find(params[:claim_id])
    end
  end
end
