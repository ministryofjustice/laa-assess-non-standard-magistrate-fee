module PriorAuthority
  class SendBacksController < PriorAuthority::BaseController
    def show
      @summary = BaseViewModel.build(:application_summary, submission)
      @model = BaseViewModel.build(:send_back, submission)
    end

    def new
      @form_object = SendBackForm.new(submission:,
                                      **submission.data.slice(*SendBackForm.attribute_names))
    end

    def create
      @form_object = SendBackForm.new(form_params)
      if params['save_and_exit']
        @form_object.stash
        redirect_to your_prior_authority_applications_path
      elsif @form_object.save
        redirect_to prior_authority_application_send_back_path(submission)
      else
        render :new
      end
    end

    private

    def form_params
      params.require(:prior_authority_send_back_form).permit(
        :further_information_explanation,
        :incorrect_information_explanation,
        updates_needed: []
      ).merge(
        current_user:,
        submission:,
      )
    end

    def submission
      @submission ||= PriorAuthorityApplication.find(params[:application_id])
    end
  end
end
