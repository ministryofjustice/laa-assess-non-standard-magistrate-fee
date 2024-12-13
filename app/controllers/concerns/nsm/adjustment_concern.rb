module Nsm
  module AdjustmentConcern
    extend ActiveSupport::Concern
    def confirm_deletion
      raise 'Cannot delete non-existent adjustment' unless any_adjustments?

      authorize(claim, :update?)
      @adjustment = if additional_fee?
                      view_model
                    else
                      view_model.filter(&:any_adjustments?).find do |item|
                        item.id == params[:id]
                      end
                    end

      render :confirm_delete_adjustment, locals: { claim_id: params[:claim_id], id: params[:id] }
    end

    def destroy
      authorize(claim, :update?)
      Nsm::AdjustmentDeleter.new(params, resource_klass, current_user, claim).call!
      redirect_to destroy_redirect, flash: { success: t('.success') }
    end

    private

    def destroy_redirect
      claim.any_adjustments? ? { action: :adjusted } : nsm_claim_work_items_path
    end

    def view_model
      @view_model ||= BaseViewModel.build(resource_klass, claim, nesting)
    end

    def nesting
      additional_fee? ? nil : json_search_field
    end

    def additional_fee?
      json_search_field == 'additional_fees'
    end

    def resource_klass
      return :letter_and_call if json_search_field == 'letters_and_calls'
      return params[:id].to_sym if additional_fee?

      @resource_klass ||= controller_name.singularize.to_sym
    end

    def json_search_field
      @json_search_field ||= controller_name
    end

    def any_adjustments?
      additional_fee? ? view_model.any_adjustments? : view_model.any?(&:any_adjustments?)
    end
  end
end
