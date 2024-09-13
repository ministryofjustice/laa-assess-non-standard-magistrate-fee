module Nsm
  module V1
    class ClaimSummary < BaseViewModel
      attribute :laa_reference
      attribute :defendants
      attribute :submission
      attribute :send_by_post
      attribute :assessment_comment

      delegate :last_updated_at, to: :submission

      def main_defendant_name
        main_defendant = defendants.detect { |defendant| defendant['main'] }
        main_defendant ? construct_name(main_defendant) : ''
      end

      def assigned_to
        @assigned_to ||= submission.assignments.first
      end

      def claimed_total
        submission.formatted_claimed_total
      end

      def allowed_total
        submission.formatted_allowed_total
      end

      def display_allowed_total?
        claimed_total != allowed_total || submission.assessed?
      end
    end
  end
end
