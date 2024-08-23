module Nsm
  module V1
    class ClaimSummary < BaseViewModel
      attribute :laa_reference
      attribute :defendants
      attribute :submission
      attribute :send_by_post

      def main_defendant_name
        main_defendant = defendants.detect { |defendant| defendant['main'] }
        main_defendant ? construct_name(main_defendant) : ''
      end

      def assigned_to
        @assigned_to ||= submission.assignments.first
      end

      def assessed_on
        submission.events.where(event_type: 'Event::Decision').order(created_at: :desc).first&.created_at
      end

      def sent_back_on
        submission.events.where(event_type: 'Nsm::Event::SendBack').order(created_at: :desc).first.created_at
      end

      def assessment_comment
        @assessment_comment ||= submission.latest_decision_event&.details&.dig('comment')
      end

      def claimed_total
        submission.formatted_claimed_total
      end

      def allowed_total
        submission.formatted_allowed_total
      end

      def display_allowed_total?
        claimed_total != allowed_total || submission.display_state?
      end
    end
  end
end
