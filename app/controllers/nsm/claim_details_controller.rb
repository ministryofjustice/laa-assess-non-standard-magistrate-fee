module Nsm
  class ClaimDetailsController < Nsm::BaseController
    def show
      authorize(claim)
      claim_summary = BaseViewModel.build(:claim_summary, claim)
      claim_details = ClaimDetails::Table.new(claim)

      render locals: { claim:, claim_summary:, claim_details:, provider_updates: }
    end

    private

    def provider_updates
      return nil if claim.data['further_information'].blank?

      BaseViewModel.build(:further_information, claim, 'further_information').sort_by(&:requested_at).reverse
    end

    def claim
      @claim ||= Claim.find(params[:claim_id])
    end
  end
end
