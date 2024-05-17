module Nsm
  class ClaimsController < ApplicationController
    before_action :set_default_table_sort_options, only: %i[your open closed]

    def your
      pagy, filtered_claims = order_and_paginate(Claim.pending_and_assigned_to(current_user))
      your_claims = filtered_claims.map { |claim| BaseViewModel.build(:table_row, claim) }

      render locals: { your_claims:, pagy: }
    end

    def open
      @pagy, claims = order_and_paginate(Claim.pending_decision)
      @claims = claims.map { |claim| BaseViewModel.build(:table_row, claim) }
    end

    def closed
      @pagy, claims = order_and_paginate(Claim.decision_made)
      @claims = claims.map { |claim| BaseViewModel.build(:assessed_claims, claim) }
    end

    def new
      claim = Claim.unassigned(current_user).order(created_at: :desc).first

      if claim
        Claim.transaction do
          claim.assignments.create!(user: current_user)
          ::Event::Assignment.build(submission: claim, current_user: current_user)
        end

        redirect_to nsm_claim_claim_details_path(claim)
      else
        redirect_to your_nsm_claims_path, flash: { notice: t('.no_pending_claims') }
      end
    end

    private

    def order_and_paginate(query)
      pagy(Sorter.call(query, @sort_by, @sort_direction))
    end

    def set_default_table_sort_options
      default = 'date_updated'
      @sort_by = params.fetch(:sort_by, default)
      @sort_direction = params.fetch(:sort_direction, 'descending')
    end
  end
end
