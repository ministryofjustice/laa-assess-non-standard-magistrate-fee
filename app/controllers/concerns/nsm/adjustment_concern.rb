module Nsm
  module AdjustmentConcern
    extend ActiveSupport::Concern
    def confirm_deletion
      @adjustment = adjustments.find { _1.id == params[:id] }
      render :confirm_delete_adjustment, locals: { claim_id: params[:claim_id], id: params[:id] }
    end

    def destroy
      Nsm::AdjustmentDeleter.new(params, resource_klass, current_user).call
      redirect_to destroy_redirect, flash: { success: t('.success') }
    end

    private

    def claim
      @claim ||= Claim.find(params[:claim_id])
    end

    def destroy_redirect
      claim.any_adjustments? ? { action: :adjusted } : nsm_claim_work_items_path
    end

    def adjustments
      @adjustments ||= BaseViewModel
                       .build(resource_klass, claim, json_search_field)
                       .filter(&:any_adjustments?)
    end

    def resource_klass
      return :letter_and_call if json_search_field == 'letters_and_calls'

      @resource_klass ||= controller_name.singularize.to_sym
    end

    def json_search_field
      @json_search_field ||= controller_name
    end
  end
end
