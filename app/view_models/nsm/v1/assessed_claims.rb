module Nsm
  module V1
    class AssessedClaims < BaseViewModel
      attribute :laa_reference
      attribute :defendants
      attribute :firm_office
      attribute :state
      attribute :submission
      delegate :updated_at, to: :submission

      def main_defendant_name
        main_defendant = defendants.detect { |defendant| defendant['main'] }
        main_defendant ? construct_name(main_defendant) : ''
      end

      def firm_name
        firm_office['name']
      end

      def date_assessed
        I18n.l(updated_at, format: '%-d %b %Y')
      end

      def case_worker_name
        event = submission.events.where(event_type: 'Event::Decision').order(created_at: :desc).first
        event ? event.primary_user.display_name : ''
      end

      delegate :id, to: :submission
    end
  end
end
