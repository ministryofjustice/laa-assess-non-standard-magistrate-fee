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
        key = heading_keys[event.event_type]
        raise "Prior Authority event summaries don't know how to display events of type #{event.event_type}" unless key

        I18n.t(key, caseworker:)
      end

      def comment?
        comment.present?
      end

      def comment
        case event.event_type
        when 'PriorAuthority::Event::DraftSendBack', 'Event::DraftDecision'
          nil
        when 'PriorAuthority::Event::SendBack'
          event.details['comments'].values.join(' ')
        else
          event.details['comment']
        end
      end

      private

      def heading_keys
        {
          'Event::NewVersion' => 'prior_authority.events.received',
          'Event::Assignment' => assignment_heading_key,
          'Event::Unassignment' => 'prior_authority.events.unassigned',
          'Event::DraftDecision' => 'prior_authority.events.draft_decision',
          'Event::Decision' => "prior_authority.events.decision_#{event.details['to']}",
          'PriorAuthority::Event::DraftSendBack' => 'prior_authority.events.draft_send_back',
          'PriorAuthority::Event::SendBack' => 'prior_authority.events.sent_back',
          'Event::Expiry' => 'prior_authority.events.expired'
        }
      end

      def assignment_heading_key
        if comment?
          'prior_authority.events.self_assigned'
        else
          'prior_authority.events.assigned'
        end
      end
    end
  end
end
