module Nsm
  module V1
    class ClaimSummary < BaseViewModel
      attribute :laa_reference
      attribute :defendants
      attribute :submission
      attribute :send_by_post
      attribute :assessment_comment

      delegate :last_updated_at, :assigned_user, to: :submission

      def main_defendant_name
        main_defendant = defendants.detect { |defendant| defendant['main'] }
        main_defendant ? construct_name(main_defendant) : ''
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

      def sent_back_on
        if submission.data['further_information']
          submission.data['further_information'].map { _1['requested_at'].to_datetime }.max
        else
          last_updated_at
        end
      end
    end
  end
end
