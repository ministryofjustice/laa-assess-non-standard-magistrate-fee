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
                    event.created_at.in_time_zone('London').to_fs(:time_of_day)
                  ])
      end

      def caseworker_name
        caseworker&.display_name || I18n.t('prior_authority.events.na')
      end

      def caseworker
        if event.respond_to?(:secondary_user)
          event.secondary_user || event.primary_user
        else
          event.primary_user
        end
      end

      def heading
        key = heading_keys[event.event_type]
        raise "Prior Authority event summaries don't know how to display events of type #{event.event_type}" unless key

        I18n.t(key, caseworker: caseworker_name)
      end

      def comment?
        comment.present?
      end

      def comment
        case event.event_type
        when 'PriorAuthority::Event::DraftSendBack', 'Event::DraftDecision'
          nil
        when 'PriorAuthority::Event::SendBack'
          send_back_comment
        when 'Event::ProviderUpdated'
          provider_updated_comment
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
          'Event::Expiry' => 'prior_authority.events.expired',
          'Event::ProviderUpdated' => 'prior_authority.events.provider_updated',
          'Event::Note' => 'prior_authority.events.note'
        }
      end

      def assignment_heading_key
        if comment?
          'prior_authority.events.self_assigned'
        else
          'prior_authority.events.assigned'
        end
      end

      def send_back_comment
        I18n.t('prior_authority.events.send_back_comment',
               change_types: change_types(event.details['updates_needed'].include?('further_information'),
                                          event.details['updates_needed'].include?('incorrect_information')))
      end

      def provider_updated_comment
        I18n.t('prior_authority.events.provider_updated_comment',
               change_types: change_types(event.details['comment'].present?, event.details['corrected_info'].present?))
      end

      def change_types(further_information, incorrect_information)
        [
          (I18n.t('prior_authority.events.further_information') if further_information),
          (I18n.t('prior_authority.events.incorrect_information') if incorrect_information)
        ].compact.to_sentence
      end
    end
  end
end
