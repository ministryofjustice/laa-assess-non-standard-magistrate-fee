module Nsm
  class AssignmentsController < PriorAuthority::AssignmentsController
    def new
      @form = AssignmentForm.new
    end

    def create
      @form = AssignmentForm.new(params.require(:nsm_assignment_form).permit(:comment))
      if @form.valid?
        process_assignment(@form.comment)
      else
        render :new
      end
    end

    private

    def process_assignment(comment)
      submission = Claim.find(params[:claim_id])
      submission.with_lock do
        if submission.assignments.none?
          Claim.transaction do
            submission.assignments.create!(user: current_user)
            ::Event::Assignment.build(submission:, current_user:, comment:)
          end

          redirect_to nsm_claim_claim_details_path(submission)
        else
          redirect_to nsm_claim_claim_details_path(submission), flash: { notice: t('.already_assigned') }
        end
      end
    end
  end
end
