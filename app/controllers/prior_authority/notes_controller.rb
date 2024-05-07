module PriorAuthority
  class NotesController < PriorAuthority::BaseController
    def new
      @form_object = NoteForm.new(submission:)
    end

    def create
      @form_object = NoteForm.new(form_params)
      if @form_object.save
        redirect_to prior_authority_application_events_path(submission)
      else
        render :new
      end
    end

    private

    def form_params
      params.require(:prior_authority_note_form).permit(
        *NoteForm.attribute_names
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
