module PriorAuthority
  class DecisionsController < PriorAuthority::BaseController
    def show
      authorize(submission)
      @summary = BaseViewModel.build(:application_summary, submission)
      @decision = BaseViewModel.build(:decision, submission)
    end

    def new
      authorize(submission, :edit?)
      @form_object = DecisionForm.new(submission:,
                                      **submission.data.slice(*DecisionForm.attribute_names))
    end

    def create
      authorize(local_submission, :update?)
      @form_object = DecisionForm.new(form_params)
      if params['save_and_exit']
        @form_object.stash
        redirect_to your_prior_authority_applications_path
      elsif @form_object.save
        redirect_to prior_authority_application_decision_path(local_submission)
      else
        render :new
      end
    end

    private

    def form_params
      params.require(:prior_authority_decision_form).permit(
        *DecisionForm.attribute_names
      ).merge(
        current_user: current_user,
        submission: local_submission,
      )
    end

    def submission
      @submission ||= PriorAuthorityApplication.load_from_app_store(params[:application_id])
    end

    def local_submission
      @local_submission ||= PriorAuthorityApplication.find(params[:application_id])
    end
  end
end
