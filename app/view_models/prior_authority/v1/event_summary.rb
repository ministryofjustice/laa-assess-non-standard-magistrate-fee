module PriorAuthority
  module V1
    class EventSummary
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::OutputSafetyHelper

      attribute :event

      def timestamp
        safe_join([
                    event.created_at.to_fs(:stamp),
                    tag.br,
                    event.created_at.to_fs(:time_of_day)
                  ])
      end

      def caseworker
        event.primary_user&.display_name || I18n.t('prior_authority.events.na')
      end

      def heading
        case event.event_type
        when 'Event::NewVersion'
          I18n.t('prior_authority.events.received')
        when 'Event::Assignment'
          assignment_heading
        when 'Event::Unassignment'
          I18n.t('prior_authority.events.unassigned', caseworker:)
        when 'Event::Decision'
          I18n.t("prior_authority.events.decision_#{event.details['to']}")
        else
          raise "Prior Authority event summaries don't know how to display events of type #{event.event_type}"
        end
      end

      def details?
        details.present?
      end

      def details
        event.details['comment']
      end

      private

      def assignment_heading
        if details?
          I18n.t('prior_authority.events.self_assigned', caseworker:)
        else
          I18n.t('prior_authority.events.assigned', caseworker:)
        end
      end
    end
  end
end
