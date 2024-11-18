module Nsm
  module WorkItems
    class UpliftsController < Nsm::BaseController
      def edit
        authorize(claim)
        form = Uplift::WorkItemsForm.new(claim:)

        render locals: { claim:, form: }
      end

      def update
        authorize(claim)
        form = Uplift::WorkItemsForm.new(claim:, **form_params)

        if form.save!
          redirect_to nsm_claim_work_items_path(claim),
                      flash: { success: t('.uplift_removed') }
        else
          render :edit, locals: { claim:, form: }
        end
      end

      private

      def claim
        @claim ||= Claim.load_from_app_store(params[:claim_id])
      end

      def form_params
        params.require(:nsm_uplift_work_items_form)
              .permit(:explanation)
              .merge(current_user:)
      end
    end
  end
end
